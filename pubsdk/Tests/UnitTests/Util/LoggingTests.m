//
//  LoggingTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#define CLOG_ENABLE_FOR_TESTING 1

#import <XCTest/XCTest.h>

#import "Logging.h"

@interface LoggingTests : XCTestCase

@end

@implementation LoggingTests

// All of these tests are "Does Not Crash" tests
// i.e. Successful execution of the test method means that the test passes

- (void) testLogging
{
    NSString *testStr = @"This must not cause a crash";

    CLog(@"%@", testStr);
}

- (void) testLoggingNilVarArg
{
    CLog(@"%@", nil);
}

- (void) testLoggingEmptyString
{
    CLog(@"");
}

- (void) testLoggingEmptyStringWithVarArg
{
    CLog(@"", nil);
    CLog(@"", @"SomeVarArg");
}

@end

#undef CLOG_ENABLE_FOR_TESTING
