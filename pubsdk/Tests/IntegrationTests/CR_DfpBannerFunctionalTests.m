//
//  CR_CdbCallsIntegrationTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 02/12/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CRBannerAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertDfp.h"
#import "Criteo+Internal.h"
#import "CR_BidManagerBuilder.h"
#import "CR_AdUnitHelper.h"
#import "XCTestCase+Criteo.h"
#import "CR_DfpBannerViewChecker.h"
#import "CR_DfpAdUnitIds.h"
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
}

- (void)test_givenDfpRequest_whenSetBid_thenDisplayUrlEncodedProperly {
    CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
    [self initCriteoWithAdUnits:@[banner]];
    CR_BidManagerBuilder *builder = [self.criteo bidManagerBuilder];
    CR_CdbBid *bid = [builder.cacheManager getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:banner]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:banner];
    NSString *decodedUrl = [self getDecodedDisplayUrlFromDfpRequestCustomTargeting:bannerDfpRequest.customTargeting];

    XCTAssertEqualObjects(bid.displayUrl, decodedUrl);
}

- (void)test_givenValidBanner_whenLoadingDfpBanner_thenDfpViewContainsCreative {
    CRBannerAdUnit *bannerAdUnit = [CR_TestAdUnits preprodBanner320x50];
    [self initCriteoWithAdUnits:@[bannerAdUnit]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];
    [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:bannerAdUnit];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect that banner is rendered."];
    CR_DfpBannerViewChecker *dfpBannerViewChecker = [[CR_DfpBannerViewChecker alloc] initWithExpectation:expectation];
    UIViewController *viewController = [self createRootViewControllerWithSize:CGSizeMake(320, 50)];
    DFPBannerView *dfpBannerView = [self createDfpBannerViewWithChecker:dfpBannerViewChecker andWithViewController: viewController];

    [dfpBannerView loadRequest:bannerDfpRequest];
    [viewController.view addSubview:dfpBannerView];

    [self criteo_waitForExpectations:@[expectation]];
}

#pragma mark - Private methods

- (DFPBannerView *)createDfpBannerViewWithChecker:(CR_DfpBannerViewChecker *)dfpBannerViewChecker
                            andWithViewController:(UIViewController *)viewController {
    DFPBannerView *dfpBannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    dfpBannerView.adUnitID = CR_DfpAdUnitIds.dfpBanner50AdUnitId;
    dfpBannerView.backgroundColor = [UIColor orangeColor];
    dfpBannerView.delegate = dfpBannerViewChecker;
    dfpBannerView.rootViewController = viewController;
    return dfpBannerView;
}

@end
