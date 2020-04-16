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
#import "NSUserDefaults+Testing.h"

@interface CR_ConfigManagerTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefault;
@property (nonatomic, strong) CR_ConfigManager *configManager;

@end

@implementation CR_ConfigManagerTests {
    CR_Config *localConfig;
    CR_ApiHandler *mockApiHandler;
}

- (void)setUp {
    localConfig = [[CR_Config alloc] initWithCriteoPublisherId:nil];
    mockApiHandler = OCMStrictClassMock(CR_ApiHandler.class);

    self.userDefault = [[NSUserDefaults alloc] init];
    self.configManager = [[CR_ConfigManager alloc] initWithApiHandler:mockApiHandler
                                                          userDefault:self.userDefault];
}

- (void)tearDown {
    mockApiHandler = nil;
    localConfig = nil;

    [self.userDefault removeObjectForKey:NSUserDefaultsKillSwitchKey];
    [self.userDefault removeObjectForKey:NSUserDefaultsCsmEnabledKey];
}

- (void) testConfigManagerDisableKillSwitch {
    [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"killSwitch\": false }"];
    localConfig.killSwitch = YES;

    [self.configManager refreshConfig:localConfig];

    XCTAssertEqual(localConfig.killSwitch, NO, @"Kill switch should be deactivated after config is refreshed from remote API");
}

- (void) testConfigManagerEnabledKillSwitch {
    [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"killSwitch\": true }"];
    localConfig.killSwitch = NO;

    [self.configManager refreshConfig:localConfig];

    XCTAssertEqual(localConfig.killSwitch, YES, @"Kill switch should be activated after config is refreshed from remote API");
}

- (void) testRefreshConfig_CsmFeatureFlagNotInResponse_DoNotUpdateIt {
    [self prepareApiHandlerToRespondRemoteConfigJson:@"{}"];
    localConfig.csmEnabled = NO;

    [self.configManager refreshConfig:localConfig];

    XCTAssertFalse(localConfig.csmEnabled);
}

- (void) testRefreshConfig_GivenCsmFeatureFlagSetToTrueInRequest_CsmIsEnabled {
    [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"csmEnabled\": true }"];
    localConfig.csmEnabled = NO;

    [self.configManager refreshConfig:localConfig];

    XCTAssertTrue(localConfig.isCsmEnabled);
}

- (void) testRefreshConfig_GivenCsmFeatureFlagSetToFalseInRequest_CsmIsDisabled {
    [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"csmEnabled\": false }"];
    localConfig.csmEnabled = YES;

    [self.configManager refreshConfig:localConfig];

    XCTAssertFalse(localConfig.isCsmEnabled);
}

#pragma mark - Private

- (void) prepareApiHandlerToRespondRemoteConfigJson:(NSString *)jsonResponse {
    NSData *dataResponse = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionaryResponse = [CR_Config getConfigValuesFromData:dataResponse];

    OCMStub([mockApiHandler getConfig:localConfig
                      ahConfigHandler:([OCMArg invokeBlockWithArgs:dictionaryResponse, nil])]);
}

@end
