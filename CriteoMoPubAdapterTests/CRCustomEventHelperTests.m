//
//  CRCustomEventHelperTests.m
//  CriteoMoPubAdapterTests
//
//  Created by Robert Aung Hein Oo on 8/12/19.
//  Copyright © 2019 Sneha Pathrose. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRCustomEventHelper.h"

@interface CRCustomEventHelperTests : XCTestCase

@end

@implementation CRCustomEventHelperTests

- (void) testInfoKeyMissing {
    NSDictionary *info = @{ @"invalidKey" : @"value", @"cpid" : @"i should be uppercase" };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void) testInfoValueMissing {
    NSDictionary *info = @{ @"cpId" : [NSNull null], @"adUnitId" : [NSNull null] };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void) testInfoValueNotString {
    NSDictionary *info = @{ @"cpId" : @21, @"adUnitId" : @48 };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void) testInfoValueEmptyString {
    NSDictionary *info = @{ @"cpId" : @"", @"adUnitId" : @"" };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void) testValidInfo {
    NSDictionary *info = @{ @"cpId" : @"Publisher Id", @"some Key" : @"some value", @"adUnitId" : @"an adUnitId" };
    XCTAssertTrue([CRCustomEventHelper checkValidInfo:info]);
}

@end
