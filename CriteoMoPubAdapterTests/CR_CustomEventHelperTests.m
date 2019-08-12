//
//  CR_CustomEventHelperTests.m
//  CriteoMoPubAdapterTests
//
//  Created by Robert Aung Hein Oo on 8/12/19.
//  Copyright © 2019 Sneha Pathrose. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_CustomEventHelper.h"

@interface CR_CustomEventHelperTests : XCTestCase

@end

@implementation CR_CustomEventHelperTests

- (void) testInfoKeyMissing {
    NSDictionary *info = @{ @"invalidKey" : @"value", @"cpid" : @"i should be uppercase" };
    XCTAssertFalse([CR_CustomEventHelper checkValidInfo:info]);
}

- (void) testInfoValueMissing {
    NSDictionary *info = @{ @"cpId" : [NSNull null], @"adUnitId" : [NSNull null] };
    XCTAssertFalse([CR_CustomEventHelper checkValidInfo:info]);
}

- (void) testInfoValueNotString {
    NSDictionary *info = @{ @"cpId" : @21, @"adUnitId" : @48 };
    XCTAssertFalse([CR_CustomEventHelper checkValidInfo:info]);
}

- (void) testInfoValueEmptyString {
    NSDictionary *info = @{ @"cpId" : @"", @"adUnitId" : @"" };
    XCTAssertFalse([CR_CustomEventHelper checkValidInfo:info]);
}

- (void) testValidInfo {
    NSDictionary *info = @{ @"cpId" : @"Publisher Id", @"some Key" : @"some value", @"adUnitId" : @"an adUnitId" };
    XCTAssertTrue([CR_CustomEventHelper checkValidInfo:info]);
}

@end
