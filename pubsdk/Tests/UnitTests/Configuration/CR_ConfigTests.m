//
//  CR_ConfigTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_Config.h"
#import "NSUserDefaults+Testing.h"
#import "NSUserDefaults+CR_Utils.h"

@interface CR_ConfigTests : XCTestCase

@end

@implementation CR_ConfigTests

- (void)tearDown {
    // Apparently, even new initialized user defaults have state.
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults removeObjectForKey:NSUserDefaultsKillSwitchKey];
    [userDefaults removeObjectForKey:NSUserDefaultsCsmEnabledKey];

    [super tearDown];
}

- (void)testGetConfigValuesFromData {
    // Json response from config endpoint
    NSString *rawJsonCdbResponse = @"{\"killSwitch\":true}";
    NSData *configResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *configData = [CR_Config getConfigValuesFromData:configResponse];
    XCTAssertEqual(YES, ((NSNumber *) [configData objectForKey:@"killSwitch"]).boolValue);
}

- (void)testInit_GivenEmptyUserDefault_KillSwitchIsDisabledByDefault {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertFalse(config.killSwitch);
}

- (void)testInit_GivenUserDefaultWithKillSwitchEnabled_KillSwitchIsEnabled {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setBool:YES forKey:NSUserDefaultsKillSwitchKey];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(config.killSwitch);
}

- (void)testInit_GivenUserDefaultWithKillSwitchDisabled_KillSwitchIsDisabled {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setBool:NO forKey:NSUserDefaultsKillSwitchKey];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertFalse(config.killSwitch);
}

- (void)testInit_GivenUserDefaultWithGarbageInKillSwitch_KillSwitchIsDisabledByDefault {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setObject:@"garbage" forKey:NSUserDefaultsKillSwitchKey];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertFalse(config.killSwitch);
}

- (void)testInit_GivenEmptyUserDefault_CsmFeatureIsEnabledByDefault {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(config.isCsmEnabled);
}

- (void)testInit_GivenUserDefaultWithCsmFeatureEnabled_CsmFeatureIsEnabled {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setBool:YES forKey:NSUserDefaultsCsmEnabledKey];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(config.isCsmEnabled);
}

- (void)testInit_GivenUserDefaultWithCsmFeatureDisabled_CsmFeatureIsDisabled {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setBool:NO forKey:NSUserDefaultsCsmEnabledKey];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertFalse(config.isCsmEnabled);
}

- (void)testInit_GivenUserDefaultWithGarbageInCsmFeature_CsmFeatureIsEnabledByDefault {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setObject:@"garbage" forKey:NSUserDefaultsCsmEnabledKey];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(config.isCsmEnabled);
}

- (void)testSetKillSwitch_GivenNoUpdate_NothingIsWrittenInUserDefaults {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertFalse(config.killSwitch);
    XCTAssertFalse([userDefaults containsKey:NSUserDefaultsKillSwitchKey]);
}

- (void)testSetKillSwitch_GivenEnabledKillSwitch_WriteItInUserDefaults {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
    config.killSwitch = YES;

    CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(newConfig.killSwitch);
    XCTAssertTrue([userDefaults containsKey:NSUserDefaultsKillSwitchKey]);
    XCTAssertTrue([userDefaults boolForKey:NSUserDefaultsKillSwitchKey]);
}

- (void)testSetKillSwitch_GivenDisabledKillSwitch_WriteItInUserDefaults {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
    config.killSwitch = NO;

    CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertFalse(newConfig.killSwitch);
    XCTAssertTrue([userDefaults containsKey:NSUserDefaultsKillSwitchKey]);
    XCTAssertFalse([userDefaults boolForKey:NSUserDefaultsKillSwitchKey]);
}

- (void)testSetCsmEnabled_GivenNoUpdate_NothingIsWrittenInUserDefaults {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(config.csmEnabled);
    XCTAssertFalse([userDefaults containsKey:NSUserDefaultsCsmEnabledKey]);
}

- (void)testSetCsmEnabled_GivenEnabledFeatureFlag_WriteItInUserDefaults {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
    config.csmEnabled = YES;

    CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(newConfig.csmEnabled);
    XCTAssertTrue([userDefaults containsKey:NSUserDefaultsCsmEnabledKey]);
    XCTAssertTrue([userDefaults boolForKey:NSUserDefaultsCsmEnabledKey]);
}

- (void)testSetCsmEnabled_GivenDisabledFeatureFlag_WriteItInUserDefaults {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
    config.csmEnabled = NO;

    CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertFalse(newConfig.csmEnabled);
    XCTAssertTrue([userDefaults containsKey:NSUserDefaultsCsmEnabledKey]);
    XCTAssertFalse([userDefaults boolForKey:NSUserDefaultsCsmEnabledKey]);
}

@end
