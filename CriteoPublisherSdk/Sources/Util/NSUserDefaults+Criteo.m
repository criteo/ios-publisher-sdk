//
//  NSUserDefaults+Criteo.m
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

#import "NSUserDefaults+Criteo.h"

@implementation NSUserDefaults (Criteo)

- (BOOL)cr_containsKey:(NSString *)key {
  return ([self objectForKey:key] != nil);
}

- (BOOL)boolForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue {
  id value = [self objectForKey:key];
  if (value && [value isKindOfClass:NSNumber.class]) {
    return ((NSNumber *)value).boolValue;
  }
  return defaultValue;
}

- (double)doubleForKey:(NSString *)key withDefaultValue:(double)defaultValue {
  id value = [self objectForKey:key];
  if (value && [value isKindOfClass:NSNumber.class]) {
    return ((NSNumber *)value).doubleValue;
  }
  return defaultValue;
}

- (int)intForKey:(NSString *)key withDefaultValue:(int)defaultValue {
  id value = [self objectForKey:key];
  if (value && [value isKindOfClass:NSNumber.class]) {
    return ((NSNumber *)value).intValue;
  }
  return defaultValue;
}

@end
