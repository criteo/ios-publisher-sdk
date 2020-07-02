//
//  LoggingTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#define CLOG_ENABLE_FOR_TESTING 1

#import <XCTest/XCTest.h>

#import "Logging.h"

@interface LoggingTests : XCTestCase

@end

@implementation LoggingTests

// All of these tests are "Does Not Crash" tests
// i.e. Successful execution of the test method means that the test passes

- (void)testLogging {
  NSString *testStr = @"This must not cause a crash";

  CLog(@"%@", testStr);
}

- (void)testLoggingNilVarArg {
  CLog(@"%@", nil);
}

- (void)testLoggingEmptyString {
  CLog(@"");
}

- (void)testLoggingEmptyStringWithVarArg {
  CLog(@"", nil);
  CLog(@"", @"SomeVarArg");
}

@end

#undef CLOG_ENABLE_FOR_TESTING
