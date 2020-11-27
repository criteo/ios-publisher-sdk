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

@implementation CR_InternalContextProvider


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
  return CR_DeviceConnectionTypeUnknown;  // TODO EE-1315
}

- (nullable NSString *)fetchUserCountry {
  return nil;  // TODO EE-1315
}

- (nullable NSArray<NSString *> *)fetchUserLanguages {
  return nil;  // TODO EE-1315
}

- (nullable NSNumber *)fetchDeviceWidth {
  return nil;  // TODO EE-1315
}

- (nullable NSNumber *)fetchDeviceHeight {
  return nil;  // TODO EE-1315
}

- (nullable NSString *)fetchDeviceOrientation {
  return nil;  // TODO EE-1315
}

- (nullable NSNumber *)fetchSessionDuration {
  return nil;  // TODO EE-1315
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

- (void)setNonNullObject:(id)object
                  forKey:(NSString *)key
            inDictionary:(NSMutableDictionary<NSString *, id> *)dictionary {
  if (object != nil) {
    dictionary[key] = object;
  }
}

@end