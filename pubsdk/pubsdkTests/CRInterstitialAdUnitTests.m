//
//  CRInterstitialAdUnitTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRInterstitialAdUnit.h"
#import "CRInterstitialAdUnit+Internal.h"
#import "CRAdUnit+Internal.h"

@interface CRInterstitialAdUnitTests : XCTestCase

@end

@implementation CRInterstitialAdUnitTests

- (void)testInterstitialAdUnitInitialization {
    NSString *expectedAdUnitId = @"expected";
    CRAdUnitType expectedType = CRAdUnitTypeInterstitial;
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:expectedAdUnitId];
    XCTAssertTrue([[interstitialAdUnit adUnitId] isEqual:expectedAdUnitId]);
    XCTAssertEqual([interstitialAdUnit adUnitType], expectedType);
}

- (void) testAdUnitSizesForInterstitial {
    CGSize tooSmall = CGSizeMake(300.0, 400.0);
    CGSize size = [CRInterstitialAdUnit interstitialSizeForCurrentScreenOrientation:tooSmall];
    CGSize expectedSize = CGSizeMake(320.0, 480.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize tooLarge = CGSizeMake(700.0, 900.0);
    size = [CRInterstitialAdUnit interstitialSizeForCurrentScreenOrientation:tooLarge];
    expectedSize = CGSizeMake(640.0, 360.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhoneX = CGSizeMake(375.0, 812.0);
    size = [CRInterstitialAdUnit interstitialSizeForCurrentScreenOrientation:iPhoneX];
    expectedSize = CGSizeMake(360.0, 640.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhone8PlusAnd7Plus = CGSizeMake(736.0, 414.0); //landscape
    size = [CRInterstitialAdUnit interstitialSizeForCurrentScreenOrientation:iPhone8PlusAnd7Plus];
    expectedSize = CGSizeMake(640.0, 360.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhone8And7And6 = CGSizeMake(375.0, 667.0);
    size = [CRInterstitialAdUnit interstitialSizeForCurrentScreenOrientation:iPhone8And7And6];
    expectedSize = CGSizeMake(360.0, 640.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);

    CGSize iPhoneSE = CGSizeMake(320.0, 568.0);
    size = [CRInterstitialAdUnit interstitialSizeForCurrentScreenOrientation:iPhoneSE];
    expectedSize = CGSizeMake(320.0, 480.0);
    XCTAssertTrue(size.width == expectedSize.width);
    XCTAssertTrue(size.height == expectedSize.height);
}

@end
