//
//  CR_CdbCallsIntegrationTests.m
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
#import "Criteo+Testing.h"
#import "CRInterstitialAdUnit.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertDfp.h"
#import "CR_DependencyProvider.h"
#import "CR_AdUnitHelper.h"
#import "Criteo+Internal.h"
#import "XCTestCase+Criteo.h"
#import "CR_DfpCreativeViewChecker.h"
#import "CR_DeviceInfoMock.h"
#import "NSString+CriteoUrl.h"
#import "CR_TargetingKeys.h"
#import "CR_CacheManager.h"
@import GoogleMobileAds;

@interface CR_DfpInterstitialFunctionalTests : CR_IntegrationsTestBase

@property(strong, nonatomic) CRInterstitialAdUnit *preprodAdUnit;
@property(strong, nonatomic) DFPRequest *request;

@end

@implementation CR_DfpInterstitialFunctionalTests

- (void)setUp {
  self.preprodAdUnit = [CR_TestAdUnits preprodInterstitial];
  self.request = [[DFPRequest alloc] init];
}

- (void)test_givenInterstitialWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
  CRInterstitialAdUnit *interstitial = [CR_TestAdUnits randomInterstitial];
  [self initCriteoWithAdUnits:@[ interstitial ]];
  DFPRequest *interstitialDfpRequest = [[DFPRequest alloc] init];

  [self.criteo setBidsForRequest:interstitialDfpRequest withAdUnit:interstitial];

  XCTAssertNil(interstitialDfpRequest.customTargeting);
}

- (void)test_givenInterstitialWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
  CRInterstitialAdUnit *interstitial = [CR_TestAdUnits demoInterstitial];
  [self initCriteoWithAdUnits:@[ interstitial ]];
  DFPRequest *interstitialDfpRequest = [[DFPRequest alloc] init];

  [self.criteo setBidsForRequest:interstitialDfpRequest withAdUnit:interstitial];

  CR_AssertDfpCustomTargetingContainsCriteoBid(interstitialDfpRequest.customTargeting);
}

- (void)test_givenDfpRequest_whenSetBid_thenDisplayUrlEncodedProperly {
  CRInterstitialAdUnit *interstitialAdUnit = [CR_TestAdUnits demoInterstitial];
  [self initCriteoWithAdUnits:@[ interstitialAdUnit ]];
  CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;
  CR_CdbBid *bid = [dependencyProvider.cacheManager
      getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:interstitialAdUnit]];
  DFPRequest *interstitialDfpRequest = [[DFPRequest alloc] init];

  [self.criteo setBidsForRequest:interstitialDfpRequest withAdUnit:interstitialAdUnit];
  NSString *encodedUrl = interstitialDfpRequest.customTargeting[CR_TargetingKey_crtDfpDisplayUrl];
  NSString *decodedUrl = [NSString cr_decodeDfpCompatibleString:encodedUrl];

  CGSize screenSize = dependencyProvider.deviceInfo.screenSize;
  NSString *expectedDisplayUrl =
      [NSString stringWithFormat:@"%@?wvw=%d&wvh=%d", bid.displayUrl, (int)screenSize.width,
                                 (int)screenSize.height];

  XCTAssertEqualObjects(expectedDisplayUrl, decodedUrl);
}

- (void)test_givenValidInterstitial_whenLoadingDfpInterstitial_thenDfpViewContainsCreative {
  CRInterstitialAdUnit *interstitialAdUnit = [CR_TestAdUnits preprodInterstitial];
  [self initCriteoWithAdUnits:@[ interstitialAdUnit ]];
  DFPRequest *dfpRequest = [[DFPRequest alloc] init];
  DFPInterstitial *dfpInterstitial =
      [[DFPInterstitial alloc] initWithAdUnitID:CR_TestAdUnits.dfpInterstitialAdUnitId];
  CR_DfpCreativeViewChecker *dfpViewChecker =
      [[CR_DfpCreativeViewChecker alloc] initWithInterstitial:dfpInterstitial];

  [self.criteo setBidsForRequest:dfpRequest withAdUnit:interstitialAdUnit];
  [dfpInterstitial loadRequest:dfpRequest];

  BOOL renderedProperly = [dfpViewChecker waitAdCreativeRendered];
  XCTAssertTrue(renderedProperly);
}

