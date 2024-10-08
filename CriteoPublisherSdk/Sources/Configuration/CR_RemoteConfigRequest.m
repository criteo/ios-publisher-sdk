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
@property(copy, nonatomic, nullable) NSString *inventoryGroupId;

- (instancetype)initWithCriteoPublisherId:(NSString *)criteoPublisherId
                         inventoryGroupId:(nullable NSString *)inventoryGroupId
                               sdkVersion:(NSString *)sdkVersion
                                    appId:(NSString *)appId
                                profileId:(NSNumber *)profileId
                              deviceModel:(NSString *)deviceModel
                                 deviceOs:(NSString *)deviceOs
                                configUrl:(NSString *)configUrl;

@end

@implementation CR_RemoteConfigRequest

+ (instancetype)requestWithConfig:(CR_Config *)config profileId:(NSNumber *)profileId {
  return [CR_RemoteConfigRequest.alloc initWithCriteoPublisherId:config.criteoPublisherId
                                                inventoryGroupId:config.inventoryGroupId
                                                      sdkVersion:config.sdkVersion
                                                           appId:config.appId
                                                       profileId:profileId
                                                     deviceModel:config.deviceModel
                                                        deviceOs:config.deviceOs
                                                       configUrl:config.configUrl];
}

- (instancetype)initWithCriteoPublisherId:(NSString *)criteoPublisherId
                         inventoryGroupId:(nullable NSString *)inventoryGroupId
                               sdkVersion:(NSString *)sdkVersion
                                    appId:(NSString *)appId
                                profileId:(NSNumber *)profileId
                              deviceModel:(NSString *)deviceModel
                                 deviceOs:(NSString *)deviceOs
                                configUrl:(NSString *)configUrl {
  if (self = [super init]) {
    _criteoPublisherId = criteoPublisherId;
    _inventoryGroupId = inventoryGroupId;
    _sdkVersion = sdkVersion;
    _appId = appId;
    _profileId = profileId;
    _deviceModel = deviceModel;
    _deviceOs = deviceOs;
    _configUrl = configUrl;
  }
  return self;
}

- (NSDictionary *)postBody {
  NSMutableDictionary *body = [NSMutableDictionary dictionary];
  NSDictionary *values = @{
    @"cpId" : self.criteoPublisherId,
    @"bundleId" : self.appId,
    @"sdkVersion" : self.sdkVersion,
    @"rtbProfileId" : self.profileId,
    @"deviceModel" : self.deviceModel,
    @"deviceOs" : self.deviceOs
  };
  [body setValuesForKeysWithDictionary:values];
  if (self.inventoryGroupId != nil) {
    [body setObject:self.inventoryGroupId forKey:@"inventoryGroupId"];
  }
  return body;
}

@end
