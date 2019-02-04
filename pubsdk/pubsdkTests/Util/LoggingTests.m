//
//  LoggingTests.m
//  pubsdkTests
//
//  Created by Paul Davis on 2/4/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Logging.h"

@interface LoggingTests : XCTestCase

@end

@implementation LoggingTests

- (void) testLoggingDoesNotCrash
{
    NSString *testStr = @"This must not cause a crash";

    CLog(@"%@", testStr);
}

@end
