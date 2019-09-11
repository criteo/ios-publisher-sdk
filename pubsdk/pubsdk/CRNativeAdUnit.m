//
//  CRNativeAdUnit.m
//  pubsdk
//
//  Created by Richard Clark on 9/10/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRNativeAdUnit.h"
#import "CRAdUnit+Internal.h"

@implementation CRNativeAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
    self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeNative];
    return self;
}

- (NSUInteger) hash {
    return super.hash ^ (NSUInteger)11748390512345843219ull;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:CRNativeAdUnit.class]) {
        return NO;
    }
    return [self isEqualToNativeAdUnit:object];
}

- (BOOL) isEqualToNativeAdUnit:(CRNativeAdUnit *)adUnit {
    return [adUnit isMemberOfClass:self.class] && [self isEqualToAdUnit:adUnit];
}

@end
