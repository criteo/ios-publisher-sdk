//
//  CR_AppEvents.h
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

#ifndef CR_AppEvents_h
#define CR_AppEvents_h

#import "CR_ApiHandler.h"
#import "CR_DataProtectionConsent.h"
#import "CR_Config.h"
#import "CR_DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_AppEvents : NSObject

@property(readonly, nonatomic) NSUInteger throttleSec;
@property(readonly, nonatomic) NSDate *latestEventSent;
@property(readonly, nonatomic) BOOL throttleExpired;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithApiHandler:(CR_ApiHandler *)apiHandler
                            config:(CR_Config *)config
                           consent:(CR_DataProtectionConsent *)consent
                        deviceInfo:(CR_DeviceInfo *)deviceInfo
                notificationCenter:(NSNotificationCenter *)notificationCenter
    NS_DESIGNATED_INITIALIZER;
- (void)registerForIosEvents;
- (void)sendLaunchEvent;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_AppEvents_h */
