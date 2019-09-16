//
//  NSDictionary+CriteoTests.m
//  pubsdkTests
//
//  Created by Richard Clark on 9/14/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+Criteo.h"

@interface NSDictionary_AdditionsTests : XCTestCase

@end

@implementation NSDictionary_AdditionsTests

- (void)testDictionaryWithNewValue {
    NSDictionary *dict = @{ @"a" : @(1), @"b" : @(2) };
    NSDictionary *modDict = [dict dictionaryWithNewValue:@(3) forKey:@"a"];
    XCTAssertEqualObjects(modDict[@"a"], @(3));
    XCTAssertEqualObjects(modDict[@"b"], @(2));
}

@end
