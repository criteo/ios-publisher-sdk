//
//  NSDictionary+CriteoTests.m
//  pubsdkTests
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+Criteo.h"

@interface NSDictionary_AdditionsTests : XCTestCase

@end

@implementation NSDictionary_AdditionsTests

- (void)testDictionaryWithNewValueForKey {
    NSDictionary *dict = @{ @"a" : @(1), @"b" : @(2) };
    NSDictionary *modDict = [dict dictionaryWithNewValue:@(3) forKey:@"a"];
    XCTAssertEqualObjects(modDict[@"a"], @(3));
    XCTAssertEqualObjects(modDict[@"b"], @(2));
}

- (void)testDictionaryWithNewValueForKeys {
    NSDictionary *dict = @{ @"a" : @(1), @"b" : @{ @"c" : @{ @"x" : @(14)}, @"y" : @(42) }};
    NSDictionary *modDict = [dict dictionaryWithNewValue:@(3) forKeys:@[ @"b", @"c", @"x" ]];
    XCTAssertEqualObjects(modDict[@"a"], @(1));
    XCTAssertEqualObjects(modDict[@"b"][@"c"], @{ @"x" : @(3)});
    XCTAssertEqualObjects(modDict[@"b"][@"c"][@"x"], @(3));

    modDict = [dict dictionaryWithNewValue:nil forKeys:@[ @"b", @"c", @"x" ]];
    XCTAssertNil(modDict[@"b"][@"c"][@"x"]);

    modDict = [dict dictionaryWithNewValue:@(3) forKeys:@[ @"d", @"c" ]];
    XCTAssertNil(modDict);

    modDict = [dict dictionaryWithNewValue:@(3) forKeys:@[ @"a", @"c", @"x", @"q" ]];
    XCTAssertNil(modDict);
}

@end
