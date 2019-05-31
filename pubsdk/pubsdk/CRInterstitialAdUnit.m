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

//needs to be sorted from smallest to largest in width
static const CGSize supportedInterstitialSizes[] = {
    { .width = 320.0, .height = 480.0 },
    { .width = 360.0, .height = 640.0 },
    { .width = 480.0, .height = 320.0 },
    { .width = 640.0, .height = 360.0 }
};

+ (CGSize)interstitialSizeForCurrentScreenOrientation:(CGSize)screenSize {
    CGSize interstitialSize = supportedInterstitialSizes[0];
    for (int i = 0; i < ((sizeof supportedInterstitialSizes) / (sizeof supportedInterstitialSizes[0])); ++i){
        //original orientation of the device
        if (screenSize.width >= supportedInterstitialSizes[i].width){
            interstitialSize = supportedInterstitialSizes[i];
        }
    }
    return interstitialSize;
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
    self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeInterstitial];
    return self;
}

@end
