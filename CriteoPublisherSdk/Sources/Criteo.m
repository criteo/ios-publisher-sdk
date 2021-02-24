//
//  Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Criteo.h"
#if __has_include("CriteoPublisherSdk-Swift.h")
#import "CriteoPublisherSdk-Swift.h"
#else
#import <CriteoPublisherSdk/CriteoPublisherSdk-Swift.h>
#endif
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_ThreadManager.h"
#import "CR_Logging.h"
#import "CR_DependencyProvider.h"
#import "CR_IntegrationRegistry.h"
#import "CR_UserDataHolder.h"
#import "CR_URLOpener.h"

@implementation Criteo

#pragma mark - Lifecycle

- (void)setup {
  CRLogInfo(@"Initialization", @"Singleton was initialized");

  if (!CRSKAdNetworkInfo.hasCriteoId) {
    CRLogInfo(
        @"SKAdNetwork",
        @"SKAdNetwork Criteo ID \"%@\" is missing in application Info.plist.\n"
         "Your application won't be eligible to App Install campaigns.\n"
         "For more details, please go to https://publisherdocs.criteotilt.com/app/ios/ios14/#skadnetwork",
        CRSKAdNetworkInfo.CriteoId);
  }

  if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-CriteoPublisherSdkVerboseLogs"]) {
    [self.class setVerboseLogsEnabled:YES];
  }

  CR_Gdpr *gdpr = self.dependencyProvider.consent.gdpr;
  CRLogInfo(@"Consent", @"Initialized with TCF: %@", gdpr);
}

static Criteo *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedCriteo {
  // The initialization step of the SDK involves logger which need the sharedCriteo.
  // To handle the circular dependency, the pure instantiation is separated from the initialization.
  __block BOOL wasInstantiated = NO;

  dispatch_once(&onceToken, ^{
    @try {
      sharedInstance = [[self alloc] initWithDependencyProvider:CR_DependencyProvider.new];
      wasInstantiated = YES;
    } @catch (NSException *exception) {
      NSLog(@"Criteo Singleton initialization failed: %@", exception);
    }
  });

  if (wasInstantiated) {
    [sharedInstance setup];
  }

  return sharedInstance;
}

+ (void)resetSharedCriteo {
  sharedInstance = nil;
  onceToken = 0;
}

- (void)registerCriteoPublisherId:(NSString *)criteoPublisherId
                      withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  if (criteoPublisherId == nil || criteoPublisherId.length == 0) {
    CRLogError(@"Registration", @"Invalid Criteo publisher ID: \"%@\"", criteoPublisherId);
  }
  @synchronized(self) {
    if (!self.isRegistered) {
      self.registered = true;
      @try {
        [self.dependencyProvider.threadManager dispatchAsyncOnGlobalQueue:^{
          [self _registerCriteoPublisherId:criteoPublisherId withAdUnits:adUnits];
          CRLogInfo(@"Registration",
                    @"Criteo SDK version %@ is registered with Publisher ID %@ and %d ad units: %@",
                    CRITEO_PUBLISHER_SDK_VERSION, criteoPublisherId, adUnits.count, adUnits);
        }];
      } @catch (NSException *exception) {
        CRLogException(
            @"Registration", exception,
            @"Criteo SDK version %@ failed registering Publisher ID %@ and %d ad units: %@",
            CRITEO_PUBLISHER_SDK_VERSION, criteoPublisherId, adUnits.count, adUnits);
      }
    } else {
      CRLogInfo(
          @"Registration",
          @"You should only call register method once. Please ignore this if you're using a mediation adapter.");
    }
  }
}

#pragma mark - Consent Management

- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut {
  const CR_CcpaCriteoState state =
      usPrivacyOptOut ? CR_CcpaCriteoStateOptOut : CR_CcpaCriteoStateOptIn;
  self.bidManager.consent.usPrivacyCriteoState = state;
}

- (void)setMopubConsent:(NSString *)mopubConsent {
  self.bidManager.consent.mopubConsent = mopubConsent;
}

#pragma mark - User data

