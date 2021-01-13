//
//  CR_Config.h
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

#ifndef CR_Config_h
#define CR_Config_h

#import <Foundation/Foundation.h>
#import "CR_LogMessage.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const CR_ConfigCdbUrl;
FOUNDATION_EXTERN NSString *const CR_ConfigAppEventsUrl;
FOUNDATION_EXTERN NSString *const CR_ConfigConfigurationUrl;

@interface CR_Config : NSObject

#pragma mark - Properties

@property(copy, nonatomic, nullable) NSString *criteoPublisherId;
@property(assign, nonatomic) BOOL killSwitch;
@property(copy, nonatomic) NSString *adTagUrlMode;
@property(copy, nonatomic) NSString *viewportWidthMacro;
@property(copy, nonatomic) NSString *displayURLMacro;

#pragma mark CSM

@property(assign, nonatomic, getter=isCsmEnabled) BOOL csmEnabled;

#pragma mark Prefetch

@property(assign, nonatomic, getter=isPrefetchOnInitEnabled) BOOL prefetchOnInitEnabled;

#pragma mark Live Bidding

@property(assign, nonatomic, getter=isLiveBiddingEnabled) BOOL liveBiddingEnabled;
@property(assign, nonatomic) NSTimeInterval liveBiddingTimeBudget;

#pragma mark Logging

@property(assign, nonatomic) CR_LogSeverity remoteLogLevel;

#pragma mark Read only

@property(nonatomic, readonly) NSString *cdbUrl;
@property(nonatomic, readonly) NSString *path;
@property(nonatomic, readonly) NSString *csmPath;
@property(nonatomic, readonly) NSString *logsPath;
@property(nonatomic, readonly) NSString *sdkVersion;
@property(nonatomic, readonly) NSString *appId;
@property(nonatomic, readonly) NSString *appEventsUrl;
@property(nonatomic, readonly) NSString *appEventsSenderId;
@property(nonatomic, readonly) NSString *deviceModel;
@property(nonatomic, readonly) NSString *osVersion;
@property(nonatomic, readonly) NSString *deviceOs;
@property(nonatomic, readonly) NSString *configUrl;

#pragma mark - Lifecycle

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
                                   cdbUrl:(NSString *)cdbUrl
                             appEventsUrl:(NSString *)appEventsUrl
                                configUrl:(NSString *)configUrl
                             userDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;

/*
 * Helper function to convert NSData returned from a network call
 * to an NSDictionary with config values
 */
+ (NSDictionary *)getConfigValuesFromData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_Config_h */
