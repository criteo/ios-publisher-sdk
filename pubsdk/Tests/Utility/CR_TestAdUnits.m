//
// Created by Aleksandr Pakhmutov on 04/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_TestAdUnits.h"
#import "Criteo+Testing.h"
#import "CRNativeAdUnit.h"

@implementation CR_TestAdUnits

+ (CRBannerAdUnit *)demoBanner320x50 {
    return [self banner320x50WithId:DemoBannerAdUnitId];
}

+ (CRBannerAdUnit *)randomBanner320x50 {
    return [self banner320x50WithId:[[NSUUID UUID] UUIDString]];
}

+ (CRBannerAdUnit *)preprodBanner320x50 {
    return [self banner320x50WithId:PreprodBannerAdUnitId];
}

+ (CRInterstitialAdUnit *)demoInterstitial {
    return [self interstitialWithId:DemoInterstitialAdUnitId];
}

+ (CRInterstitialAdUnit *)randomInterstitial {
    return [self interstitialWithId:[[NSUUID UUID] UUIDString]];
}

+ (CRInterstitialAdUnit *)preprodInterstitial {
    return [self interstitialWithId:PreprodInterstitialAdUnitId];
}

+ (CRNativeAdUnit *)randomNative {
    return [self nativeWithId:[[NSUUID UUID] UUIDString]];
}
+ (NSString *)dfpBanner50AdUnitId {
    return @"/140800857/Endeavour_320x50";
}

+ (NSString *)dfpInterstitialAdUnitId {
    return @"/140800857/Endeavour_Interstitial_320x480";
}

+ (NSString *)dfpNativeId {
    return @"/140800857/Endeavour_Native";
}

#pragma mark - Private methods

+ (CRInterstitialAdUnit *)interstitialWithId:(NSString *)adUnitId {
    return [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
}

+ (CRBannerAdUnit *)banner320x50WithId:(NSString *)adUnitId {
    return [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId size:CGSizeMake(320, 50)];
}

+ (CRNativeAdUnit *)nativeWithId:(NSString *)adUnitId {
    return [[CRNativeAdUnit alloc] initWithAdUnitId:adUnitId];
}

@end