- (void)setUserData:(CRUserData *)userData {
  self.dependencyProvider.userDataHolder.userData = userData;
}

#pragma mark - Bidding

- (void)loadBidForAdUnit:(CRAdUnit *)adUnit responseHandler:(CRBidResponseHandler)responseHandler {
  [self loadBidForAdUnit:adUnit withContext:CRContextData.new responseHandler:responseHandler];
}

- (void)loadBidForAdUnit:(CRAdUnit *)adUnit
             withContext:(CRContextData *)contextData
         responseHandler:(CRBidResponseHandler)responseHandler {
  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  [self.bidManager loadCdbBidForAdUnit:cacheAdUnit
                           withContext:contextData
                       responseHandler:^(CR_CdbBid *cdbBid) {
                         [self.threadManager dispatchAsyncOnMainQueue:^{
                           CRBid *bid =
                               cdbBid ? [[CRBid alloc] initWithCdbBid:cdbBid adUnit:adUnit] : nil;
                           CRLogInfo(@"Bidding", @"Loaded bid: %@", bid);
                           responseHandler(bid);
                         }];
                       }];
}

#pragma mark App bidding

- (void)enrichAdObject:(id)object withBid:(CRBid *)bid {
  [self.bidManager enrichAdObject:object withBid:bid];
}

#pragma mark - Private
#pragma mark Lifecycle

- (instancetype)initWithDependencyProvider:(CR_DependencyProvider *)dependencyProvider {
  if (self = [super init]) {
    _registered = false;
    _dependencyProvider = dependencyProvider;
  }
  return self;
}

- (void)_registerCriteoPublisherId:(NSString *)criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  self.config.criteoPublisherId = criteoPublisherId;
  [self.appEvents registerForIosEvents];
  [self.appEvents sendLaunchEvent];
  [self.configManager refreshConfig:self.config];
  CR_CacheAdUnitArray *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:adUnits];

  if (self.config.isPrefetchOnInitEnabled) {
    [self.bidManager prefetchBidsForAdUnits:cacheAdUnits withContext:CRContextData.new];
  }
}

#pragma mark Generic

- (void)loadCdbBidForAdUnit:(CR_CacheAdUnit *)slot
                withContext:(CRContextData *)contextData
            responseHandler:(CR_CdbBidResponseHandler)responseHandler {
  [self.bidManager loadCdbBidForAdUnit:slot
                           withContext:contextData
                       responseHandler:responseHandler];
}

#pragma mark Properties

- (CR_AppEvents *)appEvents {
  return self.dependencyProvider.appEvents;
}

- (CR_BidManager *)bidManager {
  return self.dependencyProvider.bidManager;
}

- (CR_Config *)config {
  return self.dependencyProvider.config;
}

- (CR_ConfigManager *)configManager {
  return self.dependencyProvider.configManager;
}

- (CR_IntegrationRegistry *)integrationRegistry {
  return self.dependencyProvider.integrationRegistry;
}

- (id<CR_NetworkManagerDelegate>)networkManagerDelegate {
  return self.bidManager.networkManagerDelegate;
}

- (void)setNetworkManagerDelegate:(id<CR_NetworkManagerDelegate>)networkManagerDelegate {
  self.bidManager.networkManagerDelegate = networkManagerDelegate;
}

- (CR_ThreadManager *)threadManager {
  return self.dependencyProvider.threadManager;
}

#pragma mark - Debug

+ (void)setVerboseLogsEnabled:(BOOL)enabled {
  [CR_Logging setConsoleSeverityThreshold:enabled ? CR_LogSeverityInfo : CR_LogSeverityWarning];
}

#pragma mark - Intended for manual tests

+ (void)loadProductWithParameters:(NSDictionary *)parameters
               fromViewController:(UIViewController *)controller {
  CR_URLOpener *opener = [[CR_URLOpener alloc] init];
  [opener openExternalURL:[NSURL URLWithString:@"https://apps.apple.com"]
      withSKAdNetworkParameters:[[CR_SKAdNetworkParameters alloc] initWithDict:parameters]
             fromViewController:controller
                     completion:^(BOOL success){
                     }];
}

@end
