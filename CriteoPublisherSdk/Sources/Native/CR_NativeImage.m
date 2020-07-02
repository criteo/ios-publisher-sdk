//
//  CR_NativeImage.m
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

#import "CR_NativeImage.h"
#import "NSObject+Criteo.h"
#import "NSString+Criteo.h"

// Writable properties for internal use
@interface CR_NativeImage ()

@property(copy, nonatomic) NSString *url;
@property int width;
@property int height;

@end

@implementation CR_NativeImage

- (instancetype)initWithDict:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    _url = [NSString cr_nonEmptyStringWithStringOrNil:dict[@"url"]];
    _width = [(NSNumber *)dict[@"width"] intValue];
    _height = [(NSNumber *)dict[@"height"] intValue];
  }
  return self;
}

+ (CR_NativeImage *)nativeImageWithDict:(NSDictionary *)dict {
  if (dict && [dict isKindOfClass:NSDictionary.class]) {
    return [[CR_NativeImage alloc] initWithDict:dict];
  } else {
    return nil;
  }
}

// Hash values of two CR_NativeImage objects must be the same if the objects are equal. The reverse
// is not guaranteed (nor does it need to be).
- (NSUInteger)hash {
  return _url.hash ^ (NSUInteger)_width ^ (NSUInteger)_height;
}

- (BOOL)isEqual:(id)other {
  if (!other || ![other isMemberOfClass:CR_NativeImage.class]) {
    return NO;
  }
  CR_NativeImage *otherImage = (CR_NativeImage *)other;
  BOOL result = YES;
  result &= [NSObject cr_object:_url isEqualTo:otherImage.url];
  result &= _width == otherImage.width;
  result &= _height == otherImage.height;
  return result;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
  CR_NativeImage *copy = [[CR_NativeImage alloc] init];
  copy.url = self.url;
  copy.width = self.width;
  copy.height = self.height;
  return copy;
}

@end
