//
//  CR_MopubIntegrationFunctionalTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 03/12/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CRBannerAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "MPClasses.h"
#import "CR_TestAdUnits.h"

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

    [self.criteo setBidsForRequest:adView withAdUnit:banner];

    [self assertMopubKeywordsUpdated:adView.keywords andStillHaveInitialKeywords:initialMopubKeywords];
}

@end
