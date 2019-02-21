//
//  CR_AppEventsTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_AppEvents.h"
#import "ApiHandler.h"

@interface CR_AppEventsTests : XCTestCase

@end

@implementation CR_AppEventsTests

// Internally sendLaunchEvent, sendActiveEvent and sendInActiveEvent call the same method
// So this test should suffice
- (void) testSendEvent {
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *mockConfig = OCMStrictClassMock([Config class]);
    GdprUserConsent *mockGdpr = OCMStrictClassMock([GdprUserConsent class]);
    DeviceInfo *mockDeviceInfo = OCMStrictClassMock([DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(100), @"throttleSec", nil];
    NSDate *testDate = [NSDate date];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                             gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                  config:[OCMArg isKindOfClass:[Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                          config:mockConfig
                                                            gdpr:mockGdpr
                                                      deviceInfo:mockDeviceInfo];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(100, [appEvents throttleSec]);
    XCTAssertEqualObjects(testDate, [appEvents latestEventSent]);
    XCTAssertFalse([appEvents throttleExpired]);
}

- (void) testThrottleExpiredZeroThrottle {
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *mockConfig = OCMStrictClassMock([Config class]);
    GdprUserConsent *mockGdpr = OCMStrictClassMock([GdprUserConsent class]);
    DeviceInfo *mockDeviceInfo = OCMStrictClassMock([DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(0), @"throttleSec", nil];
    NSDate *testDate = [NSDate date];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                             gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                  config:[OCMArg isKindOfClass:[Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                          config:mockConfig
                                                            gdpr:mockGdpr
                                                      deviceInfo:mockDeviceInfo];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(0, [appEvents throttleSec]);
    XCTAssertEqualObjects(testDate, [appEvents latestEventSent]);
    XCTAssertTrue([appEvents throttleExpired]);
}

- (void) testThrottleExpiredWithThrottleSecs {
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *mockConfig = OCMStrictClassMock([Config class]);
    GdprUserConsent *mockGdpr = OCMStrictClassMock([GdprUserConsent class]);
    DeviceInfo *mockDeviceInfo = OCMStrictClassMock([DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(30), @"throttleSec", nil];
    // Event was sent 60 secs ago and throttle is 30 secs
    NSDate *testDate = [NSDate dateWithTimeIntervalSinceNow:-60];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                             gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                  config:[OCMArg isKindOfClass:[Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                          config:mockConfig
                                                            gdpr:mockGdpr
                                                      deviceInfo:mockDeviceInfo];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(30, [appEvents throttleSec]);
    XCTAssertTrue([appEvents throttleExpired]);
}

- (void) testThrottleNotExpiredWithThrottleSecs {
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *mockConfig = OCMStrictClassMock([Config class]);
    GdprUserConsent *mockGdpr = OCMStrictClassMock([GdprUserConsent class]);
    DeviceInfo *mockDeviceInfo = OCMStrictClassMock([DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(30), @"throttleSec", nil];
    // Event was sent 10 secs ago and throttle is 30 secs
    NSDate *testDate = [NSDate dateWithTimeIntervalSinceNow:-10];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                             gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                  config:[OCMArg isKindOfClass:[Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                          config:mockConfig
                                                            gdpr:mockGdpr
                                                      deviceInfo:mockDeviceInfo];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(30, [appEvents throttleSec]);
    XCTAssertFalse([appEvents throttleExpired]);
}

/*
// This is to test if CR_AppEvents makes one and only one call to the [apiHandler sendAppEvent]
- (void) testNoApiCallIfThrottleIsOn {
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *mockConfig = OCMStrictClassMock([Config class]);
    GdprUserConsent *mockGdpr = OCMStrictClassMock([GdprUserConsent class]);
    DeviceInfo *mockDeviceInfo = OCMStrictClassMock([DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(300), @"throttleSec", nil];
    // Event was sent 10 secs ago and throttle is 300 secs
    NSDate *testDate = [NSDate dateWithTimeIntervalSinceNow:-10];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                             gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                  config:[OCMArg isKindOfClass:[Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler config:mockConfig gdpr:mockGdpr deviceInfo:mockDeviceInfo];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(300, [appEvents throttleSec]);
    XCTAssertFalse([appEvents throttleExpired]);
    // The next call to send*Event should NOT fire a call to ApiHandler as the throttle is on
    OCMReject([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                               gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                    config:[OCMArg isKindOfClass:[Config class]]
                                deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                            ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);
    [appEvents sendActiveEvent:[NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification object:nil]];
    OCMVerify(mockApiHandler);
}

// This is to test if CR_AppEvents makes two calls to the [apiHandler sendAppEvent]
- (void) testApiCallIfThrottleIsExpired {
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *mockConfig = OCMStrictClassMock([Config class]);
    GdprUserConsent *mockGdpr = OCMStrictClassMock([GdprUserConsent class]);
    DeviceInfo *mockDeviceInfo = OCMStrictClassMock([DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(10), @"throttleSec", nil];
    // Event was sent 30 secs ago and throttle is 10 secs
    NSDate *testDate = [NSDate dateWithTimeIntervalSinceNow:-30];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                             gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                  config:[OCMArg isKindOfClass:[Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler config:mockConfig gdpr:mockGdpr deviceInfo:mockDeviceInfo];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(10, [appEvents throttleSec]);
    XCTAssertTrue([appEvents throttleExpired]);
    // The next call to send*Event should fire a call to ApiHandler as the throttle is off
    OCMReject([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                               gdprConsent:[OCMArg isKindOfClass:[GdprUserConsent class]]
                                    config:[OCMArg isKindOfClass:[Config class]]
                                deviceInfo:[OCMArg isKindOfClass:[DeviceInfo class]]
                            ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);
    [appEvents sendActiveEvent:[NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification object:nil]];
    OCMVerify(mockApiHandler);
}
*/
@end
