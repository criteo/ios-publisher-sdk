//
//  CRNativeAdUnit.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAdUnit.h"
#import "CRAdUnit+Internal.h"

@implementation CRNativeAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
    self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeNative];
    return self;
}

- (NSUInteger) hash {
    return self.adUnitId.hash ^ (NSUInteger)11748390512345843219ull;
}

- (BOOL)isEqual:(id)other {
    if (!other || ![other isMemberOfClass:CRNativeAdUnit.class]) { return NO; }
    return [self isEqualToNativeAdUnit:(CRNativeAdUnit *)other];
}

- (BOOL)isEqualToNativeAdUnit:(CRNativeAdUnit *)other {
    return [self.adUnitId isEqualToString:other.adUnitId];
}

@end
