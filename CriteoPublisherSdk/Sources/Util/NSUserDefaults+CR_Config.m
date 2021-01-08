//
//  NSUserDefaults+CR_Config.m
//  CriteoPublisherSdk
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

#import "NSUserDefaults+CR_Config.h"
#import "NSUserDefaults+Criteo.h"
#import "CRConstants.h"

NSString *const NSUserDefaultsKillSwitchKey = @"CRITEO_KillSwitch";
NSString *const NSUserDefaultsCsmEnabledKey = @"CRITEO_CsmEnabled";
NSString *const NSUserDefaultsPrefetchOnInitEnabledKey = @"CRITEO_PrefetchOnInitEnabled";
NSString *const NSUserDefaultsLiveBiddingEnabledKey = @"CRITEO_LiveBiddingEnabled";
NSString *const NSUserDefaultsLiveBiddingTimeBudgetKey = @"CRITEO_LiveBiddingTimeBudget";
NSString *const NSUserDefaultsRemoteLogLevelKey = @"CRITEO_RemoteLogLevel";

@implementation NSUserDefaults (CR_Config)

- (BOOL)cr_valueForKillSwitch {
  return [self boolForKey:NSUserDefaultsKillSwitchKey withDefaultValue:NO];
}

- (void)cr_setValueForKillSwitch:(BOOL)killSwitch {
  [self setBool:killSwitch forKey:NSUserDefaultsKillSwitchKey];
}

- (BOOL)cr_valueForCsmEnabled {
  return [self boolForKey:NSUserDefaultsCsmEnabledKey withDefaultValue:YES];
}

- (void)cr_setValueForCsmEnabled:(BOOL)csmEnabled {
  [self setBool:csmEnabled forKey:NSUserDefaultsCsmEnabledKey];
}

- (BOOL)cr_valueForPrefetchOnInitEnabled {
  return [self boolForKey:NSUserDefaultsPrefetchOnInitEnabledKey withDefaultValue:YES];
}

- (void)cr_setValueForPrefetchOnInitEnabled:(BOOL)prefetchOnInitEnabled {
  [self setBool:prefetchOnInitEnabled forKey:NSUserDefaultsPrefetchOnInitEnabledKey];
}

- (BOOL)cr_valueForLiveBiddingEnabled {
  return [self boolForKey:NSUserDefaultsLiveBiddingEnabledKey withDefaultValue:NO];
}

- (void)cr_setValueForLiveBiddingEnabled:(BOOL)liveBiddingEnabled {
  [self setBool:liveBiddingEnabled forKey:NSUserDefaultsLiveBiddingEnabledKey];
}

- (NSTimeInterval)cr_valueForLiveBiddingTimeBudget {
  return [self doubleForKey:NSUserDefaultsLiveBiddingTimeBudgetKey
           withDefaultValue:CRITEO_DEFAULT_LIVE_BID_TIME_BUDGET_IN_SECONDS];
}

- (void)cr_setValueForLiveBiddingTimeBudget:(NSTimeInterval)liveBiddingTimeBudget {
  [self setDouble:liveBiddingTimeBudget forKey:NSUserDefaultsLiveBiddingTimeBudgetKey];
}

- (CR_LogSeverity)cr_valueForRemoteLogLevel {
  return (CR_LogSeverity)[self intForKey:NSUserDefaultsRemoteLogLevelKey
                        withDefaultValue:CR_LogSeverityWarning];
}

- (void)cr_setValueForRemoteLogLevel:(CR_LogSeverity)logLevel {
  [self setInteger:logLevel forKey:NSUserDefaultsRemoteLogLevelKey];
}

@end
