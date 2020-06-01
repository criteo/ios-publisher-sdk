//
//  CR_MopubIntegrationFunctionalTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CRInterstitialAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertMopub.h"
#import "Criteo+Internal.h"
#import "Criteo+Testing.h"
#import "CR_DependencyProvider.h"
#import "CR_AdUnitHelper.h"
#import "CR_MopubCreativeViewChecker.h"
#import "CR_CacheManager.h"
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
    CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;
    CR_CdbBid *bid = [dependencyProvider.cacheManager getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:interstitial]];

    [self.criteo setBidsForRequest:interstitialAdController withAdUnit:interstitial];

    CR_AssertMopubKeywordContainsCriteoBid(interstitialAdController.keywords, initialMopubKeywords, bid.displayUrl);
}

- (void)test_givenValidInterstitial_whenLoading_thenMopubViewContainsCreative {
    CRInterstitialAdUnit *interstitialAdUnit = [CR_TestAdUnits preprodInterstitial];
    [self initCriteoWithAdUnits:@[interstitialAdUnit]];

    MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:CR_TestAdUnits.mopubInterstitialAdUnitId];
    [self.criteo setBidsForRequest:interstitial withAdUnit:interstitialAdUnit];

    CR_MopubCreativeViewChecker *viewChecker = [[CR_MopubCreativeViewChecker alloc] initWithInterstitial:interstitial];

    [viewChecker initMopubSdkAndRenderAd:interstitial];

    BOOL renderedProperly = [viewChecker waitAdCreativeRendered];
    XCTAssertTrue(renderedProperly);
}

@end
