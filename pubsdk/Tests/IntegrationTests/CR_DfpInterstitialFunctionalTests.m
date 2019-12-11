//
//  CR_CdbCallsIntegrationTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 02/12/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CRInterstitialAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertDfp.h"
@import GoogleMobileAds;

@interface CR_DfpInterstitialFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_DfpInterstitialFunctionalTests

- (void)test_givenInterstitialWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
    CRInterstitialAdUnit *interstitial = [CR_TestAdUnits randomInterstitial];
    [self initCriteoWithAdUnits:@[interstitial]];
    DFPRequest *interstitialDfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:interstitialDfpRequest withAdUnit:interstitial];

    XCTAssertNil(interstitialDfpRequest.customTargeting);
}

- (void)test_givenInterstitialWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
    CRInterstitialAdUnit *interstitial = [CR_TestAdUnits demoInterstitial];
    [self initCriteoWithAdUnits:@[interstitial]];
    DFPRequest *interstitialDfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:interstitialDfpRequest withAdUnit:interstitial];

    CR_AssertDfpCustomTargetingContainsCriteoBid(interstitialDfpRequest.customTargeting);
}

@end
