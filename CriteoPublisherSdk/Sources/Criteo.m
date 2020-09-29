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
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_ThreadManager.h"
#import "Logging.h"
#import "CR_DependencyProvider.h"
#import "CR_IntegrationRegistry.h"

@interface Criteo ()

@property(nonatomic, strong) NSMutableArray<CR_CacheAdUnit *> *registeredAdUnits;
@property(nonatomic, strong, readonly) CR_BidManager *bidManager;
@property(nonatomic, assign) bool hasPrefetched;
@property(nonatomic, assign) bool registered;

@end

@implementation Criteo

- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut {
  const CR_CcpaCriteoState state =
      usPrivacyOptOut ? CR_CcpaCriteoStateOptOut : CR_CcpaCriteoStateOptIn;
  self.bidManager.consent.usPrivacyCriteoState = state;
}

- (void)setMopubConsent:(NSString *)mopubConsent {
  self.bidManager.consent.mopubConsent = mopubConsent;
}

- (id<CR_NetworkManagerDelegate>)networkManagerDelegate {
  return self.bidManager.networkManagerDelegate;
}

- (void)setNetworkManagerDelegate:(id<CR_NetworkManagerDelegate>)networkManagerDelegate {
  self.bidManager.networkManagerDelegate = networkManagerDelegate;
}

+ (instancetype)sharedCriteo {
  static Criteo *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self criteo];
  });

  return sharedInstance;
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

- (instancetype)initWithDependencyProvider:(CR_DependencyProvider *)dependencyProvider {
  if (self = [super init]) {
    _registeredAdUnits = [[NSMutableArray alloc] init];
    _registered = false;
    _hasPrefetched = false;
    _dependencyProvider = dependencyProvider;
  }
  return self;
}

- (void)registerCriteoPublisherId:(NSString *)criteoPublisherId
                      withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  @synchronized(self) {
    if (!self.registered) {
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

- (void)_registerCriteoPublisherId:(NSString *)criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  self.config.criteoPublisherId = criteoPublisherId;

  CR_CacheAdUnitArray *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:adUnits];
  [self.registeredAdUnits addObjectsFromArray:cacheAdUnits];
  [self.bidManager registerWithSlots:cacheAdUnits];
  if (!self.config.liveBiddingEnabled) {
    [self prefetchAll];
  }
}

- (CR_BidManager *)bidManager {
  return self.dependencyProvider.bidManager;
}

- (void)prefetchAll {
  if (!self.hasPrefetched) {
    [self.bidManager prefetchBidsForAdUnits:self.registeredAdUnits];
    self.hasPrefetched = YES;
  }
}

- (void)setBidsForRequest:(id)request withAdUnit:(CRAdUnit *)adUnit {
  [self.bidManager addCriteoBidToRequest:request
                               forAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]];
}

- (CRBidResponse *)getBidResponseForAdUnit:(CRAdUnit *)adUnit {
  [self.integrationRegistry declare:CR_IntegrationInHouse];
  return [self.bidManager bidResponseForCacheAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]
                                         adUnitType:adUnit.adUnitType];
}

- (void)getBid:(CR_CacheAdUnit *)slot responseHandler:(CR_BidResponseHandler)responseHandler {
  [self.bidManager getBidForAdUnit:slot bidResponseHandler:responseHandler];
}

- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType {
  return [self.bidManager tokenValueForBidToken:bidToken adUnitType:adUnitType];
}

- (CR_Config *)config {
  return self.dependencyProvider.config;
}

- (CR_ThreadManager *)threadManager {
  return self.dependencyProvider.threadManager;
}

- (CR_IntegrationRegistry *)integrationRegistry {
  return self.dependencyProvider.integrationRegistry;
}

@end
