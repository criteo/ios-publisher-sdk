//
//  CRInHouseFunctionalTests.m
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

#import "XCTestCase+Criteo.h"
#import "Criteo.h"
#import "Criteo+Testing.h"
#import "CRBannerView.h"
#import "CRInterstitial.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_CreativeViewChecker.h"
#import "CR_TestAdUnits.h"
#import "CRContextData.h"

static NSString *creativeUrl1 = @"www.criteo.com";
static NSString *creativeUrl2 = @"www.apple.com";

@interface CR_InHouseFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_InHouseFunctionalTests

#pragma mark - Banners

- (void)test_givenBanner_whenLoadBid_thenBannerReceiveAd {
  CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                            criteo:self.criteo];

  [self.criteo loadBidForAdUnit:banner
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.bannerView loadAdWithBid:bid];
                }];

  [self cr_waitForExpectations:@[ checker.didReceiveAdExpectation ]];
}

- (void)test_givenBannerWithBadAdUnitId_whenLoadBid_thenBannerFailToReceiveAd {
  CRBannerAdUnit *banner = [CR_TestAdUnits randomBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                            criteo:self.criteo];

  [self.criteo loadBidForAdUnit:banner
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.bannerView loadAdWithBid:bid];
                }];

  [self cr_waitForExpectations:@[ checker.failToReceiveAdExpectation ]];
}

- (void)test_givenBanner_whenLoadBidTwice_thenBannerFailToReceiveAd {
  CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                            criteo:self.criteo];
  __block CRBid *bidToReuse = nil;
  [self.criteo loadBidForAdUnit:banner
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.bannerView loadAdWithBid:bid];
                  bidToReuse = bid;
                }];
  [self cr_waitForExpectations:@[ checker.didReceiveAdExpectation ]];
  checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner criteo:self.criteo];

  [checker.bannerView loadAdWithBid:bidToReuse];

  [self cr_waitForExpectations:@[ checker.failToReceiveAdExpectation ]];
}

- (void)test_givenTwoAdRenderings_whenReuseSameBannerView_thenTwoAdsPresented {
  CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                            criteo:self.criteo];

  [checker injectBidWithExpectedCreativeUrl:creativeUrl2];
  [self.criteo loadBidForAdUnit:banner
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.bannerView loadAdWithBid:bid];
                }];
  [self cr_waitForExpectations:@[ checker.didReceiveAdExpectation ]];

  [checker resetExpectations];

  [checker injectBidWithExpectedCreativeUrl:creativeUrl2];
  [self.criteo loadBidForAdUnit:banner
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.bannerView loadAdWithBid:bid];
                }];
  [self cr_waitForExpectations:@[ checker.didReceiveAdExpectation ]];
}

- (void)test_givenTwoAdRenderings_whenRecreateBannerView_thenTwoAdsPresented {
  CRBannerAdUnit *banner = [CR_TestAdUnits preprodBanner320x50];
  [self initCriteoWithAdUnits:@[ banner ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:banner
                                                                            criteo:self.criteo];

  [checker injectBidWithExpectedCreativeUrl:creativeUrl1];
  [self.criteo loadBidForAdUnit:banner
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.bannerView loadAdWithBid:bid];
                }];
  [self cr_waitForExpectations:@[ checker.didReceiveAdExpectation ]];

  [checker resetExpectations];
  [checker resetBannerView];

  [checker injectBidWithExpectedCreativeUrl:creativeUrl2];
  [self.criteo loadBidForAdUnit:banner
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.bannerView loadAdWithBid:bid];
                }];
  [self cr_waitForExpectations:@[ checker.didReceiveAdExpectation ]];
}

#pragma mark - Interstitial

- (void)test_givenInterstitial_whenLoadBid_thenReceiveAd {
  CRInterstitialAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
  [self initCriteoWithAdUnits:@[ adUnit ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:adUnit
                                                                            criteo:self.criteo];
  [self.criteo loadBidForAdUnit:adUnit
                    withContext:CRContextData.new
                responseHandler:^(CRBid *bid) {
                  [checker.interstitial loadAdWithBid:bid];
                }];

  [self cr_waitForExpectations:@[ checker.adCreativeRenderedExpectation ]];
}

- (void)test_givenInterstitial_whenLoadWrongBid_thenFailToReceiveAd {
  CRInterstitialAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
  CRInterstitialAdUnit *orphan = [CR_TestAdUnits demoInterstitial];
  [self initCriteoWithAdUnits:@[ adUnit, orphan ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:adUnit
                                                                            criteo:self.criteo];

  [self.criteo loadBidForAdUnit:orphan
                    withContext:CRContextData.new
                responseHandler:^(CRBid *orphanBid) {
                  [checker.interstitial loadAdWithBid:orphanBid];
                }];

  [self cr_waitForExpectations:@[ checker.failToReceiveAdExpectation ]];
}

- (void)test_givenInterstitialLoadWrongBid_whenLoadGoodBid_thenReceiveAd {
  CRInterstitialAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
  CRInterstitialAdUnit *orphan = [CR_TestAdUnits demoInterstitial];
  [self initCriteoWithAdUnits:@[ adUnit, orphan ]];
  CR_CreativeViewChecker *checker = [[CR_CreativeViewChecker alloc] initWithAdUnit:adUnit
                                                                            criteo:self.criteo];
  [self.criteo loadBidForAdUnit:orphan
                    withContext:CRContextData.new
                responseHandler:^(CRBid *orphanBid) {
                  [checker.interstitial loadAdWithBid:orphanBid];
                }];

  [self cr_waitForExpectations:@[ checker.failToReceiveAdExpectation ]];
  [checker resetExpectations];

  [self.criteo loadBidForAdUnit:adUnit
                    withContext:CRContextData.new
                responseHandler:^(CRBid *goodBid) {
                  [checker.interstitial loadAdWithBid:goodBid];
                }];

  [self cr_waitForExpectations:@[ checker.failToReceiveAdExpectation ]];
}

#pragma mark - rewarded

- (void)test_givenRewarded_whenLoad_thenFailToReceiveAd {
  CRRewardedAdUnit *adUnit = [CR_TestAdUnits randomRewarded];
  self.criteo = [Criteo testing_criteoWithNetworkCaptor];
  [self.criteo testing_registerWithAdUnits:@[ adUnit ]];
  BOOL finished = [self.criteo testing_waitForRegisterHTTPResponses];
  XCTAssertFalse(
      finished,
      "There are no prefetch request issued as the adUnit type is only supported for GAM");
}

@end
