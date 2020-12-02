//
//  CRBannerAdUnit.m
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

#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"

@implementation CRBannerAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size {
  if (self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeBanner]) {
    _size = size;
  }
  return self;
}

- (NSUInteger)hash {
  return [super hash] ^ (NSUInteger)_size.height ^ (NSUInteger)_size.width;
}

- (BOOL)isEqual:(nullable id)object {
  if (self == object) {
    return YES;
  }

  if (![object isKindOfClass:CRBannerAdUnit.class]) {
    return NO;
  }

  return [self isEqualToBannerAdUnit:object];
}

- (BOOL)isEqualToBannerAdUnit:(CRBannerAdUnit *)adUnit {
  return CGSizeEqualToSize(_size, adUnit->_size) && [self isEqualToAdUnit:adUnit];
}

- (NSString *)description {
  NSMutableString *description =
      [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"self.adUnitId=%@", self.adUnitId];
  [description appendFormat:@", self.size=%@", NSStringFromCGSize(self.size)];
  [description appendString:@">"];
  return description;
}

@end
