//
//  CR_CdbCallsIntegrationTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CRBannerAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertDfp.h"
#import "Criteo+Internal.h"
#import "CR_BidManagerBuilder.h"
#import "CR_AdUnitHelper.h"
#import "CR_DfpCreativeViewChecker.h"
#import "NSString+CR_Url.h"
#import "CR_TargetingKeys.h"
#import "XCTestCase+Criteo.h"
@import GoogleMobileAds;

@interface CR_DfpBannerFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_DfpBannerFunctionalTests

- (void)test_givenBannerWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
    CRBannerAdUnit *banner = [CR_TestAdUnits randomBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:banner];

    XCTAssertNil(bannerDfpRequest.customTargeting);
}

- (void)test_givenBannerWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
    CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:banner];

    CR_AssertDfpCustomTargetingContainsCriteoBid(bannerDfpRequest.customTargeting);
    NSLog(@"%@", self.criteo.testing_networkCaptor.allRequests);
}

- (void)test_givenDfpRequest_whenSetBid_thenDisplayUrlEncodedProperly {
    CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    CR_BidManagerBuilder *builder = [self.criteo bidManagerBuilder];
    CR_CdbBid *bid = [builder.cacheManager getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:banner]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:banner];
    NSString *encodedUrl = bannerDfpRequest.customTargeting[CR_TargetingKey_crtDfpDisplayUrl];
    NSString *decodedUrl = [NSString decodeDfpCompatibleString:encodedUrl];

    XCTAssertEqualObjects(bid.displayUrl, decodedUrl);
}

- (void)test_givenValidBanner_whenLoadingDfpBanner_thenDfpViewContainsCreative {
    CRBannerAdUnit *bannerAdUnit = [CR_TestAdUnits preprodBanner320x50];
    [self initCriteoWithAdUnits:@[bannerAdUnit]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];
    CR_DfpCreativeViewChecker *dfpViewChecker = [[CR_DfpCreativeViewChecker alloc] initWithBannerWithSize:kGADAdSizeBanner
                                                                                             withAdUnitId:CR_TestAdUnits.dfpBanner50AdUnitId];

    [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:bannerAdUnit];
    [dfpViewChecker.dfpBannerView loadRequest:bannerDfpRequest];

    BOOL renderedProperly = [dfpViewChecker waitAdCreativeRendered];
    XCTAssert(renderedProperly);
}

- (void)test_givenGoodBannerRegistered_whenLoadingDfpBannerWithRandomAdUnitId_thenDfpViewDoNotContainCreative {
    CRBannerAdUnit *bannerAdUnit = [CR_TestAdUnits preprodBanner320x50];
    CRBannerAdUnit *bannerAdUnitRandom = [CR_TestAdUnits randomBanner320x50];
    [self initCriteoWithAdUnits:@[bannerAdUnit]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];
    CR_DfpCreativeViewChecker *dfpViewChecker = [[CR_DfpCreativeViewChecker alloc] initWithBannerWithSize:kGADAdSizeBanner
                                                                                             withAdUnitId:CR_TestAdUnits.dfpBanner50AdUnitId];

    [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:bannerAdUnitRandom];
    [dfpViewChecker.dfpBannerView loadRequest:bannerDfpRequest];

    [self criteo_waitForExpectations:@[dfpViewChecker.adCreativeRenderedExpectationWithoutExpectedCreative]];
}

@end
