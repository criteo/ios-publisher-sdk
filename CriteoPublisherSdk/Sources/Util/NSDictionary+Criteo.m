//
//  NSDictionary+Criteo.m
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

#import "NSDictionary+Criteo.h"

@implementation NSDictionary (Criteo)

- (NSDictionary *)cr_dictionaryWithNewValue:(nullable id)value forKey:(id)key {
  NSMutableDictionary *mutableDict = [NSMutableDictionary new];
  [mutableDict addEntriesFromDictionary:self];
  mutableDict[key] = value;
  return mutableDict;
}

- (nullable NSDictionary *)cr_dictionaryWithNewValue:(nullable id)value forKeys:(NSArray *)keys {
  if (keys.count == 0) {
    return nil;
  }
  id key = keys[0];
  if (!key) {
    return nil;
  }
  if (keys.count == 1) {
    return [self cr_dictionaryWithNewValue:value forKey:key];
  } else {
    if (!self[key] || ![self[key] isKindOfClass:NSDictionary.class]) {
      return nil;
    }
    NSDictionary *subDict = self[key];
    NSArray *remainingKeys = [keys subarrayWithRange:NSMakeRange(1, keys.count - 1)];
    NSDictionary *modifiedSubDict = [subDict cr_dictionaryWithNewValue:value forKeys:remainingKeys];
    if (!modifiedSubDict) {
      return nil;
    }
    return [self cr_dictionaryWithNewValue:modifiedSubDict forKey:key];
  }
}

@end
