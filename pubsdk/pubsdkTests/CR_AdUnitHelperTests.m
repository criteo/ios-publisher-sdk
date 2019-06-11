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
#import "CR_DeviceInfo.h"
#import "CR_AdUnitHelper.h"

@interface CR_AdUnitHelperTests : XCTestCase

@end

@implementation CR_AdUnitHelperTests

- (void)testBannerAdUnitsToCacheAdUnits {
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0)];
    CR_CacheAdUnit *expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0)];
    XCTAssertTrue([expectedCacheAdUnit isEqual:[[CR_AdUnitHelper cacheAdUnitsForAdUnits:@[bannerAdUnit]
                                                                             deviceInfo:[CR_DeviceInfo new]] objectAtIndex:0]]);
}

- (void)testInterstitialAdUnitsToCacheAdUnits {
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"1234"];
    CR_CacheAdUnit *expectedCacheAdUnitPortrait = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                                                                    size:CGSizeMake(360.0, 640.0)];
    CR_CacheAdUnit *expectedCacheAdUnitLandscape = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                                                                     size:CGSizeMake(480.0, 320.0)];
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234"
                                                                 size:CGSizeMake(320.0, 50.0)];
    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo screenSize]).andReturn(CGSizeMake(400.0, 480.0));
    NSArray<CR_CacheAdUnit *> *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:@[bannerAdUnit, interstitialAdUnit]
                                                                          deviceInfo:mockDeviceInfo];
    XCTAssertTrue([expectedCacheAdUnitPortrait isEqual:[cacheAdUnits objectAtIndex:1]]);
    XCTAssertTrue([expectedCacheAdUnitLandscape isEqual:[cacheAdUnits objectAtIndex:2]]);
}

- (void)testAdUnitToCacheAdUnit {
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"1234"];
    CR_CacheAdUnit *expectedInterstitialCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(360.0, 640.0)];
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0)];
    CR_CacheAdUnit *expectedBannerCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234" size:CGSizeMake(320.0, 50.0)];
    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo screenSize]).andReturn(CGSizeMake(400.0, 700.0));
    // for banner and interstitial
    XCTAssertTrue([expectedBannerCacheAdUnit isEqual:[CR_AdUnitHelper cacheAdUnitForAdUnit:bannerAdUnit
                                                                                deviceInfo:mockDeviceInfo]]);
    XCTAssertTrue([expectedInterstitialCacheAdUnit isEqual:[CR_AdUnitHelper cacheAdUnitForAdUnit:interstitialAdUnit
                                                                                      deviceInfo:mockDeviceInfo]]);
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
    CR_CacheAdUnit *expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testCacheAdUnit" size:expectedSize];

    CR_CacheAdUnit *resultingCacheAdUnit = [CR_AdUnitHelper interstitialCacheAdUnitForAdUnitId:@"testCacheAdUnit"
                                                                                   screenSize:CGSizeMake(500.0, 330.0)];
    XCTAssertTrue([expectedCacheAdUnit isEqual:resultingCacheAdUnit]);
}

@end
