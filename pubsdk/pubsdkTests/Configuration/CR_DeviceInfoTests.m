//
//  CR_DeviceInfoTests.m
//  pubsdkTests
//
//  Created by Paul Davis on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "CR_DeviceInfo.h"
@import WebKit;

@interface CR_DeviceInfoTests : XCTestCase

@end

@implementation CR_DeviceInfoTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testWKWebViewSuccess {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UserAgent is filled asynchronously"];

    WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
    UIWebView *uiWebViewMock = OCMStrictClassMock([UIWebView class]);
    
    OCMStub([wkWebViewMock evaluateJavaScript:@"navigator.userAgent" completionHandler:([OCMArg invokeBlockWithArgs:@"Some Ua", [NSNull null], nil])]);
    
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithWKWebView:wkWebViewMock uiWebView:uiWebViewMock];
    [deviceInfo waitForUserAgent:^{
        XCTAssertEqual(@"Some Ua", deviceInfo.userAgent, @"User agent should be set if WKWebView passes it");
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:0.1];
}

- (void)testFallBackToUiWebView {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UserAgent is filled asynchronously"];

    WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
    UIWebView *uiWebViewMock = OCMStrictClassMock([UIWebView class]);
    
    NSError *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
    OCMStub([wkWebViewMock evaluateJavaScript:@"navigator.userAgent" completionHandler:([OCMArg invokeBlockWithArgs:@"Not An UA", anError, nil])]);
    
    OCMStub([uiWebViewMock stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]).andReturn(@"Another Ua");
    
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithWKWebView:wkWebViewMock uiWebView:uiWebViewMock];
    [deviceInfo waitForUserAgent:^{
        XCTAssertEqual(@"Another Ua", deviceInfo.userAgent, @"User agent should be set to fallback value if WKWebView doesn't pass it but UIWebView does");
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:0.1];
}

- (void)testCompleteFailure {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UserAgent is filled asynchronously"];
    
    WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
    UIWebView *uiWebViewMock = nil;
    
    NSError *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
    OCMStub([wkWebViewMock evaluateJavaScript:@"navigator.userAgent" completionHandler:([OCMArg invokeBlockWithArgs:@"Not An UA", anError, nil])]);
    
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] initWithWKWebView:wkWebViewMock uiWebView:uiWebViewMock];
    [deviceInfo waitForUserAgent:^{
        XCTAssertNil(deviceInfo.userAgent, @"User agent should be nil if we didn't manage to set it. Perhaps we can find a better solution in the future. Also we should log.");
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:0.1];
}

// This is more an ITest and should probably be moved in a separate project
- (void) testUserAgent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UserAgent is filled asynchronously"];

    CR_DeviceInfo *device = [[CR_DeviceInfo alloc] init];
    XCTAssertNil(device.userAgent, @"User-Agent is nil when we create the object");
    [device waitForUserAgent:^{
        XCTAssertNotNil(device.userAgent, @"User-Agent should be filled in after a short period of time");
        NSRange range = [device.userAgent rangeOfString:@"Mozilla.*Mobile/" options:NSRegularExpressionSearch];
        XCTAssertTrue(range.location != NSNotFound);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:5];
}

// This is more an ITest and should probably be moved in a separate project
- (void) testUIWebViewUserAgent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"UserAgent is filled asynchronously"];
    
    WKWebView *wkWebViewMock = OCMStrictClassMock([WKWebView class]);
    NSError *anError = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
    OCMStub([wkWebViewMock evaluateJavaScript:@"navigator.userAgent" completionHandler:([OCMArg invokeBlockWithArgs:@"Not An UA", anError, nil])]);

    CR_DeviceInfo *device = [[CR_DeviceInfo alloc] initWithWKWebView:wkWebViewMock uiWebView:[UIWebView new]];
    XCTAssertNil(device.userAgent, @"User-Agent is nil when we create the object");
    [device waitForUserAgent:^{
        XCTAssertNotNil(device.userAgent, @"User-Agent should be filled in after a short period of time");
        NSRange range = [device.userAgent rangeOfString:@"Mozilla.*Mobile/" options:NSRegularExpressionSearch];
        XCTAssertTrue(range.location != NSNotFound);
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:5];
}

@end
