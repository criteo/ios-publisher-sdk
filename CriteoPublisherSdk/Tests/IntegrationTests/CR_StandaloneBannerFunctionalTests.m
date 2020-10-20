//
//  CR_StandaloneBannerFunctionalTests.m
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

#import <XCTest/XCTestCase.h>
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CRBannerView.h"
#import "XCTestCase+Criteo.h"
#import "CR_CreativeViewChecker.h"

static NSString *creativeUrl1 = @"www.criteo.com";
static NSString *creativeUrl2 = @"www.apple.com";

@interface CR_StandaloneBannerFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_StandaloneBannerFunctionalTests

- (void)test_givenBannerWithBadAdUnitId_whenLoadAd_thenDelegateReceiveFail {
  CRBannerAdUnit *banner = [CR_TestAdUnits randomBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];

  CR_CreativeViewChecker *viewChecker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                                criteo:self.criteo];

  [viewChecker.bannerView loadAd];

  [self cr_waitForExpectations:@[ viewChecker.bannerViewFailToReceiveAdExpectation ]];
}

- (void)test_givenBannerWithGoodAdUnitId_whenLoadAd_thenDelegateInvoked {
  CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *viewChecker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                                criteo:self.criteo];

  [viewChecker.bannerView loadAd];

  [self cr_waitForExpectations:@[ viewChecker.bannerViewDidReceiveAdExpectation ]];
}

// Note this test relies on WireMock, for more information see wiremock/wiremock.md
- (void)test_givenBannerWithGoodAdUnitId_whenLoadAd_thenAdIsLoadedProperly {
  CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *viewChecker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                                criteo:self.criteo];

  [viewChecker.bannerView loadAd];

  [self cr_waitForExpectations:@[ viewChecker.adCreativeRenderedExpectation ]];
}

- (void)test_givenTwoAdRenderings_whenReuseSameBannerView_thenTwoAdsPresented {
  CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *viewChecker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                                criteo:self.criteo];

  [viewChecker injectBidWithExpectedCreativeUrl:creativeUrl1];
  [viewChecker.bannerView loadAd];
  [self cr_waitForExpectations:@[ viewChecker.adCreativeRenderedExpectation ]];

  [viewChecker resetExpectations];

  [viewChecker injectBidWithExpectedCreativeUrl:creativeUrl2];
  [viewChecker.bannerView loadAd];
  [self cr_waitForExpectations:@[ viewChecker.adCreativeRenderedExpectation ]];
}

- (void)test_givenTwoAdRenderings_whenRecreateBannerView_thenTwoAdsPresented {
  CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *viewChecker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                                criteo:self.criteo];

  [viewChecker injectBidWithExpectedCreativeUrl:creativeUrl1];
  [viewChecker.bannerView loadAd];
  [self cr_waitForExpectations:@[ viewChecker.adCreativeRenderedExpectation ]];

  [viewChecker resetExpectations];
  [viewChecker resetBannerView];

  [viewChecker injectBidWithExpectedCreativeUrl:creativeUrl2];
  [viewChecker.bannerView loadAd];
  [self cr_waitForExpectations:@[ viewChecker.adCreativeRenderedExpectation ]];
}

@end
