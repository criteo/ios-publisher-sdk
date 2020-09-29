//
//  CR_ConfigManager.h
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

#ifndef CR_ConfigManager_h
#define CR_ConfigManager_h

#import <Foundation/Foundation.h>
#import "CR_ApiHandler.h"
#import "CR_Config.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_ConfigManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithApiHandler:(CR_ApiHandler *)apiHandler
               integrationRegistry:(CR_IntegrationRegistry *)integrationRegistry
                        deviceInfo:(CR_DeviceInfo *)deviceInfo NS_DESIGNATED_INITIALIZER;
- (void)refreshConfig:(CR_Config *)config;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_ConfigManager_h */
