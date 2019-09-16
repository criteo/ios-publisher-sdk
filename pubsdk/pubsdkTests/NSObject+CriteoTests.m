//
//  NSObject+CriteoTests.m
//  pubsdkTests
//
//  Created by Richard Clark on 9/15/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+Criteo.h"

@interface NSObject_CriteoTests : XCTestCase

@end

@implementation NSObject_CriteoTests

- (void)testObjectIsEqualTo {
    XCTAssertTrue([NSObject object:@"a" isEqualTo:@"a"]);
    XCTAssertFalse([NSObject object:@"a" isEqualTo:@"b"]);
    XCTAssertFalse([NSObject object:@"a" isEqualTo:nil]);
    XCTAssertFalse([NSObject object:nil isEqualTo:@"a"]);
    XCTAssertTrue([NSObject object:nil isEqualTo:nil]);
}

@end
