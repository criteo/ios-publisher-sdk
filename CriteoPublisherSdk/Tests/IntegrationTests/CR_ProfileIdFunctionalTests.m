//
//  CR_ProfileIdFunctionalTests.m
//  CriteoPublisherSdkTests
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

#import <FunctionalObjC/FBLFunctional.h>
#import <XCTest/XCTest.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_IntegrationRegistry.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSURL+Testing.h"

@interface CR_ProfileIdFunctionalTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_DependencyProvider *dependencyProvider;

@end

@implementation CR_ProfileIdFunctionalTests

- (void)setUp {
  [super setUp];

  self.dependencyProvider =
      CR_DependencyProvider.new.withIsolatedUserDefaults.withWireMockConfiguration
          .withListenedNetworkManager.withIsolatedFeedbackStorage.withIsolatedNotificationCenter;

  [self resetCriteo];
}

- (void)tearDown {
  CR_ThreadManager *threadManager = self.criteo.dependencyProvider.threadManager;
  [threadManager waiter_waitIdle];
  [super tearDown];
}

#pragma mark - Prefetch

- (void)testPrefetch_GivenSdkUsedForTheFirstTime_UseFallbackProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];

  NSDictionary *request = [self cdbRequest];
  XCTAssertEqualObjects(request[@"profileId"], @(CR_IntegrationFallback));
}

- (void)testPrefetch_GivenUsedSdk_UseLastProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];

  [self getBidResponseWithAdUnit:adUnit];

  NSDictionary *request = [self cdbRequest];
  XCTAssertEqualObjects(request[@"profileId"], @(CR_IntegrationInHouse));
}

#pragma mark - Private

- (void)resetCriteo {
  self.criteo = [[Criteo alloc] initWithDependencyProvider:self.dependencyProvider];
}

- (void)prepareCriteoForGettingBidWithAdUnits:(NSArray *)adUnits {
  [self.criteo testing_registerWithAdUnits:adUnits];
  [self.criteo testing_waitForRegisterHTTPResponses];
}

- (void)getBidResponseWithAdUnit:(CRAdUnit *)adUnit {
  [self.criteo.testing_networkCaptor clear];
  [self.criteo getBidResponseForAdUnit:adUnit];
  [self waitForBid];
}

- (void)waitForBid {
  CR_NetworkWaiterBuilder *builder =
      [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.criteo.config
                                        networkCaptor:self.criteo.testing_networkCaptor];
  CR_NetworkWaiter *waiter = builder.withBid.withFinishedRequestsIncluded.build;
  const BOOL result = [waiter wait];
  XCTAssert(result, @"Failed waiting for a bid");
}

- (NSDictionary *)requestPassingTest:(BOOL (^)(CR_HttpContent *))predicate {
  NSArray<CR_HttpContent *> *requests = self.criteo.testing_networkCaptor.allRequests;
  NSUInteger index = [requests
      indexOfObjectPassingTest:^BOOL(CR_HttpContent *httpContent, NSUInteger idx, BOOL *stop) {
        return predicate(httpContent);
      }];
  CR_HttpContent *request = (index != NSNotFound) ? requests[index] : nil;
  return request.requestBody;
}

- (NSDictionary *)cdbRequest {
  return [self requestPassingTest:^BOOL(CR_HttpContent *httpContent) {
    return [httpContent.url testing_isBidUrlWithConfig:self.criteo.config];
  }];
}

@end
