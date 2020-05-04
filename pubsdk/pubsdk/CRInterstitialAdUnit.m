//
//  CRInterstitialAdUnit.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRInterstitialAdUnit.h"
#import "CRAdUnit+Internal.h"
#import <UIKit/UIKit.h>

@implementation CRInterstitialAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
    self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeInterstitial];
    return self;
}

- (NSUInteger) hash
{
    return super.hash ^ (NSUInteger)14559042078869117629ull;
}

- (BOOL) isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:CRInterstitialAdUnit.class]) {
        return NO;
    }

    return [self isEqualToInterstitialAdUnit:object];
}

- (BOOL) isEqualToInterstitialAdUnit:(CRInterstitialAdUnit *)adUnit
{
    return [adUnit isMemberOfClass:self.class] && [self isEqualToAdUnit:adUnit];
}

@end
