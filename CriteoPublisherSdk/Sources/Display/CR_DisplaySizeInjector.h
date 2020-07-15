//
//  CR_DisplaySizeInjector.h
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

@class CR_DeviceInfo;

NS_ASSUME_NONNULL_BEGIN

@interface CR_DisplaySizeInjector : NSObject

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo;

/**
 * Inject parameters to resize the given display URL accordingly to the current full screen size.
 *
 * Safe area is ignored and the size of the whole screen is injected here.
 *
 * @param displayUrl the AJS display URL to decorate
 * @return display URL with injected query parameters
 */
- (NSString *)injectFullScreenSizeInDisplayUrl:(NSString *)displayUrl;

/**
 * Inject parameters to resize the given display URL accordingly to the current full screen size.
 *
 * Safe area is respected and only its size is injected.
 *
 * @param displayUrl the AJS display URL to decorate
 * @return display URL with injected query parameters
 */
- (NSString *)injectSafeScreenSizeInDisplayUrl:(NSString *)displayUrl;

@end

NS_ASSUME_NONNULL_END
