//
//  CR_MopubIntegrationFunctionalTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CRBannerAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertMopub.h"
#import "Criteo+Internal.h"
#import "Criteo+Testing.h"
#import "CR_BidManagerBuilder.h"
#import "CR_AdUnitHelper.h"
#import <MoPub.h>
#import "CR_MopubCreativeViewChecker.h"

static NSString *initialMopubKeywords = @"key1:value1,key2:value2";

@interface CR_MopubBannerFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_MopubBannerFunctionalTests

- (void)test_givenBannerWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
    CRBannerAdUnit *banner = [CR_TestAdUnits randomBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    MPAdView *adView = [[MPAdView alloc] init];
    adView.keywords = initialMopubKeywords;

    [self.criteo setBidsForRequest:adView withAdUnit:banner];

    XCTAssertEqualObjects(initialMopubKeywords, adView.keywords);
}

- (void)test_givenBannerWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
    CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    MPAdView *adView = [[MPAdView alloc] init];
    adView.keywords = initialMopubKeywords;
    CR_BidManagerBuilder *builder = [self.criteo bidManagerBuilder];
    CR_CdbBid *bid = [builder.cacheManager getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:banner]];

    [self.criteo setBidsForRequest:adView withAdUnit:banner];

    CR_AssertMopubKeywordContainsCriteoBid(adView.keywords, initialMopubKeywords, bid.displayUrl);
}

- (void)test_givenValidBanner_whenLoadingMopubBanner_thenMopubViewContainsCreative {
    CRBannerAdUnit *bannerAdUnit = [CR_TestAdUnits preprodBanner320x50];
    [self initCriteoWithAdUnits:@[bannerAdUnit]];

    MPAdView *mpAdView = [[MPAdView alloc] initWithAdUnitId:CR_TestAdUnits.mopubBanner50AdUnitId];
    mpAdView.maxAdSize = kMPPresetMaxAdSize50Height;
    [self.criteo setBidsForRequest:mpAdView withAdUnit:bannerAdUnit];

    CR_MopubCreativeViewChecker *viewChecker = [[CR_MopubCreativeViewChecker alloc] initWithBanner:mpAdView];

    [viewChecker initMopubSdkAndRenderAd:mpAdView];

    BOOL renderedProperly = [viewChecker waitAdCreativeRendered];
    XCTAssertTrue(renderedProperly);
}

@end
