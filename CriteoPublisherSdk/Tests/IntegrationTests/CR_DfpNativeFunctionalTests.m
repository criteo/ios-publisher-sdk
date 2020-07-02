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
#import "Criteo.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_TargetingKeys.h"
#import "NSString+CriteoUrl.h"
#import "CR_DfpCreativeViewChecker.h"
#import "CR_NativeAssets+Testing.h"
@import GoogleMobileAds;

@interface CR_DfpNativeFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_DfpNativeFunctionalTests

- (void)test_givenNativeWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
  CRNativeAdUnit *native = [CR_TestAdUnits randomNative];
  [self initCriteoWithAdUnits:@[ native ]];
  DFPRequest *dfpRequest = [[DFPRequest alloc] init];

  [self.criteo setBidsForRequest:dfpRequest withAdUnit:native];

  XCTAssertNil(dfpRequest.customTargeting);
}

- (void)test_givenNativeWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
  CRNativeAdUnit *native = [CR_TestAdUnits preprodNative];
  [self initCriteoWithAdUnits:@[ native ]];
  DFPRequest *dfpRequest = [[DFPRequest alloc] init];

  [self.criteo setBidsForRequest:dfpRequest withAdUnit:native];

  CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
  CR_NativeProduct *product = assets.products[0];
  CR_NativeAdvertiser *advertiser = assets.advertiser;
  CR_NativePrivacy *privacy = assets.privacy;

  NSDictionary *targeting = dfpRequest.customTargeting;

  XCTAssertNotNil(targeting[CR_TargetingKey_crtCpm]);
  XCTAssertNil(targeting[CR_TargetingKey_crtDfpDisplayUrl]);

  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnTitle]], product.title);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnDesc]], product.description);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnImageUrl]], product.image.url);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnPrice]], product.price);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnClickUrl]], product.clickUrl);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnCta]], product.callToAction);

  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvName]],
                        advertiser.description);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvDomain]], advertiser.domain);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvLogoUrl]],
                        advertiser.logoImage.url);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvUrl]],
                        advertiser.logoClickUrl);

  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnPrUrl]],
                        privacy.optoutClickUrl);
  XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnPrImageUrl]],
                        privacy.optoutImageUrl);

  XCTAssertEqualObjects([self _decode:targeting[[self _crtnPixUrl:0]]], assets.impressionPixels[0]);
  XCTAssertEqualObjects([self _decode:targeting[[self _crtnPixUrl:1]]], assets.impressionPixels[1]);

  NSString *pixelCount = [NSString stringWithFormat:@"%@", @(assets.impressionPixels.count)];
  XCTAssertEqualObjects(targeting[CR_TargetingKey_crtnPixCount], pixelCount);
}

- (void)test_givenValidNative_whenLoadingNative_thenDfpViewContainsNativeCreative {
  CRNativeAdUnit *bannerAdUnit = [CR_TestAdUnits preprodNative];
  [self initCriteoWithAdUnits:@[ bannerAdUnit ]];
  DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

  CR_DfpCreativeViewChecker *dfpViewChecker =
      [[CR_DfpCreativeViewChecker alloc] initWithBannerWithSize:kGADAdSizeFluid
                                                   withAdUnitId:CR_TestAdUnits.dfpNativeId];

  [self.criteo setBidsForRequest:bannerDfpRequest withAdUnit:bannerAdUnit];
  [dfpViewChecker.dfpBannerView loadRequest:bannerDfpRequest];

  BOOL renderedProperly = [dfpViewChecker waitAdCreativeRendered];
  XCTAssertTrue(renderedProperly);
}

#pragma mark - Private methods

- (NSString *)_crtnPixUrl:(int)index {
  return [NSString stringWithFormat:@"%@%d", CR_TargetingKey_crtnPixUrl, index];
}

- (NSString *)_decode:(NSString *)value {
  return [NSString cr_decodeDfpCompatibleString:value];
}

@end
