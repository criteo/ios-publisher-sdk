//
//  CR_TokenValue.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CR_TokenValue.h"
#import "CR_CdbBid.h"

@interface CR_TokenValue ()

@property(readonly, nonatomic) CR_CdbBid *cdbBid;

@end

@implementation CR_TokenValue

- (instancetype)initWithCdbBid:(CR_CdbBid *)cdbBid adUnit:(CRAdUnit *)adUnit {
  if (self = [super init]) {
    _cdbBid = cdbBid;
    _adUnit = adUnit;
  }
  return self;
}

- (NSString *)displayUrl {
  return self.cdbBid.displayUrl;
}

- (CR_NativeAssets *)nativeAssets {
  return self.cdbBid.nativeAssets;
}

- (BOOL)isExpired {
  return self.cdbBid.isExpired;
}

- (BOOL)isEqual:(id)other {
  if (other == self) return YES;
  if (!other || ![[other class] isEqual:[self class]]) return NO;

  return [self isEqualToValue:other];
}

- (BOOL)isEqualToValue:(CR_TokenValue *)value {
  if (self == value) return YES;
  if (value == nil) return NO;
  if (self.adUnit != value.adUnit && ![self.adUnit isEqualToAdUnit:value.adUnit]) return NO;
  if (self.cdbBid != value.cdbBid && ![self.cdbBid isEqual:value.cdbBid]) return NO;
  return YES;
}

- (NSUInteger)hash {
  NSUInteger hash = [self.adUnit hash];
  hash = hash * 31u + [self.cdbBid hash];
  return hash;
}

@end
