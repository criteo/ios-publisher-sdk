//
//  CRAdUnit.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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

@end
