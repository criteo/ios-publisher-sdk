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
#import <CriteoPublisherSdk/CriteoPublisherSdk-Swift.h>
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_ThreadManager.h"
#import "Logging.h"
#import "CR_DependencyProvider.h"
#import "CR_IntegrationRegistry.h"

@implementation Criteo

#pragma mark - Lifecycle

+ (instancetype)sharedCriteo {
  static Criteo *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self criteo];
  });

  return sharedInstance;
}

- (void)registerCriteoPublisherId:(NSString *)criteoPublisherId
                      withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  @synchronized(self) {
    if (!self.isRegistered) {
      self.registered = true;
      @try {
        [self.dependencyProvider.threadManager dispatchAsyncOnGlobalQueue:^{
          [self _registerCriteoPublisherId:criteoPublisherId withAdUnits:adUnits];
        }];
      } @catch (NSException *exception) {
        CLogException(exception);
      }
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

#pragma mark - Bidding

- (void)loadBidForAdUnit:(CRAdUnit *)adUnit responseHandler:(CRBidResponseHandler)responseHandler {
  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  [self.bidManager loadCdbBidForAdUnit:cacheAdUnit
                       responseHandler:^(CR_CdbBid *cdbBid) {
                         [self.threadManager dispatchAsyncOnMainQueue:^{
                           CRBid *bid = [[CRBid alloc] initWithCdbBid:cdbBid adUnit:adUnit];
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
    [self validateIntegration];
  }
  return self;
}

+ (instancetype)criteo {
  Criteo *criteo = nil;
  @try {
    CR_DependencyProvider *dependencyProvider = [[CR_DependencyProvider alloc] init];
    criteo = [[self alloc] initWithDependencyProvider:dependencyProvider];
  } @catch (NSException *exception) {
    CLogException(exception);
  }
  return criteo;
}

- (void)_registerCriteoPublisherId:(NSString *)criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  self.config.criteoPublisherId = criteoPublisherId;
  [self.appEvents registerForIosEvents];
  [self.appEvents sendLaunchEvent];
  [self.configManager refreshConfig:self.config];
  CR_CacheAdUnitArray *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:adUnits];

  if (self.config.isPrefetchOnInitEnabled) {
    [self.bidManager prefetchBidsForAdUnits:cacheAdUnits];
  }
}

#pragma mark Generic

- (void)loadCdbBidForAdUnit:(CR_CacheAdUnit *)slot
            responseHandler:(CR_CdbBidResponseHandler)responseHandler {
  [self.bidManager loadCdbBidForAdUnit:slot responseHandler:responseHandler];
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

@end
