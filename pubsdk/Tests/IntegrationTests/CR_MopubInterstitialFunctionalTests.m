//
//  CR_MopubIntegrationFunctionalTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 03/12/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CRInterstitialAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertMopub.h"
#import "Criteo+Internal.h"
#import "CR_BidManagerBuilder.h"
#import "CR_AdUnitHelper.h"
#import <MoPub.h>

static NSString *initialMopubKeywords = @"key1:value1,key2:value2";

@interface CR_MopubInterstitialFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_MopubInterstitialFunctionalTests

- (void)test_givenInterstitialWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
    CRInterstitialAdUnit *interstitial = [CR_TestAdUnits randomInterstitial];
    [self initCriteoWithAdUnits:@[interstitial]];
    MPInterstitialAdController *interstitialAdController = [[MPInterstitialAdController alloc] init];
    interstitialAdController.keywords = initialMopubKeywords;

    [self.criteo setBidsForRequest:interstitialAdController withAdUnit:interstitial];

    XCTAssertEqualObjects(initialMopubKeywords, interstitialAdController.keywords);
}

- (void)test_givenInterstitialWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
    CRInterstitialAdUnit *interstitial = [CR_TestAdUnits demoInterstitial];
    [self initCriteoWithAdUnits:@[interstitial]];
    MPInterstitialAdController *interstitialAdController = [[MPInterstitialAdController alloc] init];
    interstitialAdController.keywords = initialMopubKeywords;
    CR_BidManagerBuilder *builder = [self.criteo bidManagerBuilder];
    CR_CdbBid *bid = [builder.cacheManager getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:interstitial]];

    [self.criteo setBidsForRequest:interstitialAdController withAdUnit:interstitial];

    CR_AssertMopubKeywordContainsCriteoBid(interstitialAdController.keywords, initialMopubKeywords, bid.displayUrl);
}

@end
