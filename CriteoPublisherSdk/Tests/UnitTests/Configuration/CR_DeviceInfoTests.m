//
//  CR_DeviceInfoTests.m
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

#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "CR_DeviceInfo+Testing.h"
#import "CR_ThreadManager.h"
#import "WKWebView+Testing.h"
#import "XCTestCase+Criteo.h"

@interface CR_DeviceInfoTests : XCTestCase
@end

@implementation CR_DeviceInfoTests

- (void)testWKWebViewSuccess {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"UserAgent is filled asynchronously"];
  WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
  OCMStub([wkWebViewMock
      evaluateJavaScript:@"navigator.userAgent"
       completionHandler:([OCMArg invokeBlockWithArgs:@"Some Ua", [NSNull null], nil])]);
  CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
  CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithThreadManager:threadManager
                                                               testWebView:wkWebViewMock];
  [deviceInfo waitForUserAgent:^{
    XCTAssertEqual(@"Some Ua", deviceInfo.userAgent,
                   @"User agent should be set if WKWebView passes it");
    [expectation fulfill];
  }];
  [self cr_waitShortlyForExpectations:@[ expectation ]];
}

- (void)testCompleteFailure {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"UserAgent is filled asynchronously"];
  WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
  NSError *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
  OCMStub([wkWebViewMock
      evaluateJavaScript:@"navigator.userAgent"
       completionHandler:([OCMArg invokeBlockWithArgs:@"Not An UA", anError, nil])]);
  CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
  CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithThreadManager:threadManager
                                                               testWebView:wkWebViewMock];
  [deviceInfo waitForUserAgent:^{
    XCTAssertNil(
        deviceInfo.userAgent,
        @"User agent should be nil if we didn't manage to set it. Perhaps we can find a better solution in the future. Also we should log.");
    [expectation fulfill];
  }];
  [self cr_waitShortlyForExpectations:@[ expectation ]];
}

// This is more an ITest and should probably be moved in a separate project
- (void)testUserAgent {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"UserAgent is filled asynchronously"];
  CR_DeviceInfo *device = [[CR_DeviceInfo alloc] init];
  XCTAssertNil(device.userAgent, @"User-Agent is nil when we create the object");
  [device waitForUserAgent:^{
    XCTAssertNotNil(device.userAgent,
                    @"User-Agent should be filled in after a short period of time");
    NSRange range = [device.userAgent rangeOfString:@"Mozilla.*Mobile/"
                                            options:NSRegularExpressionSearch];
    XCTAssertTrue(range.location != NSNotFound);
    [expectation fulfill];
  }];
  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testWebViewInstantiatedOnMainThread {
  XCTestExpectation *expectation = [self expectationWithDescription:@"DeviceInfo created"];
  dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    XCTAssertNoThrow([[CR_DeviceInfo alloc] init]);
    [expectation fulfill];
  });
  [self cr_waitShortlyForExpectations:@[ expectation ]];
}

- (void)testWebViewReleasedAfterUse {
  XCTestExpectation *expectation = [self expectationWithDescription:@"WebView has been released"];
  WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
  NSError *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
  OCMStub([wkWebViewMock
      evaluateJavaScript:@"navigator.userAgent"
       completionHandler:([OCMArg invokeBlockWithArgs:@"Not An UA", anError, nil])]);
  CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
  CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithThreadManager:threadManager
                                                               testWebView:wkWebViewMock];
  [deviceInfo waitForUserAgent:^{
    XCTAssertNil(deviceInfo.webView, @"WebView has been released");
    [expectation fulfill];
  }];
  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testSafeScreenSize_GivenAnyDevice_ReturnNonZeroSizeBelowFullScreenSize {
  WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
  CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
  CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithThreadManager:threadManager
                                                               testWebView:wkWebViewMock];

  CGSize safeScreenSize = deviceInfo.safeScreenSize;
  CGSize fullScreenSize = deviceInfo.screenSize;

  XCTAssertGreaterThan(safeScreenSize.width, 0);
  XCTAssertGreaterThan(safeScreenSize.height, 0);
  XCTAssertLessThanOrEqual(safeScreenSize.width, fullScreenSize.width);
  XCTAssertLessThanOrEqual(safeScreenSize.height, fullScreenSize.height);
}

@end
