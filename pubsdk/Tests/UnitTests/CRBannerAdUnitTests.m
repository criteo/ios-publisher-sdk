//
//  CRBannerAdUnitTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"

@interface CRBannerAdUnitTests : XCTestCase

@end

@implementation CRBannerAdUnitTests

- (void)testBannerAdUnitInitialization {
    NSString *expectedAdUnitId = @"expected";
    CRAdUnitType expectedType = CRAdUnitTypeBanner;
    CGSize expectedSize = CGSizeMake(320.0, 50.0);
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:expectedAdUnitId
                                                                 size:expectedSize];
    XCTAssertTrue([[bannerAdUnit adUnitId] isEqual:expectedAdUnitId]);
    XCTAssertEqual([bannerAdUnit adUnitType], expectedType);
    XCTAssertEqual([bannerAdUnit size].width, expectedSize.width);
    XCTAssertEqual([bannerAdUnit size].height, expectedSize.height);
}

- (void) testSameBannerAdUnitsHaveSameHash
{
    CRBannerAdUnit* bannerAdUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit* bannerAdUnit2 = [[CRBannerAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"] size:CGSizeMake(350.0f, 50.0f)];

    XCTAssertEqual(bannerAdUnit1.hash, bannerAdUnit2.hash);
}

- (void) testSameBannerAdUnitsAreEqual
{
    CRBannerAdUnit* bannerAdUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit* bannerAdUnit2 = [[CRBannerAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"] size:CGSizeMake(350.0f, 50.0f)];

    XCTAssert([bannerAdUnit1 isEqual:bannerAdUnit2]);
    XCTAssert([bannerAdUnit2 isEqual:bannerAdUnit1]);

    XCTAssert([bannerAdUnit1 isEqualToBannerAdUnit:bannerAdUnit2]);
    XCTAssert([bannerAdUnit2 isEqualToBannerAdUnit:bannerAdUnit1]);

    XCTAssertEqualObjects(bannerAdUnit1, bannerAdUnit2);
}

- (void) testDifferentBannerAdUnitsHaveDifferentHash
{
    CRBannerAdUnit *bannerAdUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit *bannerAdUnit2 = [[CRBannerAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"] size:CGSizeMake(350.0f, 200.0f)];
    XCTAssertNotEqual(bannerAdUnit1.hash, bannerAdUnit2.hash);

    CRBannerAdUnit *bannerAdUnit3 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit *bannerAdUnit4 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 200.0f)];
    XCTAssertNotEqual(bannerAdUnit3.hash, bannerAdUnit4.hash);

    CRBannerAdUnit *bannerAdUnit5 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit *bannerAdUnit6 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Changed" size:CGSizeMake(350.0f, 50.0f)];
    XCTAssertNotEqual(bannerAdUnit5.hash, bannerAdUnit6.hash);
}

- (void) testDifferentBannerAdUnitsAreNotEqual
{
    CRBannerAdUnit *bannerAdUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit *bannerAdUnit2 = [[CRBannerAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"] size:CGSizeMake(350.0f, 200.0f)];

    XCTAssertFalse([bannerAdUnit1 isEqual:bannerAdUnit2]);
    XCTAssertFalse([bannerAdUnit2 isEqual:bannerAdUnit1]);
    XCTAssertFalse([bannerAdUnit1 isEqualToBannerAdUnit:bannerAdUnit2]);
    XCTAssertFalse([bannerAdUnit2 isEqualToBannerAdUnit:bannerAdUnit1]);
    XCTAssertNotEqualObjects(bannerAdUnit1, bannerAdUnit2);

    CRBannerAdUnit *bannerAdUnit3 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit *bannerAdUnit4 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 200.0f)];

    XCTAssertFalse([bannerAdUnit3 isEqual:bannerAdUnit4]);
    XCTAssertFalse([bannerAdUnit4 isEqual:bannerAdUnit3]);
    XCTAssertFalse([bannerAdUnit3 isEqualToBannerAdUnit:bannerAdUnit4]);
    XCTAssertFalse([bannerAdUnit4 isEqualToBannerAdUnit:bannerAdUnit3]);
    XCTAssertNotEqualObjects(bannerAdUnit3, bannerAdUnit4);

    CRBannerAdUnit *bannerAdUnit5 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"String1" size:CGSizeMake(350.0f, 50.0f)];
    CRBannerAdUnit *bannerAdUnit6 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Changed" size:CGSizeMake(350.0f, 50.0f)];

    XCTAssertFalse([bannerAdUnit5 isEqual:bannerAdUnit6]);
    XCTAssertFalse([bannerAdUnit6 isEqual:bannerAdUnit5]);
    XCTAssertFalse([bannerAdUnit5 isEqualToBannerAdUnit:bannerAdUnit6]);
    XCTAssertFalse([bannerAdUnit6 isEqualToBannerAdUnit:bannerAdUnit5]);
    XCTAssertNotEqualObjects(bannerAdUnit5, bannerAdUnit6);
}

@end
