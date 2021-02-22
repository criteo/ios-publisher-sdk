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
#import "CR_Config.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_IntegrationRegistry.h"
#import "CR_NetworkCaptor.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSURL+Testing.h"
#import "CRBannerView.h"
#import "CRBannerView+Internal.h"
#import "CRInterstitial+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CR_URLOpenerMock.h"
#import "DFPRequestClasses.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"
#import "CRContextData.h"

@interface CR_ProfileIdFunctionalTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_DependencyProvider *dependencyProvider;

@end

@implementation CR_ProfileIdFunctionalTests

- (void)setUp {
  [super setUp];

  self.dependencyProvider =
      CR_DependencyProvider.new.withIsolatedUserDefaults.withWireMockConfiguration
          .withListenedNetworkManager.withIsolatedFeedbackStorage.withIsolatedNotificationCenter
          .withShortLiveBidTimeBudget.withConsentGiven;

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
  [self.dependencyProvider.integrationRegistry declare:CR_IntegrationInHouse];
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
  [self.dependencyProvider.integrationRegistry declare:CR_IntegrationInHouse];
  [self prepareCriteoAndGetBid];

  [self resetCriteo];
  [self.dependencyProvider.integrationRegistry declare:CR_IntegrationInHouse];
  [self prepareCriteoForGettingBid];

  NSDictionary *request = [self configRequest];
  XCTAssertEqualObjects(request[@"rtbProfileId"], @(CR_IntegrationInHouse));
}

#pragma mark - CSM

- (void)testCsm_GivenPrefetchWithSdkUsedForTheFirstTime_UseFallbackProfileId {
  CRBannerAdUnit *adUnit = [self prepareCriteoAndGetBid];

  [self.criteo.testing_networkCaptor clear];
  // Get another bid to send CSM of previous call
  [self getBidWithAdUnit:adUnit];

  NSDictionary *request = [self csmRequest];
  XCTAssertEqualObjects(request[@"profile_id"], @(CR_IntegrationFallback));
}

- (void)
    testCsm_GivenIntegrationSpecificBidConsumedWithSdkUsedForTheFirstTime_UseIntegrationProfileId {
  CRBannerAdUnit *adUnit = [self prepareCriteoAndGetBid];

  [self resetCriteo];
  [self.dependencyProvider.integrationRegistry declare:CR_IntegrationInHouse];

  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  [self getBidWithAdUnit:adUnit];

  [self.criteo.testing_networkCaptor clear];
  // Get another bid to send CSM of previous call
  [self getBidWithAdUnit:adUnit];

  NSDictionary *request = [self csmRequest];
  XCTAssertEqualObjects(request[@"profile_id"], @(CR_IntegrationInHouse));
}

#pragma mark - Standalone

- (void)validateStandaloneTest {
  [self waitForIdleState];
  NSDictionary *request = [self cdbRequest];
  XCTAssertEqualObjects(request[@"profileId"], @(CR_IntegrationStandalone));
}

- (void)testStandaloneBanner_GivenAnyPreviousIntegration_UseStandaloneProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareUsedSdkWithInHouse:adUnit];

  CRBannerView *bannerView = [[CRBannerView alloc] initWithAdUnit:adUnit criteo:self.criteo];
  [bannerView loadAdWithContext:self.contextData];

  [self validateStandaloneTest];
}

- (void)testStandaloneInterstitial_GivenAnyPreviousIntegration_UseStandaloneProfileId {
  CRInterstitialAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
  [self prepareUsedSdkWithInHouse:adUnit];

  CRInterstitial *interstitial = [[CRInterstitial alloc] initWithAdUnit:adUnit criteo:self.criteo];
  [interstitial loadAdWithContext:self.contextData];

  [self validateStandaloneTest];
}

- (void)testStandaloneNative_GivenAnyPreviousIntegration_UseStandaloneProfileId {
  CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
  [self prepareUsedSdkWithInHouse:adUnit];

  CRNativeLoader *nativeLoader =
      [[CRNativeLoader alloc] initWithAdUnit:adUnit
                                      criteo:self.criteo
                                   urlOpener:[[CR_URLOpenerMock alloc] init]];
  nativeLoader.delegate = OCMProtocolMock(@protocol(CRNativeLoaderDelegate));
  [nativeLoader loadAdWithContext:self.contextData];

  [self validateStandaloneTest];
}

#pragma mark - InHouse

- (void)testInHouseBanner_GivenAnyPreviousIntegration_UseInHouseProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  CRBid *bid = [self prepareCriteoAndGetBidWithAdUnit:adUnit];

  CRBannerView *bannerView = [[CRBannerView alloc] initWithAdUnit:adUnit criteo:self.criteo];
  [bannerView loadAdWithBid:bid];  // declares integration

  // Get another bid to request with declared integration
  [self expectIntegrationType:CR_IntegrationInHouse whenGettingBidForAdUnit:adUnit];
}

