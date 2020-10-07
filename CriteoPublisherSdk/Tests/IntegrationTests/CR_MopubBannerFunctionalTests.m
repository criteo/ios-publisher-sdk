//
//  CR_MopubIntegrationFunctionalTests.m
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

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CRBannerAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider.h"
#import "CR_AdUnitHelper.h"
#import <MoPub.h>
#import "CR_MopubCreativeViewChecker.h"
#import "NSString+Testing.h"
#import "CR_CacheManager.h"
#import "XCTestCase+Criteo.h"

static NSString *const kCpmKey = @"crt_cpm";
static NSString *const kDictionaryDisplayUrlKey = @"crt_displayUrl";
static NSString *const kSizeKey = @"crt_size";

static NSString *initialMopubKeywords = @"key1:value1,key2:value2";

@interface CR_MopubBannerFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_MopubBannerFunctionalTests

- (void)test_givenBannerWithBadAdUnitId_whenEnrichAdObject_thenRequestKeywordsDoNotChange {
  CRBannerAdUnit *banner = [CR_TestAdUnits randomBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  MPAdView *adView = [[MPAdView alloc] init];
  adView.keywords = initialMopubKeywords;

  [self enrichAdObject:adView forAdUnit:banner];

  XCTAssertEqualObjects(initialMopubKeywords, adView.keywords);
}

- (void)test_givenBannerWithGoodAdUnitId_whenEnrichAdObject_thenRequestKeywordsUpdated {
  CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  MPAdView *adView = [[MPAdView alloc] init];
  adView.keywords = initialMopubKeywords;
  CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;
  CR_CdbBid *bid = [dependencyProvider.cacheManager
      getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:banner]];
  NSDictionary *expected = @{
    kCpmKey : bid.cpm,
    kDictionaryDisplayUrlKey : bid.displayUrl,
    kSizeKey : @"320x50",
    @"key1" : @"value1",
    @"key2" : @"value2"
  };

  [self enrichAdObject:adView forAdUnit:banner];

  NSDictionary *keywords = [adView.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
}

// Note this test relies on WireMock, for more information see wiremock/wiremock.md
- (void)test_givenValidBanner_whenLoadingMopubBanner_thenMopubViewContainsCreative {
  CRBannerAdUnit *bannerAdUnit = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ bannerAdUnit ]];

  MPAdView *mpAdView = [[MPAdView alloc] initWithAdUnitId:CR_TestAdUnits.mopubBanner50AdUnitId];
  mpAdView.maxAdSize = kMPPresetMaxAdSize50Height;
  [self enrichAdObject:mpAdView forAdUnit:bannerAdUnit];

  CR_MopubCreativeViewChecker *viewChecker =
      [[CR_MopubCreativeViewChecker alloc] initWithBanner:mpAdView];

  [viewChecker initMopubSdkAndRenderAd:mpAdView];

  BOOL renderedProperly = [viewChecker waitAdCreativeRendered];
  XCTAssertTrue(renderedProperly);
}

@end
