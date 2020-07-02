//
//  CR_NativeAdvertiser.m
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

#import "CR_NativeAdvertiser.h"
#import "NSObject+Criteo.h"
#import "NSURL+Criteo.h"
#import "NSString+Criteo.h"

@interface CR_NativeAdvertiser ()

@property(copy, nonatomic) NSString *description;
@property(copy, nonatomic) NSString *domain;
@property(copy, nonatomic) CR_NativeImage *logoImage;
@property(copy, nonatomic) NSString *logoClickUrl;

@end

@implementation CR_NativeAdvertiser

@synthesize description = _description;

- (instancetype)initWithDict:(NSDictionary *)dict {
  self = [super init];
  if (self) {
    _description = [NSString cr_nonEmptyStringWithStringOrNil:dict[@"description"]];
    _domain = [NSString cr_nonEmptyStringWithStringOrNil:dict[@"domain"]];
    _logoImage = [CR_NativeImage nativeImageWithDict:dict[@"logo"]];
    _logoClickUrl = [NSString cr_nonEmptyStringWithStringOrNil:dict[@"logoClickUrl"]];
  }
  return self;
}

+ (CR_NativeAdvertiser *)nativeAdvertiserWithDict:(NSDictionary *)dict {
  if (dict && [dict isKindOfClass:NSDictionary.class]) {
    return [[CR_NativeAdvertiser alloc] initWithDict:dict];
  } else {
    return nil;
  }
}

// Hash values of two CR_NativeAdvertiser objects must be the same if the objects are equal. The
// reverse is not guaranteed (nor does it need to be).
- (NSUInteger)hash {
  return _description.hash ^ _domain.hash ^ _logoImage.hash ^ _logoClickUrl.hash;
}

- (BOOL)isEqual:(id)other {
  if (!other || ![other isMemberOfClass:CR_NativeAdvertiser.class]) {
    return NO;
  }
  CR_NativeAdvertiser *otherAdvertiser = (CR_NativeAdvertiser *)other;
  BOOL result = YES;
  result &= [NSObject cr_object:_description isEqualTo:otherAdvertiser.description];
  result &= [NSObject cr_object:_domain isEqualTo:otherAdvertiser.domain];
  result &= [NSObject cr_object:_logoImage isEqualTo:otherAdvertiser.logoImage];
  result &= [NSObject cr_object:_logoClickUrl isEqualTo:otherAdvertiser.logoClickUrl];
  return result;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
  CR_NativeAdvertiser *copy = [[CR_NativeAdvertiser alloc] init];
  copy.description = self.description;
  copy.domain = self.domain;
  copy.logoImage = self.logoImage;
  copy.logoClickUrl = self.logoClickUrl;
  return copy;
}

@end
