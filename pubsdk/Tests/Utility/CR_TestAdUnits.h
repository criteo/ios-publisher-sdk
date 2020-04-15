//
// Created by Aleksandr Pakhmutov on 04/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRInterstitialAdUnit.h"
#import "CRBannerAdUnit.h"
#import "CRNativeAdUnit.h"

@interface CR_TestAdUnits : NSObject

@property(class, nonatomic, readonly) CRBannerAdUnit *demoBanner320x50;
@property(class, nonatomic, readonly) CRBannerAdUnit *randomBanner320x50;
@property(class, nonatomic, readonly) CRBannerAdUnit *preprodBanner320x50;

@property(class, nonatomic, readonly) CRInterstitialAdUnit *demoInterstitial;
@property(class, nonatomic, readonly) CRInterstitialAdUnit *randomInterstitial;
@property(class, nonatomic, readonly) CRInterstitialAdUnit *preprodInterstitial;

@property(class, nonatomic, readonly) CRNativeAdUnit *randomNative;
@property(class, nonatomic, readonly) CRNativeAdUnit *preprodNative;

@property(class, nonatomic, readonly) NSString *dfpBanner50AdUnitId;
@property(class, nonatomic, readonly) NSString *dfpInterstitialAdUnitId;
@property(class, nonatomic, readonly) NSString *dfpNativeId;

@property(class, nonatomic, readonly) NSString *mopubBanner50AdUnitId;
@property(class, nonatomic, readonly) NSString *mopubInterstitialAdUnitId;

@property(class, nonatomic, readonly) NSString *randomBannerAdUnitId;
@property(class, nonatomic, readonly) NSString *randomInterstitialAdUnitId;
@property(class, nonatomic, readonly) NSString *randomNativeAdUnitId;

+ (CRBannerAdUnit *)banner320x50WithId:(NSString *)adUnitId;

@end
