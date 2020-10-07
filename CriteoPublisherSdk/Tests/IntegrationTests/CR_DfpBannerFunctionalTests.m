//
//  CR_CdbCallsIntegrationTests.m
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
@import GoogleMobileAds;

#import <XCTest/XCTest.h>

#import "Criteo+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CRBannerAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertDfp.h"
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_DependencyProvider.h"
#import "CR_DfpCreativeViewChecker.h"
#import "CR_TargetingKeys.h"
#import "CR_CacheManager.h"
#import "NSString+CriteoUrl.h"

@interface CR_DfpBannerFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_DfpBannerFunctionalTests

- (void)test_givenBannerWithBadAdUnitId_whenEnrichAdObject_thenRequestKeywordsDoNotChange {
  CRBannerAdUnit *banner = [CR_TestAdUnits randomBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

  [self enrichAdObject:(id)bannerDfpRequest forAdUnit:banner];

  XCTAssertNil(bannerDfpRequest.customTargeting);
}

- (void)test_givenBannerWithGoodAdUnitId_whenEnrichAdObject_thenRequestKeywordsUpdated {
  CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

  [self enrichAdObject:(id)bannerDfpRequest forAdUnit:banner];

  CR_AssertDfpCustomTargetingContainsCriteoBid(bannerDfpRequest.customTargeting);
  NSLog(@"%@", self.criteo.testing_networkCaptor.allRequests);
}

- (void)test_givenDfpRequest_whenSetBid_thenDisplayUrlEncodedProperly {
  CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;
  CR_CdbBid *bid = [dependencyProvider.cacheManager
      getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:banner]];
  DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

  [self enrichAdObject:(id)bannerDfpRequest forAdUnit:banner];

  NSString *encodedUrl = bannerDfpRequest.customTargeting[CR_TargetingKey_crtDfpDisplayUrl];
  NSString *decodedUrl = [NSString cr_decodeDfpCompatibleString:encodedUrl];

  XCTAssertEqualObjects(bid.displayUrl, decodedUrl);
}

// Note this test relies on WireMock, for more information see wiremock/wiremock.md
- (void)test_givenValidBanner_whenLoadingDfpBanner_thenDfpViewContainsCreative {
  CRBannerAdUnit *bannerAdUnit = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ bannerAdUnit ]];
  DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];
  CR_DfpCreativeViewChecker *dfpViewChecker =
      [[CR_DfpCreativeViewChecker alloc] initWithBannerWithSize:kGADAdSizeBanner
                                                   withAdUnitId:CR_TestAdUnits.dfpBanner50AdUnitId];

  [self enrichAdObject:(id)bannerDfpRequest forAdUnit:bannerAdUnit];

  [dfpViewChecker.dfpBannerView loadRequest:bannerDfpRequest];

  BOOL renderedProperly = [dfpViewChecker waitAdCreativeRendered];
  XCTAssert(renderedProperly);
}

- (void)
    test_givenGoodBannerRegistered_whenLoadingDfpBannerWithRandomAdUnitId_thenDfpViewDoNotContainCreative {
  CRBannerAdUnit *bannerAdUnit = [CR_TestAdUnits preprodBanner320x50];
  CRBannerAdUnit *bannerAdUnitRandom = [CR_TestAdUnits randomBanner320x50];
  [self initCriteoWithAdUnits:@[ bannerAdUnit ]];
  DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];
  CR_DfpCreativeViewChecker *dfpViewChecker =
      [[CR_DfpCreativeViewChecker alloc] initWithBannerWithSize:kGADAdSizeBanner
                                                   withAdUnitId:CR_TestAdUnits.dfpBanner50AdUnitId];

  [self enrichAdObject:(id)bannerDfpRequest forAdUnit:bannerAdUnitRandom];
  [dfpViewChecker.dfpBannerView loadRequest:bannerDfpRequest];

  BOOL renderedProperly = [dfpViewChecker waitAdCreativeRendered];
  XCTAssertFalse(renderedProperly);
}

- (void)test_givenBannerAdUnit_whenEnrichAdObjectForRequest_thenRequestKeywordsContainsCrtSize {
  CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ adUnit ]];
  DFPRequest *request = [[DFPRequest alloc] init];

  [self enrichAdObject:(id)request forAdUnit:adUnit];

  XCTAssertEqualObjects(request.customTargeting[@"crt_size"], @"320x50");
}

@end
