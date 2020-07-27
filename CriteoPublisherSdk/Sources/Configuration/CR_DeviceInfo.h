//
//  CR_DeviceInfo.h
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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class WKWebView;
@class CR_ThreadManager;

#if TARGET_OS_SIMULATOR
#define CR_SIMULATOR_IDFA @"8BADF00D-74BC-43D6-AA75-91D2B271A9A0"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CR_DeviceInfo : NSObject

@property(copy, atomic) NSString *userAgent;
@property(copy, nonatomic, readonly) NSString *deviceId;

/**
 * Full size of the main screen without considering the safe area.
 */
@property(nonatomic, readonly) CGSize screenSize;

/**
 * Size of the main screen when considering the safe area.
 * If there is no safe area, then this returns the same than `screeSize`
 */
@property(nonatomic, readonly) CGSize safeScreenSize;

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager NS_DESIGNATED_INITIALIZER;

- (void)waitForUserAgent:(void (^_Nullable)(void))completion;

- (BOOL)validScreenSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
