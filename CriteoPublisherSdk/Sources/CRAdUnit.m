//
//  CRAdUnit.m
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

#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"

@implementation CRAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId adUnitType:(CRAdUnitType)adUnitType {
  if (self = [super init]) {
    _adUnitId = adUnitId;
    _adUnitType = adUnitType;
  }
  return self;
}

- (NSUInteger)hash {
  return _adUnitId.hash ^ (NSUInteger)_adUnitType;
}

- (BOOL)isEqual:(nullable id)object {
  if (object == self) {
    return YES;
  }

  if (![object isKindOfClass:CRAdUnit.class]) {
    return NO;
  }

  return [self isEqualToAdUnit:object];
}

- (BOOL)isEqualToAdUnit:(CRAdUnit *)adUnit {
  return _adUnitType == adUnit->_adUnitType && [_adUnitId isEqualToString:adUnit->_adUnitId];
}

- (NSString *)description {
  NSMutableString *description =
      [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"self.adUnitId=%@", self.adUnitId];
  [description appendString:@">"];
  return description;
}

@end
