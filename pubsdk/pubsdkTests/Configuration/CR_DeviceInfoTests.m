//
//  CR_DeviceInfoTests.m
//  pubsdkTests
//
//  Created by Paul Davis on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CR_DeviceInfo.h"

@interface CR_DeviceInfoTests : XCTestCase

@end

@implementation CR_DeviceInfoTests

- (void)setUp {
}

- (void)tearDown {
}

- (void) testUserAgent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UserAgent is filled asynchronously"];

    CR_DeviceInfo *device = [[CR_DeviceInfo alloc] init];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertNotNil(device.userAgent, @"User-Agent should be filled in after a short period of time");
        NSRange range = [device.userAgent rangeOfString:@"Mozilla.*Mobile/" options:NSRegularExpressionSearch];
        XCTAssertTrue(range.location != NSNotFound);
        [expectation fulfill];
    });

    [self waitForExpectations:@[expectation] timeout:2];
}

@end
