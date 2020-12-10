//
//  CR_InternalContextProvider.h
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

@class CR_Session;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CR_DeviceConnectionType) {
  CR_DeviceConnectionTypeUnknown = 0,  // Represent null value
  CR_DeviceConnectionTypeWired = 1,
  CR_DeviceConnectionTypeWifi = 2,
  CR_DeviceConnectionTypeCellularUnknown = 3,
  CR_DeviceConnectionTypeCellular2G = 4,
  CR_DeviceConnectionTypeCellular3G = 5,
  CR_DeviceConnectionTypeCellular4G = 6,
  CR_DeviceConnectionTypeCellular5G = 7,
};

@interface CR_InternalContextProvider : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (id)initWithSession:(CR_Session *)session;

/**
 * Device make (e.g., "Apple")
 *
 * @remark OpenRTB field: `device.make`
 */
- (nullable NSString *)fetchDeviceMake;

/**
 * Device model (e.g., “iPhone10,1” when the specific device model is known, “iPhone” otherwise).
 * The value obtained from the device O/S should be used when available.
 *
 * @remark OpenRTB field: `device.model`
 */
- (nullable NSString *)fetchDeviceModel;

/**
 * Network connection type.
 *
 * @remark OpenRTB field: `device.contype`
 */
- (CR_DeviceConnectionType)fetchDeviceConnectionType;

/**
 * ### Geo object
 * This object encapsulates various methods for specifying a geographic location. [...]. When
 * subordinate to a User object, it indicates the location of the user's home base (i.e., not
 * necessarily their current location).
 *
 * ### Country property
 * Country code using ISO-3166-1-alpha-2.
 * *Note that alpha-3 codes may be encountered and vendors are encouraged to be tolerant of them.*
 *
 * @remark OpenRTB field: `user.geo.country`
 */
- (nullable NSString *)fetchUserCountry;

/**
 * A string array containing the languages setup on the user's device keyboard. Country codes
 * (ISO-3166-1-alpha-2) are passed in the string array, where "en", "he" = English and Hebrew
 * languages are enabled on the user's device keyboard
 *
 * @remark Custom field: `data.inputLanguage`
 */
- (nullable NSArray<NSString *> *)fetchUserLanguages;

/**
 * Physical width of the screen in pixels.
 *
 * @remark OpenRTB field: `device.w`
 */
- (nullable NSNumber *)fetchDeviceWidth;

/**
 * Physical height of the screen in pixels.
 *
 * @remark OpenRTB field: `device.h`
 */
- (nullable NSNumber *)fetchDeviceHeight;

/**
 * The ratio of physical pixels to device independent pixels.
 *
 * @remark OpenRTB field: `device.pxratio`
 */
- (nullable NSNumber *)fetchDevicePixelRatio;

/**
 * Screen orientation ("Portrait" or "Landscape")
 *
 * @remark Custom field: `data.orientation`
 */
- (nullable NSString *)fetchDeviceOrientation;

/**
 * The total duration of time a user has spent so far in a specific app session expressed in
 * seconds. For example, a user has been playing Word Game for 45 seconds
 *
 * This duration is approximate: it is the duration since the initialization of the SDK.
 *
 * @remark Custom field: `data.sessionDuration`
 */
- (nullable NSNumber *)fetchSessionDuration;

- (NSDictionary<NSString *, id> *)fetchInternalUserContext;

@end

NS_ASSUME_NONNULL_END
