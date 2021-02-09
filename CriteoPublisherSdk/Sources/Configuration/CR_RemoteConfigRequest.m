//
//  CR_RemoteConfigRequest.m
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

#import "CR_RemoteConfigRequest.h"
#import "CR_Config.h"

@interface CR_RemoteConfigRequest ()

@property(copy, nonatomic) NSString *criteoPublisherId;
@property(copy, nonatomic) NSString *sdkVersion;
@property(copy, nonatomic) NSString *appId;
@property(copy, nonatomic) NSNumber *profileId;
@property(copy, nonatomic) NSString *deviceModel;
@property(copy, nonatomic) NSString *deviceOs;
@property(copy, nonatomic) NSString *deviceId;

- (instancetype)initWithCriteoPublisherId:(NSString *)criteoPublisherId
                               sdkVersion:(NSString *)sdkVersion
                                    appId:(NSString *)appId
                                profileId:(NSNumber *)profileId
                              deviceModel:(NSString *)deviceModel
                                 deviceOs:(NSString *)deviceOs
                                 deviceId:(NSString *)deviceId
                                configUrl:(NSString *)configUrl;

@end

@implementation CR_RemoteConfigRequest

+ (instancetype)requestWithConfig:(CR_Config *)config
                        profileId:(NSNumber *)profileId
                         deviceId:(NSString *)deviceId {
  return [CR_RemoteConfigRequest.alloc initWithCriteoPublisherId:config.criteoPublisherId
                                                      sdkVersion:config.sdkVersion
                                                           appId:config.appId
                                                       profileId:profileId
                                                     deviceModel:config.deviceModel
                                                        deviceOs:config.deviceOs
                                                        deviceId:deviceId
                                                       configUrl:config.configUrl];
}

- (instancetype)initWithCriteoPublisherId:(NSString *)criteoPublisherId
                               sdkVersion:(NSString *)sdkVersion
                                    appId:(NSString *)appId
                                profileId:(NSNumber *)profileId
                              deviceModel:(NSString *)deviceModel
                                 deviceOs:(NSString *)deviceOs
                                 deviceId:(NSString *)deviceId
                                configUrl:(NSString *)configUrl {
  if (self = [super init]) {
    _criteoPublisherId = criteoPublisherId;
    _sdkVersion = sdkVersion;
    _appId = appId;
    _profileId = profileId;
    _deviceModel = deviceModel;
    _deviceOs = deviceOs;
    _deviceId = deviceId;
    _configUrl = configUrl;
  }
  return self;
}

- (NSDictionary *)postBody {
  return @{
    @"cpId" : self.criteoPublisherId,
    @"bundleId" : self.appId,
    @"sdkVersion" : self.sdkVersion,
    @"rtbProfileId" : self.profileId,
    @"deviceModel" : self.deviceModel,
    @"deviceOs" : self.deviceOs,
    @"deviceId" : self.deviceId
  };
}

@end