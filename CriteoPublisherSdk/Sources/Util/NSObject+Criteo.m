//
//  NSObject+Criteo.m
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

#import "NSObject+Criteo.h"
#import <objc/runtime.h>

@implementation NSObject (Criteo)

+ (BOOL)cr_object:(nullable id)obj1 isEqualTo:(nullable id)obj2 {
  if (obj1) {
    return [obj1 isEqual:obj2];  // isEqual returns NO if obj2 is nil
  } else {
    return !obj2;  // returns YES if obj1 and obj2 are both nil
  }
}

@end
