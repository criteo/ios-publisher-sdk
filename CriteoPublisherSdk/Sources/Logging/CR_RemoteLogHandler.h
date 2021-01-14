//
//  CR_RemoteLogHandler.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2021 Criteo. All rights reserved.
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
#import "CR_LogHandler.h"

@class CR_RemoteLogStorage;
@class CR_Config;
@class CR_DeviceInfo;
@class CR_IntegrationRegistry;
@class CR_Session;
@class CR_DataProtectionConsent;
@class CR_ApiHandler;
@class CR_ThreadManager;

NS_ASSUME_NONNULL_BEGIN

@interface CR_RemoteLogHandler : NSObject <CR_LogHandler>

- (instancetype)initWithRemoteLogStorage:(CR_RemoteLogStorage *)remoteLogStorage
                                  config:(CR_Config *)config
                              deviceInfo:(CR_DeviceInfo *)deviceInfo
                     integrationRegistry:(CR_IntegrationRegistry *)integrationRegistry
                                 session:(CR_Session *)session
                                 consent:(CR_DataProtectionConsent *)consent
                              apiHandler:(CR_ApiHandler *)apiHandler
                           threadManager:(CR_ThreadManager *)threadManager;

- (void)sendRemoteLogBatch;

@end

NS_ASSUME_NONNULL_END
