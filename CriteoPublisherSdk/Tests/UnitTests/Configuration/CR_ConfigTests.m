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
#import "CRConstants.h"
#import "NSUserDefaults+Testing.h"
#import "NSUserDefaults+Criteo.h"

@interface CR_ConfigTests : XCTestCase
@end

@implementation CR_ConfigTests

#pragma mark - Lifecycle

- (void)tearDown {
  // Apparently, even new initialized user defaults have state.
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults removeObjectForKey:NSUserDefaultsKillSwitchKey];
  [userDefaults removeObjectForKey:NSUserDefaultsCsmEnabledKey];
  [userDefaults removeObjectForKey:NSUserDefaultsPrefetchOnInitEnabledKey];
  [userDefaults removeObjectForKey:NSUserDefaultsLiveBiddingEnabledKey];
  [userDefaults removeObjectForKey:NSUserDefaultsLiveBiddingTimeBudgetKey];
  [userDefaults removeObjectForKey:NSUserDefaultsRemoteLogLevelKey];
  [userDefaults removeObjectForKey:NSUserDefaultsMRAIDKey];
  [[NSUserDefaults standardUserDefaults]
      removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
  [NSUserDefaults resetStandardUserDefaults];

  [super tearDown];
}

#pragma mark - Kill Switch

- (void)testGetConfigValuesFromData {
  // Json response from config endpoint
  NSString *rawJsonCdbResponse = @"{\"killSwitch\":true}";
  NSData *configResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *configData = [CR_Config getConfigValuesFromData:configResponse];
  XCTAssertEqual(YES, ((NSNumber *)configData[@"killSwitch"]).boolValue);
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

#pragma mark - CSM Enabled

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

- (void)testSetCsmEnabled_GivenNoUpdate_NothingIsWrittenInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.csmEnabled);
  XCTAssertFalse([userDefaults cr_containsKey:NSUserDefaultsCsmEnabledKey]);
}

- (void)testSetCsmEnabled_GivenEnabledFeature_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.csmEnabled = YES;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(newConfig.csmEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsCsmEnabledKey]);
  XCTAssertTrue([userDefaults boolForKey:NSUserDefaultsCsmEnabledKey]);
}

- (void)testSetCsmEnabled_GivenDisabledFeature_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.csmEnabled = NO;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(newConfig.csmEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsCsmEnabledKey]);
  XCTAssertFalse([userDefaults boolForKey:NSUserDefaultsCsmEnabledKey]);
}

- (void)testInit_GivenUserDefaultWithMRAIDEnabled {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setBool:YES forKey:NSUserDefaultsMRAIDKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.isMRAIDEnabled);
}

#pragma mark - Prefetch on init Enabled

- (void)testInit_GivenEmptyUserDefault_PrefetchOnInitIsEnabledByDefault {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(config.isPrefetchOnInitEnabled);
}

- (void)testInit_GivenUserDefaultWithPrefetchOnInitEnabled_PrefetchOnInitIsEnabled {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setBool:YES forKey:NSUserDefaultsPrefetchOnInitEnabledKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.isPrefetchOnInitEnabled);
}

- (void)testInit_GivenUserDefaultWithPrefetchOnInitDisabled_PrefetchOnInitIsDisabled {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setBool:NO forKey:NSUserDefaultsPrefetchOnInitEnabledKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(config.isPrefetchOnInitEnabled);
}

- (void)testInit_GivenUserDefaultWithGarbageInPrefetchOnInit_PrefetchOnInitIsEnabledByDefault {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setObject:@"garbage" forKey:NSUserDefaultsPrefetchOnInitEnabledKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(config.isPrefetchOnInitEnabled);
}

- (void)testSetPrefetchOnInitEnabled_GivenNoUpdate_NothingIsWrittenInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(config.isPrefetchOnInitEnabled);
  XCTAssertFalse([userDefaults cr_containsKey:NSUserDefaultsPrefetchOnInitEnabledKey]);
}

- (void)testSetPrefetchOnInitEnabled_GivenEnabledFeature_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.prefetchOnInitEnabled = YES;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(newConfig.isPrefetchOnInitEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsPrefetchOnInitEnabledKey]);
  XCTAssertTrue([userDefaults boolForKey:NSUserDefaultsPrefetchOnInitEnabledKey]);
}

- (void)testSetPrefetchOnInitEnabled_GivenDisabledFeature_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.prefetchOnInitEnabled = NO;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(newConfig.prefetchOnInitEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsPrefetchOnInitEnabledKey]);
  XCTAssertFalse([userDefaults boolForKey:NSUserDefaultsPrefetchOnInitEnabledKey]);
}

#pragma mark - Live Bidding Enabled

- (void)testInit_GivenEmptyUserDefault_LiveBiddingIsDisabledByDefault {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.isLiveBiddingEnabled);
}

- (void)testInit_GivenUserDefaultWithLiveBiddingEnabled_LiveBiddingIsEnabled {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setBool:YES forKey:NSUserDefaultsLiveBiddingEnabledKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.isLiveBiddingEnabled);
}

- (void)testInit_GivenUserDefaultWithLiveBiddingDisabled_LiveBiddingIsDisabled {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setBool:NO forKey:NSUserDefaultsLiveBiddingEnabledKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(config.isLiveBiddingEnabled);
}

- (void)testInit_GivenUserDefaultWithGarbageInLiveBidding_LiveBiddingIsDisabledByDefault {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setObject:@"garbage" forKey:NSUserDefaultsLiveBiddingEnabledKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.isLiveBiddingEnabled);
}

