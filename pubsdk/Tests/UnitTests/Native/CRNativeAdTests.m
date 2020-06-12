//
//  CRNativeAdTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "CRNativeLoader.h"
#import "CRNativeAd+Internal.h"
#import "CRMediaDownloader.h"
#import "CRMediaContent+Internal.h"
#import "CR_NativeAssets+Testing.h"

@interface CRNativeAdTests : XCTestCase
@end

@implementation CRNativeAdTests

- (void)testNativeAdInitializationFromAssets {
    id mediaDownloader = OCMProtocolMock(@protocol(CRMediaDownloader));
    CRNativeLoader *loader = OCMClassMock([CRNativeLoader class]);
    OCMStub(loader.mediaDownloader).andReturn(mediaDownloader);

    CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
    CRNativeAd *ad = [[CRNativeAd alloc] initWithLoader:loader assets:assets];
    // Product
    CR_NativeProduct *product = assets.products[0];
    XCTAssertEqual(ad.title, product.title);
    XCTAssertEqual(ad.body, product.description);
    XCTAssertEqual(ad.price, product.price);
    XCTAssertEqual(ad.callToAction, product.callToAction);
    XCTAssertEqualObjects(ad.productMedia.url.absoluteString, product.image.url);
    XCTAssertEqual(ad.productMedia.size.width, product.image.width);
    XCTAssertEqual(ad.productMedia.size.height, product.image.height);
    XCTAssertEqual(ad.productMedia.mediaDownloader, mediaDownloader);
    // Advertiser
    CR_NativeAdvertiser *advertiser = assets.advertiser;
    XCTAssertEqual(ad.advertiserDescription, advertiser.description);
    XCTAssertEqual(ad.advertiserDomain, advertiser.domain);
    XCTAssertEqualObjects(ad.advertiserLogoMedia.url.absoluteString, advertiser.logoImage.url);
    XCTAssertEqual(ad.advertiserLogoMedia.mediaDownloader, mediaDownloader);
}

@end
