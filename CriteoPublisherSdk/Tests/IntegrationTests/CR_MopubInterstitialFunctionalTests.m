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

- (void)test_givenInterstitialWithBadAdUnitId_whenEnrichAdObject_thenRequestKeywordsDoNotChange {
  CRInterstitialAdUnit *interstitial = [CR_TestAdUnits randomInterstitial];
  [self initCriteoWithAdUnits:@[ interstitial ]];
  MPInterstitialAdController *interstitialAdController = [[MPInterstitialAdController alloc] init];
  interstitialAdController.keywords = initialMopubKeywords;

  [self enrichAdObject:interstitialAdController forAdUnit:interstitial];

  XCTAssertEqualObjects(initialMopubKeywords, interstitialAdController.keywords);
}

- (void)test_givenInterstitialWithGoodAdUnitId_whenEnrichAdObject_thenRequestKeywordsUpdated {
  CRInterstitialAdUnit *interstitial = [CR_TestAdUnits demoInterstitial];
  [self initCriteoWithAdUnits:@[ interstitial ]];
  MPInterstitialAdController *interstitialAdController = [[MPInterstitialAdController alloc] init];
  interstitialAdController.keywords = initialMopubKeywords;
  CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;
  CR_CdbBid *bid = [dependencyProvider.cacheManager
      getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:interstitial]];

  [self enrichAdObject:interstitialAdController forAdUnit:interstitial];

  CR_AssertMopubKeywordContainsCriteoBid(interstitialAdController.keywords, initialMopubKeywords,
                                         bid.displayUrl);
}

- (void)test_givenValidInterstitial_whenLoading_thenMopubViewContainsCreative {
  CRInterstitialAdUnit *interstitialAdUnit = [CR_TestAdUnits preprodInterstitial];
  [self initCriteoWithAdUnits:@[ interstitialAdUnit ]];

  MPInterstitialAdController *interstitial = [MPInterstitialAdController
      interstitialAdControllerForAdUnitId:CR_TestAdUnits.mopubInterstitialAdUnitId];
  [self enrichAdObject:interstitial forAdUnit:interstitialAdUnit];

  CR_MopubCreativeViewChecker *viewChecker =
      [[CR_MopubCreativeViewChecker alloc] initWithInterstitial:interstitial];

  [viewChecker initMopubSdkAndRenderAd:interstitial];

  BOOL renderedProperly = [viewChecker waitAdCreativeRendered];
  XCTAssertTrue(renderedProperly);
}

@end
