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
#import "NSUserDefaults+CRPrivateKeysAndUtils.h"

@interface CR_ConfigManagerTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefault;
@property (nonatomic, strong) CR_ConfigManager *configManager;

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

    self.userDefault = [[NSUserDefaults alloc] init];
    self.configManager = [[CR_ConfigManager alloc] initWithApiHandler:mockApiHandler
                                                          userDefault:self.userDefault];
}

- (void)tearDown {
    mockApiHandler = nil;
    localConfig = nil;
    remoteConfig = nil;
}

- (void) testConfigManagerRefreshesKillSwitch
{
    [self.configManager refreshConfig:localConfig];
    XCTAssertEqual(localConfig.killSwitch, NO, @"Kill switch should be deactivated after config is refreshed from remote API");
}

- (void) testSetKillSwitchInUserDefault
{
    [self.configManager refreshConfig:localConfig];
    XCTAssertTrue([self.userDefault containsKey:NSUserDefaultsKillSwitchKey]);
    XCTAssertFalse([self.userDefault boolForKey:NSUserDefaultsKillSwitchKey]);
}

@end