- (void)test_invalidInterstitial_whenLoadingDfpInterstitial_thenDfpViewDoesNOTContainCreative {
  CRInterstitialAdUnit *interstitialAdUnitRandom = [CR_TestAdUnits randomInterstitial];
  CRInterstitialAdUnit *interstitialAdUnit = [CR_TestAdUnits preprodInterstitial];
  [self initCriteoWithAdUnits:@[ interstitialAdUnit ]];
  DFPRequest *dfpRequest = [[DFPRequest alloc] init];
  DFPInterstitial *dfpInterstitial =
      [[DFPInterstitial alloc] initWithAdUnitID:CR_TestAdUnits.dfpInterstitialAdUnitId];
  CR_DfpCreativeViewChecker *dfpViewChecker =
      [[CR_DfpCreativeViewChecker alloc] initWithInterstitial:dfpInterstitial];

  [self.criteo setBidsForRequest:dfpRequest withAdUnit:interstitialAdUnitRandom];
  [dfpInterstitial loadRequest:dfpRequest];

  BOOL renderedProperly = [dfpViewChecker waitAdCreativeRendered];
  XCTAssertFalse(renderedProperly);
}

#pragma mark - Header Bidding Size

#define CRAssertCrtSizeOnSetBidRequest(_crtSize)                            \
  do {                                                                      \
    [self recordFailureOnBidRequestCrtSizeString:_crtSize atLine:__LINE__]; \
  } while (0);

- (void)test_givenAdUnit_whenSetBidsForRequest_thenRequestKeywordsContainsCrtSize {
  [self initCriteoWithAdUnits:@[ self.preprodAdUnit ]];
  self.deviceInfo.mock_screenSize = (CGSize){320.f, 320.f};

  CRAssertCrtSizeOnSetBidRequest(@"320x480");
}

- (void)test_givenAdUnitInLandscape_whenSetBidsForRequest_thenRequestKeywordsContainsCrtSize {
  [self initCriteoWithAdUnits:@[ self.preprodAdUnit ]];
  self.deviceInfo.mock_screenSize = (CGSize){320.f, 320.f};
  self.deviceInfo.mock_isInPortrait = NO;

  CRAssertCrtSizeOnSetBidRequest(@"480x320");
}

- (void)test_givenAdUnitOnPad_whenSetBidsForRequest_thenRequestKeywordsContainsCrtSize {
  [self initCriteoWithAdUnits:@[ self.preprodAdUnit ]];
  self.deviceInfo.mock_screenSize = (CGSize){842.f, 1024.f};
  self.deviceInfo.mock_isPhone = NO;

  CRAssertCrtSizeOnSetBidRequest(@"768x1024");
}

- (void)test_givenAdUnitOnPadInLandscape_whenSetBidsForRequest_thenRequestKeywordsContainsCrtSize {
  [self initCriteoWithAdUnits:@[ self.preprodAdUnit ]];
  self.deviceInfo.mock_screenSize = (CGSize){2048.f, 768.f};
  self.deviceInfo.mock_isPhone = NO;
  self.deviceInfo.mock_isInPortrait = NO;

  CRAssertCrtSizeOnSetBidRequest(@"1024x768");
}

- (void)test_givenAdUnitOnSmallPad_whenSetBidsForRequest_thenRequestKeywordsContainsCrtSize {
  [self initCriteoWithAdUnits:@[ self.preprodAdUnit ]];
  self.deviceInfo.mock_screenSize = (CGSize){1024.f, 512.f};
  self.deviceInfo.mock_isPhone = NO;

  CRAssertCrtSizeOnSetBidRequest(@"320x480");
}

#pragma mark - Private

- (CR_DeviceInfoMock *)deviceInfo {
  return (CR_DeviceInfoMock *)self.criteo.dependencyProvider.deviceInfo;
}

- (void)recordFailureOnBidRequestCrtSizeString:(NSString *)crtSizeString
                                        atLine:(NSUInteger)lineNumber {
  [self.criteo setBidsForRequest:self.request withAdUnit:self.preprodAdUnit];

  NSString *actualCrtSize = self.request.customTargeting[@"crt_size"];
  if (![crtSizeString isEqualToString:actualCrtSize]) {
    NSString *desc =
        [[NSString alloc] initWithFormat:@"%@ (crt_size) should be equal to %@, %@", actualCrtSize,
                                         crtSizeString, self.request.customTargeting];
    NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    [self recordFailureWithDescription:desc inFile:file atLine:lineNumber expected:YES];
  }
}

@end
