//
//  NSUserDefaults+CR_Config.h
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

#ifndef NSUserDefaults_CR_Config_H
#define NSUserDefaults_CR_Config_H

#import <Foundation/Foundation.h>
#import "CR_LogMessage.h"

@interface NSUserDefaults (CR_Config)

- (BOOL)cr_valueForKillSwitch;

- (void)cr_setValueForKillSwitch:(BOOL)killSwitch;

- (BOOL)cr_valueForCsmEnabled;

- (void)cr_setValueForCsmEnabled:(BOOL)csmEnabled;

- (BOOL)cr_valueForPrefetchOnInitEnabled;

- (void)cr_setValueForPrefetchOnInitEnabled:(BOOL)prefetchOnInitEnabled;

- (BOOL)cr_valueForLiveBiddingEnabled;

- (void)cr_setValueForLiveBiddingEnabled:(BOOL)liveBiddingEnabled;

- (NSTimeInterval)cr_valueForLiveBiddingTimeBudget;

- (void)cr_setValueForLiveBiddingTimeBudget:(NSTimeInterval)timeBudget;

- (CR_LogSeverity)cr_valueForRemoteLogLevel;

- (void)cr_setValueForRemoteLogLevel:(CR_LogSeverity)logLevel;

@end

#endif /* NSUserDefaults_CR_Config_H */
