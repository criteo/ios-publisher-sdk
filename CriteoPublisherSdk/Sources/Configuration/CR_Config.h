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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const CR_ConfigCdbUrl;
FOUNDATION_EXTERN NSString *const CR_ConfigAppEventsUrl;
FOUNDATION_EXTERN NSString *const CR_ConfigConfigurationUrl;

@interface CR_Config : NSObject

@property(copy, nonatomic, nullable) NSString *criteoPublisherId;

/**
 ID for differenciate the SDK from other adapters like Publisher tag.
 */
@property(copy, nonatomic, readonly) NSNumber *profileId;
@property(copy, nonatomic, readonly) NSString *cdbUrl;
@property(copy, nonatomic, readonly) NSString *path;
@property(copy, nonatomic, readonly) NSString *csmPath;
@property(copy, nonatomic, readonly) NSString *sdkVersion;
@property(copy, nonatomic, readonly) NSString *appId;
@property(nonatomic) BOOL killSwitch;
@property(copy, nonatomic) NSString *adTagUrlMode;
@property(copy, nonatomic) NSString *viewportWidthMacro;
@property(copy, nonatomic) NSString *displayURLMacro;
@property(copy, nonatomic, readonly) NSString *appEventsUrl;
@property(copy, nonatomic, readonly) NSString *appEventsSenderId;
@property(copy, nonatomic, readonly) NSString *deviceModel;
@property(copy, nonatomic, readonly) NSString *osVersion;
@property(copy, nonatomic, readonly) NSString *deviceOs;
@property(copy, nonatomic, readonly) NSString *configUrl;

/**
 * Return <code>true</code> to indicate if the CSM feature is activated. Else <code>false</code>
 * is returned.
 */
@property(nonatomic, getter=isCsmEnabled) BOOL csmEnabled;

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
