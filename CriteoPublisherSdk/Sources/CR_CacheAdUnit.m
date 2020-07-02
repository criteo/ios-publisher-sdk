//
//  CR_CacheAdUnit.m
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

#import "CR_CacheAdUnit.h"

@implementation CR_CacheAdUnit {
  NSUInteger _hash;
}

+ (instancetype)cacheAdUnitForInterstialWithAdUnitId:(NSString *)adUnitId size:(CGSize)size {
  return [[CR_CacheAdUnit alloc] initWithAdUnitId:adUnitId
                                             size:size
                                       adUnitType:CRAdUnitTypeInterstitial];
}

- (instancetype)init {
  CGSize size = CGSizeMake(0.0, 0.0);
  return [self initWithAdUnitId:@"" size:size adUnitType:CRAdUnitTypeBanner];
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                            size:(CGSize)size
                      adUnitType:(CRAdUnitType)adUnitType {
  if (self = [super init]) {
    _adUnitId = adUnitId;
    _size = size;
    _adUnitType = adUnitType;
    // to get rid of the decimal point
    NSUInteger width = roundf(size.width);
    NSUInteger height = roundf(size.height);
    _hash = [[NSString stringWithFormat:@"%@_x_%lu_x_%lu_x_%@", _adUnitId, (unsigned long)width,
                                        (unsigned long)height, @(_adUnitType)] hash];
  }
  return self;
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId width:(CGFloat)width height:(CGFloat)height {
  CGSize size = CGSizeMake(width, height);
  return [self initWithAdUnitId:adUnitId size:size adUnitType:CRAdUnitTypeBanner];
}

- (NSUInteger)hash {
  return _hash;
}

- (BOOL)isEqual:(nullable id)object {
  if (![object isKindOfClass:[CR_CacheAdUnit class]]) {
    return NO;
  }
  CR_CacheAdUnit *obj = (CR_CacheAdUnit *)object;
  return self.hash == obj.hash;
}

- (BOOL)isValid {
  return self.adUnitId.length > 0 && roundf(self.size.width) > 0 && roundf(self.size.height) > 0;
}

- (instancetype)copyWithZone:(NSZone *)zone {
  CR_CacheAdUnit *copy = [[CR_CacheAdUnit alloc] initWithAdUnitId:self.adUnitId
                                                             size:self.size
                                                       adUnitType:self.adUnitType];
  return copy;
}

- (NSString *)cdbSize {
  return [NSString
      stringWithFormat:@"%lux%lu", (unsigned long)self.size.width, (unsigned long)self.size.height];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ adUnitId: %@", super.description, self.adUnitId];
}
@end
