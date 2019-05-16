//
//  CR_ConfigManagerTests.m
//  pubsdkTests
//
//  Created by Paul Davis on 1/26/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock.h>

#import "CR_ConfigManager.h"

@interface CR_ConfigManagerTests : XCTestCase

@end

@implementation CR_ConfigManagerTests
{
    NSDictionary *remoteConfig;
    CR_Config *localConfig;
    CR_ApiHandler *mockApiHandler;
}

- (void)setUp {
    // Remote config returned from the pub sdk config service
    remoteConfig = @{ @"killSwitch" : @(NO) };

    // Local config hosted inside the app
    localConfig = [[CR_Config alloc] initWithCriteoPublisherId:nil];
    localConfig.killSwitch = YES;

    // Mock remote config API, returns the remoteConfig dictionary above
    mockApiHandler = OCMStrictClassMock(CR_ApiHandler.class);

    OCMStub([mockApiHandler getConfig:localConfig
                      ahConfigHandler:([OCMArg invokeBlockWithArgs:remoteConfig, nil])]);
}

- (void)tearDown {
    mockApiHandler = nil;
    localConfig = nil;
    remoteConfig = nil;
}

- (void) testConfigManagerRefreshesKillSwitch
{
    XCTAssertEqual(localConfig.killSwitch, YES, @"Kill switch should be activated at the start of the test");

    CR_ConfigManager *configManager = [[CR_ConfigManager alloc] initWithApiHandler:mockApiHandler];
    [configManager refreshConfig:localConfig];

    XCTAssertEqual(localConfig.killSwitch, NO, @"Kill switch should be deactivated after config is refreshed from remote API");
}

@end