- (void)testInHouseInterstitial_GivenAnyPreviousIntegration_UseInHouseProfileId {
  CRInterstitialAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
  CRBid *bid = [self prepareCriteoAndGetBidWithAdUnit:adUnit];

  CRInterstitial *interstitial = [[CRInterstitial alloc] initWithAdUnit:adUnit criteo:self.criteo];
  [interstitial loadAdWithBid:bid];  // declares integration

  // Get another bid to request with declared integration
  [self expectIntegrationType:CR_IntegrationInHouse whenGettingBidForAdUnit:adUnit];
}

- (void)testInHouseNative_GivenAnyPreviousIntegration_UseInHouseProfileId {
  CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
  CRBid *bid = [self prepareCriteoAndGetBidWithAdUnit:adUnit];

  CRNativeLoader *nativeLoader = [[CRNativeLoader alloc] initWithAdUnit:adUnit criteo:self.criteo];
  [nativeLoader loadAdWithBid:bid];  // declares integration

  // Get another bid to request with declared integration
  [self expectIntegrationType:CR_IntegrationInHouse whenGettingBidForAdUnit:adUnit];
}

#pragma mark - AppBidding

- (void)expectAppBiddingIntegrationType:(CR_IntegrationType)expectedType
                 afterEnrichingAdObject:(id)adObject
                              forAdUnit:(CRAdUnit *)adUnit {
  // First call declares integration
  [self enrichAdObject:adObject forAdUnit:adUnit];

  // Get another bid to request with declared integration
  [self.criteo.testing_networkCaptor clear];
  [self expectIntegrationType:expectedType whenGettingBidForAdUnit:adUnit];
}

- (void)testCustomAppBidding_GivenAnyPreviousIntegration_UseCustomAppBiddingProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];

  [self prepareUsedSdkWithInHouse:adUnit];
  [self expectAppBiddingIntegrationType:CR_IntegrationCustomAppBidding
                 afterEnrichingAdObject:NSMutableDictionary.new
                              forAdUnit:adUnit];
}

- (void)testGamAppBidding_GivenAnyPreviousIntegration_UseCustomAppBiddingProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];

  [self prepareUsedSdkWithInHouse:adUnit];
  [self expectAppBiddingIntegrationType:CR_IntegrationGamAppBidding
                 afterEnrichingAdObject:GAMRequest.new
                              forAdUnit:adUnit];
}

- (void)testMopubAppBiddingBanner_GivenAnyPreviousIntegration_UseMopubAppBiddingProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];

  [self prepareUsedSdkWithInHouse:adUnit];
  [self expectAppBiddingIntegrationType:CR_IntegrationMopubAppBidding
                 afterEnrichingAdObject:MPAdView.new
                              forAdUnit:adUnit];
}

- (void)testMopubAppBiddingInterstitial_GivenAnyPreviousIntegration_UseCustomAppBiddingProfileId {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];

  [self prepareUsedSdkWithInHouse:adUnit];
  [self expectAppBiddingIntegrationType:CR_IntegrationMopubAppBidding
                 afterEnrichingAdObject:MPInterstitialAdController.new
                              forAdUnit:adUnit];
}

#pragma mark - Private

- (void)prepareUsedSdkWithInHouse:(CRAdUnit *)adUnit {
  [self prepareCriteoAndGetBidWithAdUnit:adUnit];

  [self resetCriteo];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  [self.criteo.testing_networkCaptor clear];
}

- (void)resetCriteo {
  self.criteo = [[Criteo alloc] initWithDependencyProvider:self.dependencyProvider];
}

- (void)prepareCriteoForGettingBidWithAdUnits:(NSArray *)adUnits {
  [self.criteo testing_registerWithAdUnits:adUnits];
  [self waitForIdleState];
}

- (CRBannerAdUnit *)prepareCriteoForGettingBid {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  return adUnit;
}

- (CRBid *)prepareCriteoAndGetBidWithAdUnit:(CRAdUnit *)adUnit {
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  return [self getBidWithAdUnit:adUnit];
}

- (CRBannerAdUnit *)prepareCriteoAndGetBid {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoAndGetBidWithAdUnit:adUnit];
  return adUnit;
}

- (CRBid *)getBidWithAdUnit:(CRAdUnit *)adUnit {
  [self.criteo.testing_networkCaptor clear];
  __block CRBid *bid;
  [self.criteo loadBidForAdUnit:adUnit
                    withContext:self.contextData
                responseHandler:^(CRBid *bid_) {
                  bid = bid_;
                }];
  [self waitForIdleState];
  return bid;
}

- (void)waitForIdleState {
  [self.dependencyProvider.threadManager waiter_waitIdle];
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

- (void)enrichAdObject:(id)adObject forAdUnit:(CRAdUnit *)adUnit {
  [self.criteo loadBidForAdUnit:adUnit
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [self.criteo enrichAdObject:adObject withBid:bid];
                }];
  [self waitForIdleState];
}

- (void)expectIntegrationType:(CR_IntegrationType)expectedType
      whenGettingBidForAdUnit:(CRAdUnit *)adUnit {
  [self.criteo.testing_networkCaptor clear];
  [self getBidWithAdUnit:adUnit];

  NSDictionary *request = [self cdbRequest];
  XCTAssertEqualObjects(request[@"profileId"], @(expectedType));
}

- (CRContextData *)contextData {
  return CRContextData.new;
}

@end
