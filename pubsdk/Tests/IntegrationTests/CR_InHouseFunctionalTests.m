//
//  CRInHouseFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 1/22/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "Criteo.h"
#import "XCTestCase+Criteo.h"
#import "CRBannerView.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_CreativeViewChecker.h"
#import "CR_TestAdUnits.h"

static NSString *creativeUrl1 = @"www.criteo.com";
static NSString *creativeUrl2 = @"www.apple.com";

@interface CR_InHouseFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_InHouseFunctionalTests

- (void)test_givenBanner_whenLoadBidToken_thenBannerReceiveAd {
    CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    CRBidResponse *response = [self.criteo getBidResponseForAdUnit:banner];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner criteo:self.criteo];

    [checker.bannerView loadAdWithBidToken:response.bidToken];

    [self criteo_waitForExpectations:@[checker.bannerViewDidReceiveAdExpectation]];
}

- (void)test_givenBannerWithBadAdUnitId_whenLoadBidToken_thenBannerFailToReceiveAd {
    CRBannerAdUnit *banner = [CR_TestAdUnits randomBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    CRBidResponse *response = [self.criteo getBidResponseForAdUnit:banner];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner criteo:self.criteo];

    [checker.bannerView loadAdWithBidToken:response.bidToken];

    [self criteo_waitForExpectations:@[checker.bannerViewFailToReceiveAdExpectation]];
}

- (void)test_givenBadBanner_whenLoadValidBidToken_thenBannerFailToReceiveAd {
    CRBannerAdUnit *banner1 = [CR_TestAdUnits preprodBanner320x50];
    CRBannerAdUnit *banner2 = [CR_TestAdUnits randomBanner320x50];
    [self initCriteoWithAdUnits:@[banner1]];
    CRBidResponse *response = [self.criteo getBidResponseForAdUnit:banner1];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner2 criteo:self.criteo];

    [checker.bannerView loadAdWithBidToken:response.bidToken];

    [self criteo_waitForExpectations:@[checker.bannerViewFailToReceiveAdExpectation]];
}

- (void)test_givenBanner_whenLoadWrongBidToken_thenBannerFailToReceiveAd {
    CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
    CRBannerAdUnit *orphan = [CR_TestAdUnits demoBanner320x50];
    [self initCriteoWithAdUnits:@[adUnit, orphan]];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:adUnit
                                                                              criteo:self.criteo];
    CRBidResponse *orphanBid = [self.criteo getBidResponseForAdUnit:orphan];

    [checker.bannerView loadAdWithBidToken:orphanBid.bidToken];

    [self criteo_waitForExpectations:@[checker.bannerViewFailToReceiveAdExpectation]];
}

- (void)test_givenBannerLoadWrongBidToken_whenLoadGoodBidToken_thenBannerReceiveAd {
    CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
    CRBannerAdUnit *orphan = [CR_TestAdUnits demoBanner320x50];
    [self initCriteoWithAdUnits:@[adUnit, orphan]];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:adUnit
                                                                              criteo:self.criteo];
    CRBidResponse *orphanBid = [self.criteo getBidResponseForAdUnit:orphan];
    [checker.bannerView loadAdWithBidToken:orphanBid.bidToken];
    [checker resetExpectations];

    CRBidResponse *goodBid = [self.criteo getBidResponseForAdUnit:adUnit];
    [checker.bannerView loadAdWithBidToken:goodBid.bidToken];
    [self criteo_waitForExpectations:@[checker.bannerViewDidReceiveAdExpectation]];
}

- (void)test_givenBanner_whenLoadBidTokenTwice_thenBannerFailToReceiveAd {
    CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    CRBidResponse *response = [self.criteo getBidResponseForAdUnit:banner];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner criteo:self.criteo];
    [checker.bannerView loadAdWithBidToken:response.bidToken];
    [self criteo_waitForExpectations:@[checker.bannerViewDidReceiveAdExpectation]];
    checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner criteo:self.criteo];

    [checker.bannerView loadAdWithBidToken:response.bidToken];

    [self criteo_waitForExpectations:@[checker.bannerViewFailToReceiveAdExpectation]];
}

- (void)test_givenTwoAdRenderings_whenReuseSameBannerView_thenTwoAdsPresented {
    CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner criteo:self.criteo];

    [checker injectBidWithExpectedCreativeUrl:creativeUrl2];
    CRBidResponse *response = [self.criteo getBidResponseForAdUnit:banner];
    [checker.bannerView loadAdWithBidToken:response.bidToken];
    [self criteo_waitForExpectations:@[checker.bannerViewDidReceiveAdExpectation]];

    [checker resetExpectations];

    [checker injectBidWithExpectedCreativeUrl:creativeUrl2];
    response = [self.criteo getBidResponseForAdUnit:banner];
    [checker.bannerView loadAdWithBidToken:response.bidToken];
    [self criteo_waitForExpectations:@[checker.bannerViewDidReceiveAdExpectation]];
}

- (void)test_givenTwoAdRenderings_whenRecreateBannerView_thenTwoAdsPresented {
    CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner criteo:self.criteo];

    [checker injectBidWithExpectedCreativeUrl:creativeUrl1];
    CRBidResponse *response = [self.criteo getBidResponseForAdUnit:banner];
    [checker.bannerView loadAdWithBidToken:response.bidToken];
    [self criteo_waitForExpectations:@[checker.bannerViewDidReceiveAdExpectation]];

    [checker resetExpectations];
    [checker resetBannerView];

    [checker injectBidWithExpectedCreativeUrl:creativeUrl2];
    response = [self.criteo getBidResponseForAdUnit:banner];
    [checker.bannerView loadAdWithBidToken:response.bidToken];
    [self criteo_waitForExpectations:@[checker.bannerViewDidReceiveAdExpectation]];
}

@end