- (void)testSetLiveBiddingEnabled_GivenNoUpdate_NothingIsWrittenInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(config.isLiveBiddingEnabled);
  XCTAssertFalse([userDefaults cr_containsKey:NSUserDefaultsLiveBiddingEnabledKey]);
}

- (void)testSetLiveBiddingEnabled_GivenEnabledFeature_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.liveBiddingEnabled = YES;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertTrue(newConfig.isLiveBiddingEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsLiveBiddingEnabledKey]);
  XCTAssertTrue([userDefaults boolForKey:NSUserDefaultsLiveBiddingEnabledKey]);
}

- (void)testSetLiveBiddingEnabled_GivenDisabledFeature_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.liveBiddingEnabled = NO;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertFalse(newConfig.liveBiddingEnabled);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsLiveBiddingEnabledKey]);
  XCTAssertFalse([userDefaults boolForKey:NSUserDefaultsLiveBiddingEnabledKey]);
}

#pragma mark - Live Bidding Time Budget

- (void)testInit_GivenEmptyUserDefault_LiveBiddingTimeBudgetIsDefaultValue {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.liveBiddingTimeBudget, CRITEO_DEFAULT_LIVE_BID_TIME_BUDGET_IN_SECONDS);
}

- (void)testInit_GivenUserDefaultWithLiveBiddingTimeBudget_LiveBiddingTimeBudgetIsProvided {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  NSTimeInterval testTimeBudget = 42;
  [userDefaults setDouble:testTimeBudget forKey:NSUserDefaultsLiveBiddingTimeBudgetKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.liveBiddingTimeBudget, testTimeBudget);
}

- (void)testInit_GivenUserDefaultWithLiveBiddingBudgetZero_LiveBiddingBudgetIsZero {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  NSTimeInterval testTimeBudget = 0;
  [userDefaults setDouble:testTimeBudget forKey:NSUserDefaultsLiveBiddingTimeBudgetKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.liveBiddingTimeBudget, testTimeBudget);
}

- (void)testInit_GivenUserDefaultWithGarbageInLiveBiddingTimeBudget_LiveBiddingTimeBudgetIsDefault {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setObject:@"garbage" forKey:NSUserDefaultsLiveBiddingTimeBudgetKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.liveBiddingTimeBudget, CRITEO_DEFAULT_LIVE_BID_TIME_BUDGET_IN_SECONDS);
}

- (void)testSetLiveBiddingTimeBudget_GivenNoUpdate_NothingIsWrittenInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.liveBiddingTimeBudget, CRITEO_DEFAULT_LIVE_BID_TIME_BUDGET_IN_SECONDS);
  XCTAssertFalse([userDefaults cr_containsKey:NSUserDefaultsLiveBiddingTimeBudgetKey]);
}

- (void)testSetLiveBiddingTimeBudget_GivenTimeBudgetSet_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  NSTimeInterval testTimeBudget = 42;

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.liveBiddingTimeBudget = testTimeBudget;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(newConfig.liveBiddingTimeBudget, testTimeBudget);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsLiveBiddingTimeBudgetKey]);
  XCTAssertEqual([userDefaults doubleForKey:NSUserDefaultsLiveBiddingTimeBudgetKey],
                 testTimeBudget);
}

- (void)testSetLiveBiddingTimeBudget_GivenTimeBudgetSetZero_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  NSTimeInterval testTimeBudget = 0;

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.liveBiddingTimeBudget = testTimeBudget;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(newConfig.liveBiddingTimeBudget, testTimeBudget);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsLiveBiddingTimeBudgetKey]);
  XCTAssertEqual([userDefaults doubleForKey:NSUserDefaultsLiveBiddingTimeBudgetKey],
                 testTimeBudget);
}

#pragma mark - Remote Log Level

- (void)testInit_GivenEmptyUserDefault_RemoteLogLevelIsDefaultValue {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.remoteLogLevel, CR_LogSeverityWarning);
}

- (void)testInit_GivenUserDefaultWithRemoteLogLevel_RemoteLogLevelIsProvided {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setInteger:CR_LogSeverityDebug forKey:NSUserDefaultsRemoteLogLevelKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.remoteLogLevel, CR_LogSeverityDebug);
}

- (void)testInit_GivenUserDefaultWithGarbageInRemoteLogLevel_RemoteLogLevelIsDefault {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
  [userDefaults setObject:@"garbage" forKey:NSUserDefaultsRemoteLogLevelKey];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.remoteLogLevel, CR_LogSeverityWarning);
}

- (void)testSetRemoteLogLevel_GivenNoUpdate_NothingIsWrittenInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(config.remoteLogLevel, CR_LogSeverityWarning);
  XCTAssertFalse([userDefaults cr_containsKey:NSUserDefaultsRemoteLogLevelKey]);
}

- (void)testSetRemoteLogLevel_GivenLogLevelSet_WriteItInUserDefaults {
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];

  CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];
  config.remoteLogLevel = CR_LogSeverityInfo;

  CR_Config *newConfig = [[CR_Config alloc] initWithUserDefaults:userDefaults];

  XCTAssertEqual(newConfig.remoteLogLevel, CR_LogSeverityInfo);
  XCTAssertTrue([userDefaults cr_containsKey:NSUserDefaultsRemoteLogLevelKey]);
  XCTAssertEqual([userDefaults integerForKey:NSUserDefaultsRemoteLogLevelKey], CR_LogSeverityInfo);
}

@end
