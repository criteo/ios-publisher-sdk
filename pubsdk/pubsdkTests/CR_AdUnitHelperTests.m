//
//  CR_AdUnitHelperTests.m
//  pubsdkTests
//
//  Created by Sneha Pathrose on 5/31/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRBannerAdUnit.h"
#import "CRInterstitialAdUnit.h"
#import "CRNativeAdUnit.h"
#import "CR_DeviceInfo.h"
#import "CR_AdUnitHelper.h"

@interface CR_AdUnitHelperTests : XCTestCase

@end

@implementation CR_AdUnitHelperTests

- (void)testBannerAdUnitsToCacheAdUnits {
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0)];
    CR_CacheAdUnit *expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0) adUnitType:CRAdUnitTypeBanner];
    XCTAssertTrue([expectedCacheAdUnit isEqual:[[CR_AdUnitHelper cacheAdUnitsForAdUnits:@[bannerAdUnit]] objectAtIndex:0]]);
}

- (void)testInterstitialAdUnitsToCacheAdUnits {
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"1234"];
    CR_CacheAdUnit *expectedInterstitialCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                                                                    size:CGSizeMake(360.0, 640.0) adUnitType:CRAdUnitTypeInterstitial];
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234"
                                                                 size:CGSizeMake(320.0, 50.0)];
    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(400.0, 480.0));
    CR_CacheAdUnitArray *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:@[bannerAdUnit, interstitialAdUnit]];
    XCTAssertTrue([expectedInterstitialCacheAdUnit isEqual:[cacheAdUnits objectAtIndex:1]]);
}

- (void)testAdUnitToCacheAdUnit {
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"1234"];
    CR_CacheAdUnit *expectedInterstitialCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(360.0, 640.0) adUnitType:CRAdUnitTypeInterstitial];
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0)];
    CR_CacheAdUnit *expectedBannerCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0) adUnitType:CRAdUnitTypeBanner];
    CRNativeAdUnit *nativeAdUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"1234"];
    CR_CacheAdUnit *expectedNativeCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(2.0, 2.0) adUnitType:CRAdUnitTypeNative];
    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(400.0, 700.0));
    // for banner, interstitial and native
    XCTAssertTrue([expectedBannerCacheAdUnit isEqual:[CR_AdUnitHelper cacheAdUnitForAdUnit:bannerAdUnit]]);
    XCTAssertTrue([expectedInterstitialCacheAdUnit isEqual:[CR_AdUnitHelper cacheAdUnitForAdUnit:interstitialAdUnit]]);
    XCTAssertTrue([expectedNativeCacheAdUnit isEqual:[CR_AdUnitHelper cacheAdUnitForAdUnit:nativeAdUnit]]);
}

- (void) testAdUnitSizesForInterstitial {
    CGSize tooSmall = CGSizeMake(300.0, 400.0);
    CGSize size = [CR_AdUnitHelper closestSupportedInterstitialSize:tooSmall];
    CGSize expectedSize = CGSizeMake(320.0, 480.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize tooLarge = CGSizeMake(700.0, 900.0);
    size = [CR_AdUnitHelper closestSupportedInterstitialSize:tooLarge];
    expectedSize = CGSizeMake(640.0, 360.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhoneX = CGSizeMake(375.0, 812.0);
    size = [CR_AdUnitHelper closestSupportedInterstitialSize:iPhoneX];
    expectedSize = CGSizeMake(360.0, 640.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhone8PlusAnd7Plus = CGSizeMake(736.0, 414.0); //landscape
    size = [CR_AdUnitHelper closestSupportedInterstitialSize:iPhone8PlusAnd7Plus];
    expectedSize = CGSizeMake(640.0, 360.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhone8And7And6 = CGSizeMake(375.0, 667.0);
    size = [CR_AdUnitHelper closestSupportedInterstitialSize:iPhone8And7And6];
    expectedSize = CGSizeMake(360.0, 640.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhoneSE = CGSizeMake(320.0, 568.0);
    size = [CR_AdUnitHelper closestSupportedInterstitialSize:iPhoneSE];
    expectedSize = CGSizeMake(320.0, 480.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);
}

- (void) testCacheAdUnitForCurrentOrientation {
    CGSize expectedSize = CGSizeMake(480.0, 320.0);
    CR_CacheAdUnit *expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testCacheAdUnit" size:expectedSize adUnitType:CRAdUnitTypeInterstitial];

    CR_CacheAdUnit *resultingCacheAdUnit = [CR_AdUnitHelper interstitialCacheAdUnitForAdUnitId:@"testCacheAdUnit"
                                                                                   screenSize:CGSizeMake(500.0, 330.0)];
    XCTAssertTrue([expectedCacheAdUnit isEqual:resultingCacheAdUnit]);
}

- (void)testNativeAdUnitToCacheAdUnit {
    CRNativeAdUnit *nativeAdUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"1234"];
    CR_CacheAdUnit *expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(2.0, 2.0) adUnitType:CRAdUnitTypeNative];
    XCTAssertTrue([expectedCacheAdUnit isEqual:[[CR_AdUnitHelper cacheAdUnitsForAdUnits:@[nativeAdUnit]] objectAtIndex:0]]);
}

@end
