//
//  CRInterstitialAdUnit.m
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRInterstitialAdUnit.h"
#import "CRAdUnit+Internal.h"
#import <UIKit/UIKit.h>

@implementation CRInterstitialAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
    self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeInterstitial];
    return self;
}

@end
