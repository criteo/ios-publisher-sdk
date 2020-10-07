//
//  CR_NetworkSessionPlayer.h
//  CriteoPublisherSdkTests
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

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const CR_NetworkManagerSimulatorDefaultCpm;
extern NSString *const CR_NetworkManagerSimulatorDefaultDisplayUrl;
extern const NSTimeInterval CR_NetworkManagerSimulatorInterstitialDefaultTtl;

@class CR_Config;

@interface CR_NetworkManagerSimulator : CR_NetworkManager

@property(class, assign, nonatomic, readonly) NSTimeInterval interstitialTtl;

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo NS_UNAVAILABLE;

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo
                           session:(NSURLSession *)session
                     threadManager:(CR_ThreadManager *)threadManager NS_UNAVAILABLE;

- (instancetype)initWithConfig:(CR_Config *)config
                         delay:(NSTimeInterval)delay NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
