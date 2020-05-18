//
//  CRNativeAdTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_NativeAssets.h"
#import "CRNativeAd+Internal.h"
#import "CR_NativeAssetsTests.h"

@interface CRNativeAdTests : XCTestCase
@end

@implementation CRNativeAdTests

- (void)testNativeAdInitializationFromAssets {
    CR_NativeAssets *assets = [CR_NativeAssetsTests loadNativeAssets:@"NativeAssetsFromCdb"];
    CRNativeAd *ad = [[CRNativeAd alloc] initWithNativeAssets:assets];
    // Product
    CR_NativeProduct *product = assets.products[0];
    XCTAssertEqual(ad.title, product.title);
    XCTAssertEqual(ad.body, product.description);
    XCTAssertEqual(ad.price, product.price);
    XCTAssertEqual(ad.callToAction, product.callToAction);
    XCTAssertEqual(ad.productImageUrl, product.image.url);
    // Advertiser
    CR_NativeAdvertiser *advertiser = assets.advertiser;
    XCTAssertEqual(ad.advertiserDescription, advertiser.description);
    XCTAssertEqual(ad.advertiserDomain, advertiser.domain);
    XCTAssertEqual(ad.advertiserLogoImageUrl, advertiser.logoImage.url);
}

@end
