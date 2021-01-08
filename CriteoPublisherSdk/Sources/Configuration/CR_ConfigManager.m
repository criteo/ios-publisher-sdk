//
//  CR_ConfigManager.m
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

#import "CR_ConfigManager.h"
#import "CR_RemoteConfigRequest.h"
#import "CR_IntegrationRegistry.h"

@implementation CR_ConfigManager {
  CR_ApiHandler *_apiHandler;
  CR_IntegrationRegistry *_integrationRegistry;
  CR_DeviceInfo *_deviceInfo;
}

- (instancetype)initWithApiHandler:(CR_ApiHandler *)apiHandler
               integrationRegistry:(CR_IntegrationRegistry *)integrationRegistry
                        deviceInfo:(CR_DeviceInfo *)deviceInfo {
  if (self = [super init]) {
    _apiHandler = apiHandler;
    _integrationRegistry = integrationRegistry;
    _deviceInfo = deviceInfo;
  }

  return self;
}

- (void)refreshConfig:(CR_Config *)config {
  CR_RemoteConfigRequest *request =
      [CR_RemoteConfigRequest requestWithConfig:config
                                      profileId:_integrationRegistry.profileId
                                       deviceId:_deviceInfo.deviceId];
  [_apiHandler getConfig:request
         ahConfigHandler:^(NSDictionary *configValues) {
           if (configValues[@"killSwitch"] &&
               [configValues[@"killSwitch"] isKindOfClass:NSNumber.class]) {
             config.killSwitch = ((NSNumber *)configValues[@"killSwitch"]).boolValue;
           }
           if (configValues[@"csmEnabled"] &&
               [configValues[@"csmEnabled"] isKindOfClass:NSNumber.class]) {
             config.csmEnabled = ((NSNumber *)configValues[@"csmEnabled"]).boolValue;
           }
           if (configValues[@"prefetchOnInitEnabled"] &&
               [configValues[@"prefetchOnInitEnabled"] isKindOfClass:NSNumber.class]) {
             config.prefetchOnInitEnabled =
                 ((NSNumber *)configValues[@"prefetchOnInitEnabled"]).boolValue;
           }
           if (configValues[@"liveBiddingEnabled"] &&
               [configValues[@"liveBiddingEnabled"] isKindOfClass:NSNumber.class]) {
             config.liveBiddingEnabled =
                 ((NSNumber *)configValues[@"liveBiddingEnabled"]).boolValue;
           }
           if (configValues[@"liveBiddingTimeBudgetInMillis"] &&
               [configValues[@"liveBiddingTimeBudgetInMillis"] isKindOfClass:NSNumber.class]) {
             double timeBudgetInMillis =
                 ((NSNumber *)configValues[@"liveBiddingTimeBudgetInMillis"]).doubleValue;
             config.liveBiddingTimeBudget = timeBudgetInMillis / 1000;
           }
           if (configValues[@"iOSAdTagUrlMode"] &&
               [configValues[@"iOSAdTagUrlMode"] isKindOfClass:NSString.class]) {
             config.adTagUrlMode = (NSString *)configValues[@"iOSAdTagUrlMode"];
           }
           if (configValues[@"iOSDisplayUrlMacro"] &&
               [configValues[@"iOSDisplayUrlMacro"] isKindOfClass:NSString.class]) {
             config.displayURLMacro = (NSString *)configValues[@"iOSDisplayUrlMacro"];
           }
           if (configValues[@"iOSWidthMacro"] &&
               [configValues[@"iOSWidthMacro"] isKindOfClass:NSString.class]) {
             config.viewportWidthMacro = (NSString *)configValues[@"iOSWidthMacro"];
           }
           if (configValues[@"remoteLogLevel"] &&
               [configValues[@"remoteLogLevel"] isKindOfClass:NSString.class]) {
             NSString *remoteLogLevel = (NSString *)configValues[@"remoteLogLevel"];
             if ([remoteLogLevel isEqualToString:@"Debug"]) {
               config.remoteLogLevel = CR_LogSeverityDebug;
             } else if ([remoteLogLevel isEqualToString:@"Info"]) {
               config.remoteLogLevel = CR_LogSeverityInfo;
             } else if ([remoteLogLevel isEqualToString:@"Warning"]) {
               config.remoteLogLevel = CR_LogSeverityWarning;
             } else if ([remoteLogLevel isEqualToString:@"Error"]) {
               config.remoteLogLevel = CR_LogSeverityError;
             } else if ([remoteLogLevel isEqualToString:@"None"]) {
               config.remoteLogLevel = CR_LogSeverityNone;
             }
           }
         }];
}

@end
