//
//  CRBannerAdUnit.m
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"

@implementation CRBannerAdUnit

- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                             size:(CGSize)size {
    if(self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeBanner]) {
        _size = size;
    }
    return self;
}

- (NSUInteger) hash
{
    return [super hash] ^ (NSUInteger)_size.height ^ (NSUInteger)_size.width;
}

- (BOOL) isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:CRBannerAdUnit.class]) {
        return NO;
    }

    return [self isEqualToBannerAdUnit:object];
}

- (BOOL) isEqualToBannerAdUnit:(CRBannerAdUnit *)adUnit
{
    return CGSizeEqualToSize(_size, adUnit->_size) && [self isEqualToAdUnit:adUnit];
}

@end
