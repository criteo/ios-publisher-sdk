//
//  CR_InternalContextProvider.m
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

#import "CR_InternalContextProvider.h"

#import <sys/utsname.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "CR_Reachability.h"
#import "CR_Session.h"

@interface CR_InternalContextProvider ()
@property(nonatomic, strong) CR_Reachability *reachability;
@property(nonatomic, strong) CR_Session *session;
@end

@implementation CR_InternalContextProvider

#pragma mark - Lifecycle

- (id)initWithSession:(CR_Session *)session {
  if (self = [super init]) {
    self.reachability = [CR_Reachability reachabilityForInternetConnection];
    self.session = session;
  }
  return self;
}

#pragma mark - Public methods

- (nullable NSString *)fetchDeviceMake {
  return @"Apple";
}

- (nullable NSString *)fetchDeviceModel {
  static NSString *model = nil;
  static dispatch_once_t once;

  dispatch_once(&once, ^{
    struct utsname name;
    if (uname(&name) == 0) {
      model = [NSString stringWithUTF8String:name.machine];
    }
  });
  return model;
}

- (CR_DeviceConnectionType)fetchDeviceConnectionType {
  CRNetworkStatus status = [self.reachability currentReachabilityStatus];

  if (status == NotReachable) {
    return CR_DeviceConnectionTypeUnknown;
  } else if (status == ReachableViaWiFi) {
    return CR_DeviceConnectionTypeWifi;
  } else if (status == ReachableViaWWAN) {
    static CTTelephonyNetworkInfo *networkInfo = nil;
    if (networkInfo == nil) {
      networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    NSString *accessTechnology = networkInfo.currentRadioAccessTechnology;
    if ([accessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] ||
        [accessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
        [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
        [accessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
      return CR_DeviceConnectionTypeCellular2G;
    } else if ([accessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] ||
               [accessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] ||
               [accessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] ||
               [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
               [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
               [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
      return CR_DeviceConnectionTypeCellular3G;
    } else if ([accessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
      return CR_DeviceConnectionTypeCellular4G;
    }
    if (@available(iOS 14.1, *)) {
      if ([accessTechnology isEqualToString:CTRadioAccessTechnologyNRNSA] ||
          [accessTechnology isEqualToString:CTRadioAccessTechnologyNR]) {
        return CR_DeviceConnectionTypeCellular5G;
      }
    }

    return CR_DeviceConnectionTypeCellularUnknown;
  }
  return CR_DeviceConnectionTypeUnknown;
}

- (nullable NSString *)fetchUserCountry {
  return [self getPreferredLanguagesComponentForLocaleKey:@"kCFLocaleCountryCodeKey"].firstObject;
}

- (nullable NSArray<NSString *> *)fetchUserLanguages {
  return [self getPreferredLanguagesComponentForLocaleKey:@"kCFLocaleLanguageCodeKey"];
}

- (nullable NSNumber *)fetchDeviceWidth {
  return @(self.screenSize.width * self.screenScale);
}

- (nullable NSNumber *)fetchDeviceHeight {
  return @(self.screenSize.height * self.screenScale);
}

- (nullable NSNumber *)fetchDevicePixelRatio {
  return @(self.screenScale);
}

- (nullable NSString *)fetchDeviceOrientation {
  switch ([UIDevice currentDevice].orientation) {
    case UIDeviceOrientationPortrait:
    case UIDeviceOrientationPortraitUpsideDown:
      return @"Portrait";
    case UIDeviceOrientationLandscapeLeft:
    case UIDeviceOrientationLandscapeRight:
      return @"Landscape";
    default:
      return nil;
  }
}

- (nullable NSNumber *)fetchSessionDuration {
  return @((long)self.session.duration);
}

- (NSDictionary<NSString *, id> *)fetchInternalUserContext {
  NSMutableDictionary<NSString *, id> *dictionary = NSMutableDictionary.new;
  [self setNonNullObject:[self fetchDeviceMake] forKey:@"device.make" inDictionary:dictionary];
  [self setNonNullObject:[self fetchDeviceModel] forKey:@"device.model" inDictionary:dictionary];
  [self setNonNullObject:[self fetchUserCountry]
                  forKey:@"user.geo.country"
            inDictionary:dictionary];
  [self setNonNullObject:[self fetchUserLanguages]
                  forKey:@"data.inputLanguage"
            inDictionary:dictionary];
  [self setNonNullObject:[self fetchDeviceWidth] forKey:@"device.w" inDictionary:dictionary];
  [self setNonNullObject:[self fetchDeviceHeight] forKey:@"device.h" inDictionary:dictionary];
  [self setNonNullObject:[self fetchDevicePixelRatio]
                  forKey:@"device.pxratio"
            inDictionary:dictionary];
  [self setNonNullObject:[self fetchDeviceOrientation]
                  forKey:@"data.orientation"
            inDictionary:dictionary];
  [self setNonNullObject:[self fetchSessionDuration]
                  forKey:@"data.sessionDuration"
            inDictionary:dictionary];

  CR_DeviceConnectionType connectionType = [self fetchDeviceConnectionType];
  if (connectionType != CR_DeviceConnectionTypeUnknown) {
    dictionary[@"device.contype"] = @(connectionType);
  }

  return dictionary;
}

#pragma mark - Private

- (void)setNonNullObject:(id)object
                  forKey:(NSString *)key
            inDictionary:(NSMutableDictionary<NSString *, id> *)dictionary {
  if (object != nil) {
    dictionary[key] = object;
  }
}

- (NSMutableArray<NSString *> *)getPreferredLanguagesComponentForLocaleKey:(NSString *)localeKey {
  NSArray<NSString *> *locales = [NSLocale preferredLanguages];
  NSMutableArray<NSString *> *components = [NSMutableArray arrayWithCapacity:locales.count];
  [locales enumerateObjectsUsingBlock:^(NSString *locale, NSUInteger idx, BOOL *stop) {
    NSDictionary *localeDic = [NSLocale componentsFromLocaleIdentifier:locale];
    NSString *localeComponent = localeDic[localeKey];
    if (localeComponent) {
      [components addObject:localeComponent];
    }
  }];
  return components;
}

- (CGSize)screenSize {
  return [UIScreen mainScreen].bounds.size;
}

- (CGFloat)screenScale {
  return [UIScreen mainScreen].scale;
}

@end