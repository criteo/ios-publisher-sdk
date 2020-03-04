//
//  CR_CdbCallsIntegrationTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 02/12/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertDfp.h"
#import "CR_NativeAssets.h"
#import "CR_TargetingKeys.h"
#import "NSString+CR_Url.h"
#import "CR_DfpCreativeViewChecker.h"
@import GoogleMobileAds;

@interface CR_DfpNativeFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_DfpNativeFunctionalTests

- (void)test_givenNativeWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
    CRNativeAdUnit *native = [CR_TestAdUnits randomNative];
    [self initCriteoWithAdUnits:@[native]];
    DFPRequest *dfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:dfpRequest withAdUnit:native];

    XCTAssertNil(dfpRequest.customTargeting);
}

- (void)test_givenNativeWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
    CRNativeAdUnit *native = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[native]];
    DFPRequest *dfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:dfpRequest withAdUnit:native];

    CR_NativeAssets *assets = [self _createNativeAssets];
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

    XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvName]], advertiser.description);
    XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvDomain]], advertiser.domain);
    XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvLogoUrl]], advertiser.logoImage.url);
    XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnAdvUrl]], advertiser.logoClickUrl);

    XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnPrUrl]], privacy.optoutClickUrl);
    XCTAssertEqualObjects([self _decode:targeting[CR_TargetingKey_crtnPrImageUrl]], privacy.optoutImageUrl);

    XCTAssertEqualObjects([self _decode:targeting[[self _crtnPixUrl:0]]], assets.impressionPixels[0]);
    XCTAssertEqualObjects([self _decode:targeting[[self _crtnPixUrl:1]]], assets.impressionPixels[1]);

    NSString *pixelCount = [NSString stringWithFormat:@"%@", @(assets.impressionPixels.count)];
    XCTAssertEqualObjects(targeting[CR_TargetingKey_crtnPixCount], pixelCount);
}

- (void)test_givenValidNative_whenLoadingNative_thenDfpViewContainsNativeCreative {
    CRNativeAdUnit *bannerAdUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[bannerAdUnit]];
    DFPRequest *bannerDfpRequest = [[DFPRequest alloc] init];

    CR_DfpCreativeViewChecker *dfpViewChecker = [[CR_DfpCreativeViewChecker alloc] initWithBannerWithSize:kGADAdSizeFluid
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
    return [NSString decodeDfpCompatibleString:value];
}

- (CR_NativeAssets *)_createNativeAssets {
    NSError *e = nil;
    NSURL *jsonURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"NativeAssetsFromCdb" withExtension:@"json"];
    NSString *jsonText = [NSString stringWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&e];
    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    return [[CR_NativeAssets alloc] initWithDict:dictionary];
}

@end
