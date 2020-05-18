//
//  CR_AppEventsTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_AppEvents.h"
#import "CR_ApiHandler.h"

@interface CR_AppEventsTests : XCTestCase

@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation CR_AppEventsTests

- (void)setUp {
    self.notificationCenter = [[NSNotificationCenter alloc] init];
}

// Internally sendLaunchEvent, sendActiveEvent and sendInActiveEvent call the same method
// So this test should suffice
- (void) testSendEvent {
    CR_ApiHandler *mockApiHandler = OCMStrictClassMock([CR_ApiHandler class]);
    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    CR_DataProtectionConsent *mockConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
    OCMStub([mockConsent shouldSendAppEvent]).andReturn(YES);
    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(100), @"throttleSec", nil];
    NSDate *testDate = [NSDate date];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                                 consent:[OCMArg isKindOfClass:[CR_DataProtectionConsent class]]
                                  config:[OCMArg isKindOfClass:[CR_Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[CR_DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                                config:mockConfig
                                                               consent:mockConsent
                                                            deviceInfo:mockDeviceInfo
                                                    notificationCenter:self.notificationCenter];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(100, [appEvents throttleSec]);
    XCTAssertEqualObjects(testDate, [appEvents latestEventSent]);
    XCTAssertFalse([appEvents throttleExpired]);
}

- (void) testThrottleExpiredZeroThrottle {
    CR_ApiHandler *mockApiHandler = OCMStrictClassMock([CR_ApiHandler class]);
    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    CR_DataProtectionConsent *mockConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
    OCMStub([mockConsent shouldSendAppEvent]).andReturn(YES);
    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(0), @"throttleSec", nil];
    NSDate *testDate = [NSDate date];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                                 consent:[OCMArg isKindOfClass:[CR_DataProtectionConsent class]]
                                  config:[OCMArg isKindOfClass:[CR_Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[CR_DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                                config:mockConfig
                                                               consent:mockConsent
                                                            deviceInfo:mockDeviceInfo
                                                    notificationCenter:self.notificationCenter];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(0, [appEvents throttleSec]);
    XCTAssertEqualObjects(testDate, [appEvents latestEventSent]);
    XCTAssertTrue([appEvents throttleExpired]);
}

- (void) testThrottleExpiredWithThrottleSecs {
    CR_ApiHandler *mockApiHandler = OCMStrictClassMock([CR_ApiHandler class]);
    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    CR_DataProtectionConsent *mockConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
    OCMStub([mockConsent shouldSendAppEvent]).andReturn(YES);
    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(30), @"throttleSec", nil];
    // Event was sent 60 secs ago and throttle is 30 secs
    NSDate *testDate = [NSDate dateWithTimeIntervalSinceNow:-60];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                                 consent:[OCMArg isKindOfClass:[CR_DataProtectionConsent class]]
                                  config:[OCMArg isKindOfClass:[CR_Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[CR_DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                                config:mockConfig
                                                               consent:mockConsent
                                                            deviceInfo:mockDeviceInfo
                                                    notificationCenter:self.notificationCenter];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(30, [appEvents throttleSec]);
    XCTAssertTrue([appEvents throttleExpired]);
}

- (void) testThrottleNotExpiredWithThrottleSecs {
    CR_ApiHandler *mockApiHandler = OCMStrictClassMock([CR_ApiHandler class]);
    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    CR_DataProtectionConsent *mockConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
    OCMStub([mockConsent shouldSendAppEvent]).andReturn(YES);
    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    NSDictionary *appEventsDict = [NSDictionary dictionaryWithObjectsAndKeys:@(30), @"throttleSec", nil];
    // Event was sent 10 secs ago and throttle is 30 secs
    NSDate *testDate = [NSDate dateWithTimeIntervalSinceNow:-10];

    OCMStub([mockApiHandler sendAppEvent:[OCMArg isKindOfClass:[NSString class]]
                                 consent:[OCMArg isKindOfClass:[CR_DataProtectionConsent class]]
                                  config:[OCMArg isKindOfClass:[CR_Config class]]
                              deviceInfo:[OCMArg isKindOfClass:[CR_DeviceInfo class]]
                          ahEventHandler:([OCMArg invokeBlockWithArgs:appEventsDict, testDate, nil])]);

    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:mockApiHandler
                                                                config:mockConfig
                                                               consent:mockConsent
                                                            deviceInfo:mockDeviceInfo
                                                    notificationCenter:self.notificationCenter];
    [appEvents sendLaunchEvent];
    XCTAssertEqual(30, [appEvents throttleSec]);
    XCTAssertFalse([appEvents throttleExpired]);
}

@end
