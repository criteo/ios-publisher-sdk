//
//  CR_ConfigTests.m
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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_Config.h"
#import "NSUserDefaults+Testing.h"
#import "NSUserDefaults+Criteo.h"

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
  XCTAssertEqual(YES, ((NSNumber *)[configData objectForKey:@"killSwitch"]).boolValue);
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
  XCTAssertFalse([userDefaults cr_containsKey:NSUserDefaultsKillSwitchKey]);
}

- (void)testSetKillSwitch_GivenEnabledKillSwitch_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.killSwitch = YES;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(newConfig.killSwitch);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsKillSwitchKey]);
  XCTAssertTrue([userDefaults boolForKey:NSUserDefaultsKillSwitchKey]);
}

- (void)testSetKillSwitch_GivenDisabledKillSwitch_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.killSwitch = NO;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(newConfig.killSwitch);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsKillSwitchKey]);
  XCTAssertFalse([userDefaults boolForKey:NSUserDefaultsKillSwitchKey]);
}

- (void)testSetCsmEnabled_GivenNoUpdate_NothingIsWrittenInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.csmEnabled);
  XCTAssertFalse([userDefaults cr_containsKey:NSUserDefaultsCsmEnabledKey]);
}

- (void)testSetCsmEnabled_GivenEnabledFeatureFlag_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.csmEnabled = YES;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(newConfig.csmEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsCsmEnabledKey]);
  XCTAssertTrue([userDefaults boolForKey:NSUserDefaultsCsmEnabledKey]);
}

- (void)testSetCsmEnabled_GivenDisabledFeatureFlag_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.csmEnabled = NO;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(newConfig.csmEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsCsmEnabledKey]);
  XCTAssertFalse([userDefaults boolForKey:NSUserDefaultsCsmEnabledKey]);
}

@end
