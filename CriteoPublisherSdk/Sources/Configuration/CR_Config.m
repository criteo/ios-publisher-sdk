//
//  CR_Config.m
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

#import <UIKit/UIKit.h>

#import "CR_Config.h"
#import "CRConstants.h"
#import "CR_Logging.h"
#import "NSUserDefaults+CR_Config.h"

#if false && DEBUG && TARGET_IPHONE_SIMULATOR  // toggle if need to test against wiremock
// target local wiremock when debug & simulator
NSString *const CR_ConfigCdbUrl = @"https://localhost:9099";
#else
// Production
NSString *const CR_ConfigCdbUrl = @"https://bidder.criteo.com";
#endif
NSString *const CR_ConfigAppEventsUrl = @"https://gum.criteo.com/appevent/v1";
NSString *const CR_ConfigConfigurationUrl = @"https://bidder.criteo.com/config/app";

@interface CR_Config ()

@property(nonatomic, strong, readonly) NSUserDefaults *userDefaults;

@end

@implementation CR_Config

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
                         inventoryGroupId:(nullable NSString *)inventoryGroupId
                                  storeId:(nullable NSString *)storeId
                                   cdbUrl:(NSString *)cdbUrl
                             appEventsUrl:(NSString *)appEventsUrl
                                configUrl:(NSString *)configUrl
                             userDefaults:(NSUserDefaults *)userDefaults {
  if (self = [super init]) {
    _criteoPublisherId = criteoPublisherId;
    _cdbUrl = [cdbUrl copy];
    _path = @"inapp/v2";
    _csmPath = @"csm";
    _logsPath = @"inapp/logs";
    _sdkVersion = CRITEO_PUBLISHER_SDK_VERSION;
    _appId = [[NSBundle mainBundle] bundleIdentifier];
    _killSwitch = [userDefaults cr_valueForKillSwitch];
    _deviceModel = [[UIDevice currentDevice] model];
    _osVersion = [[UIDevice currentDevice] systemVersion];
    _deviceOs = @"ios";
    _appEventsUrl = [appEventsUrl copy];
    _appEventsSenderId = @"2379";
    _adTagUrlMode =
        @"<!doctype html><html><head><meta charset=\"utf-8\"><style>body{margin:0;padding:0}</style><meta name=\"viewport\" content=\"width=%%width%%, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\" ></head><body><script src=\"%%displayUrl%%\"></script></body></html>";
    _viewportWidthMacro = @"%%width%%";
    _displayURLMacro = @"%%displayUrl%%";
    _configUrl = [configUrl copy];
    _csmEnabled = [userDefaults cr_valueForCsmEnabled];
    _prefetchOnInitEnabled = [userDefaults cr_valueForPrefetchOnInitEnabled];
    _liveBiddingEnabled = [userDefaults cr_valueForLiveBiddingEnabled];
    _liveBiddingTimeBudget = [userDefaults cr_valueForLiveBiddingTimeBudget];
    _remoteLogLevel = [userDefaults cr_valueForRemoteLogLevel];
    _userDefaults = userDefaults;
    _mraidEnabled = [userDefaults cr_valueForMRAID];
    _mraid2Enabled = [userDefaults cr_valueForMRAID2];
    _isMRAIDGlobalEnabled = _mraidEnabled || _mraid2Enabled;
    _storeId = storeId;
    _inventoryGroupId = inventoryGroupId;
  }
  return self;
}

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId {
  return [self initWithCriteoPublisherId:criteoPublisherId
                        inventoryGroupId:nil
                                 storeId:nil
                                  cdbUrl:CR_ConfigCdbUrl
                            appEventsUrl:CR_ConfigAppEventsUrl
                               configUrl:CR_ConfigConfigurationUrl
                            userDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
                         inventoryGroupId:(nullable NSString *)inventoryGroupId {
  return [self initWithCriteoPublisherId:criteoPublisherId
                        inventoryGroupId:inventoryGroupId
                                 storeId:nil
                                  cdbUrl:CR_ConfigCdbUrl
                            appEventsUrl:CR_ConfigAppEventsUrl
                               configUrl:CR_ConfigConfigurationUrl
                            userDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
                         inventoryGroupId:(nullable NSString *)inventoryGroupId
                                  storeId:(nullable NSString *)storeId {
  return [self initWithCriteoPublisherId:criteoPublisherId
                        inventoryGroupId:inventoryGroupId
                                 storeId:storeId
                                  cdbUrl:CR_ConfigCdbUrl
                            appEventsUrl:CR_ConfigAppEventsUrl
                               configUrl:CR_ConfigConfigurationUrl
                            userDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)init {
  return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  return [self initWithCriteoPublisherId:nil
                        inventoryGroupId:nil
                                 storeId:nil
                                  cdbUrl:CR_ConfigCdbUrl
                            appEventsUrl:CR_ConfigAppEventsUrl
                               configUrl:CR_ConfigConfigurationUrl
                            userDefaults:userDefaults];
}

- (void)setKillSwitch:(BOOL)killSwitch {
  _killSwitch = killSwitch;
  [self.userDefaults cr_setValueForKillSwitch:killSwitch];
}

- (void)setCsmEnabled:(BOOL)csmEnabled {
  _csmEnabled = csmEnabled;
  [self.userDefaults cr_setValueForCsmEnabled:csmEnabled];
}

- (void)setPrefetchOnInitEnabled:(BOOL)prefetchOnInitEnabled {
  _prefetchOnInitEnabled = prefetchOnInitEnabled;
  [self.userDefaults cr_setValueForPrefetchOnInitEnabled:prefetchOnInitEnabled];
}

- (void)setLiveBiddingEnabled:(BOOL)liveBiddingEnabled {
  _liveBiddingEnabled = liveBiddingEnabled;
  [self.userDefaults cr_setValueForLiveBiddingEnabled:liveBiddingEnabled];
}

- (void)setLiveBiddingTimeBudget:(NSTimeInterval)liveBiddingTimeBudget {
  _liveBiddingTimeBudget = liveBiddingTimeBudget;
  [self.userDefaults cr_setValueForLiveBiddingTimeBudget:liveBiddingTimeBudget];
}

- (void)setRemoteLogLevel:(CR_LogSeverity)remoteLogLevel {
  _remoteLogLevel = remoteLogLevel;
  [self.userDefaults cr_setValueForRemoteLogLevel:remoteLogLevel];
}

- (void)setMraidEnabled:(BOOL)mraidEnabled {
  _mraidEnabled = mraidEnabled;
  [self.userDefaults cr_setValueForMRAID:mraidEnabled];
}

- (void)setMraid2Enabled:(BOOL)mraid2Enabled {
  _mraid2Enabled = mraid2Enabled;
  [self.userDefaults cr_setValueForMRAID2:mraid2Enabled];
}

+ (NSDictionary *)getConfigValuesFromData:(NSData *)data {
  NSError *e = nil;
  NSMutableDictionary *configValues = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:&e];
  if (!configValues) {
    CRLogWarn(@"Config", @"Failed parsing config values: %@", e);
  }
  return configValues;
}

@end
