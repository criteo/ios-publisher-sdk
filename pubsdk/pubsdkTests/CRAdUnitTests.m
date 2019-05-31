//
//  CRAdUnitTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 5/31/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"

@interface CRAdUnitTests : XCTestCase


@end

@implementation CRAdUnitTests

- (void)testAdUnitInitialization {
    NSString *expectedAdUnitId = @"expected";
    CRAdUnitType expectedType = CRAdUnitTypeBanner;
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:expectedAdUnitId
                                               adUnitType:expectedType];
    XCTAssertTrue([[adUnit adUnitId] isEqual:expectedAdUnitId]);
    XCTAssertEqual([adUnit adUnitType], expectedType);
}

- (void) testInvalidAdUnitTypeInInitialization {
    NSString *expectedAdUnitId = @"expected";
    CRAdUnitType invalidType = 3;
    //TODO: have an exception after passing an invalid adunit type
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:expectedAdUnitId
                                               adUnitType:invalidType];
    XCTAssertTrue([[adUnit adUnitId] isEqual:expectedAdUnitId]);
    XCTAssertEqual([adUnit adUnitType], invalidType);
}

@end
