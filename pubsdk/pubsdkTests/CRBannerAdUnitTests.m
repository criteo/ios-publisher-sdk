//
//  CRBannerAdUnitTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
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

@end
