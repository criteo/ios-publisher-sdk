//
// Copyright © 2018-2020 Criteo. All rights reserved.
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
    return [self banner320x50WithId:self.randomBannerAdUnitId];
}

+ (CRBannerAdUnit *)preprodBanner320x50 {
    return [self banner320x50WithId:PreprodBannerAdUnitId];
}

+ (CRInterstitialAdUnit *)demoInterstitial {
    return [self interstitialWithId:DemoInterstitialAdUnitId];
}

+ (CRInterstitialAdUnit *)randomInterstitial {
    return [self interstitialWithId:self.randomInterstitialAdUnitId];
}

+ (CRInterstitialAdUnit *)preprodInterstitial {
    return [self interstitialWithId:PreprodInterstitialAdUnitId];
}

+ (CRNativeAdUnit *)randomNative {
    return [self nativeWithId:self.randomNativeAdUnitId];
}

+ (CRNativeAdUnit *)preprodNative {
    return [self nativeWithId:PreprodNativeAdUnitId];
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

+ (NSString *)mopubBanner50AdUnitId {
    return @"d2f3ed80e5da4ae1acde0971eac30fa4";
}

+ (NSString *)mopubInterstitialAdUnitId {
    return @"83a2996696284da881edaf1a480e5d7c";
}

+ (NSString *)randomBannerAdUnitId {
    return @"Random-Banner-Ad-Unit";
}

+ (NSString *)randomInterstitialAdUnitId {
    return @"Random-Interstitial-Ad-Unit";
}

+ (NSString *)randomNativeAdUnitId {
    return @"Random-Native-Ad-Unit";
}

+ (CRBannerAdUnit *)banner320x50WithId:(NSString *)adUnitId {
    return [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId size:CGSizeMake(320, 50)];
}

#pragma mark - Private methods

+ (CRInterstitialAdUnit *)interstitialWithId:(NSString *)adUnitId {
    return [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
}

+ (CRNativeAdUnit *)nativeWithId:(NSString *)adUnitId {
    return [[CRNativeAdUnit alloc] initWithAdUnitId:adUnitId];
}

@end
