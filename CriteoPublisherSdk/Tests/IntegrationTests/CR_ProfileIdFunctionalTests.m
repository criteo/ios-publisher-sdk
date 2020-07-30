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
#import <OCMock.h>

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
#import "CRBannerView.h"
#import "CRBannerView+Internal.h"
#import "CRInterstitial+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CR_URLOpenerMock.h"

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
  [self prepareCriteoForGettingBid];

  NSDictionary *request = [self cdbRequest];
  XCTAssertEqualObjects(request[@"profileId"], @(CR_IntegrationFallback));
}

- (void)testPrefetch_GivenUsedSdk_UseLastProfileId {
  [self prepareCriteoAndGetBid];

  NSDictionary *request = [self cdbRequest];
  XCTAssertEqualObjects(request[@"profileId"], @(CR_IntegrationInHouse));
}

#pragma mark - Config

- (void)testRemoteConfig_GivenSdkUsedForTheFirstTime_UseFallbackProfileId {
  [self prepareCriteoForGettingBid];

  NSDictionary *request = [self configRequest];
  XCTAssertEqualObjects(request[@"rtbProfileId"], @(CR_IntegrationFallback));
}

- (void)testRemoteConfig_GivenUsedSdk_UseLastProfileId {
  [self prepareCriteoAndGetBid];

  [self resetCriteo];
  [self prepareCriteoForGettingBid];

  NSDictionary *request = [self configRequest];
  XCTAssertEqualObjects(request[@"rtbProfileId"], @(CR_IntegrationInHouse));
}

#pragma mark - CSM

- (void)testCsm_GivenPrefetchWithSdkUsedForTheFirstTime_UseFallbackProfileId {
  [self prepareCriteoAndGetBid];

  NSDictionary *request = [self csmRequest];
  XCTAssertEqualObjects(request[@"profile_id"], @(CR_IntegrationFallback));
}

- (void)
    testCsm_GivenIntegrationSpecificBidConsumedWithSdkUsedForTheFirstTime_UseIntegrationProfileId {
  CRBannerAdUnit *adUnit = [self prepareCriteoAndGetBid];

  [self resetCriteo];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  [self getBidResponseWithAdUnit:adUnit];

  NSDictionary *request = [self csmRequest];
  XCTAssertEqualObjects(request[@"profile_id"], @(CR_IntegrationInHouse));
}

#pragma mark - Standalone

- (void)prepareStandaloneTest:(CRAdUnit *)adUnit {
  [self prepareCriteoAndGetBidWithAdUnit:adUnit];

  [self resetCriteo];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  [self.criteo.testing_networkCaptor clear];
}

- (void)validateStandaloneTest {
  [self waitForBid];
  NSDictionary *request = [self cdbRequest];
  XCTAssertEqualObjects(request[@"profileId"], @(CR_IntegrationStandalone));
}

- (void)testStandaloneBanner_GivenAnyPreviousIntegration_UseStandaloneProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareStandaloneTest:adUnit];

  CRBannerView *bannerView = [[CRBannerView alloc] initWithAdUnit:adUnit criteo:self.criteo];
  [bannerView loadAd];

  [self validateStandaloneTest];
}

- (void)testStandaloneInterstitial_GivenAnyPreviousIntegration_UseStandaloneProfileId {
  CRInterstitialAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
  [self prepareStandaloneTest:adUnit];

  CRInterstitial *interstitial = [[CRInterstitial alloc] initWithAdUnit:adUnit criteo:self.criteo];
  [interstitial loadAd];

  [self validateStandaloneTest];
}

// FIXME Fails at getting a bid
- (void)broken_testStandaloneNative_GivenAnyPreviousIntegration_UseStandaloneProfileId {
  CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
  [self prepareStandaloneTest:adUnit];

  CRNativeLoader *nativeLoader =
      [[CRNativeLoader alloc] initWithAdUnit:adUnit
                                      criteo:self.criteo
                                   urlOpener:[[CR_URLOpenerMock alloc] init]];
  nativeLoader.delegate = OCMProtocolMock(@protocol(CRNativeLoaderDelegate));
  [nativeLoader loadAd];

  [self validateStandaloneTest];
}

#pragma mark - Private

- (void)resetCriteo {
  self.criteo = [[Criteo alloc] initWithDependencyProvider:self.dependencyProvider];
}

- (void)prepareCriteoForGettingBidWithAdUnits:(NSArray *)adUnits {
  [self.criteo testing_registerWithAdUnits:adUnits];
  [self.criteo testing_waitForRegisterHTTPResponses];
}

- (CRBannerAdUnit *)prepareCriteoForGettingBid {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  return adUnit;
}

- (void)prepareCriteoAndGetBidWithAdUnit:(CRAdUnit *)adUnit {
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  [self getBidResponseWithAdUnit:adUnit];
}

- (CRBannerAdUnit *)prepareCriteoAndGetBid {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoAndGetBidWithAdUnit:adUnit];
  return adUnit;
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

- (NSDictionary *)configRequest {
  return [self requestPassingTest:^BOOL(CR_HttpContent *httpContent) {
    return [httpContent.url testing_isConfigUrlWithConfig:self.criteo.config];
  }];
}

- (NSDictionary *)csmRequest {
  return [self requestPassingTest:^BOOL(CR_HttpContent *httpContent) {
    return [httpContent.url testing_isFeedbackMessageUrlWithConfig:self.criteo.config];
  }];
}

@end
