//
//  CRBidToken.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRBidToken.h"
#import "CRBidToken+Internal.h"

@implementation CRBidToken

- (instancetype)init {
  return [self initWithUUID:nil];
}

- (instancetype)initWithUUID:(NSUUID *)uuid {
  if (self = [super init]) {
    _bidTokenUUID = uuid ? uuid : [NSUUID UUID];
  }
  return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
  return [[CRBidToken alloc] initWithUUID:_bidTokenUUID];
}

- (NSUInteger)hash {
  return _bidTokenUUID.hash;
}

- (BOOL)isEqual:(id)object {
  if ([object isKindOfClass:[CRBidToken class]]) {
    CRBidToken *other = object;
    if ([self.bidTokenUUID isEqual:other.bidTokenUUID]) {
      return YES;
    }
  }
  return NO;
}

@end
