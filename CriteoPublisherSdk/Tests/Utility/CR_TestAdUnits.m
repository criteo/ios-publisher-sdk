//
//  CR_TestAdUnits.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

+ (CRInterstitialAdUnit *)videoInterstitial {
  return [self interstitialWithId:VideoInterstitialAdUnitId];
}

+ (CRNativeAdUnit *)randomNative {
  return [self nativeWithId:self.randomNativeAdUnitId];
}

+ (CRNativeAdUnit *)preprodNative {
  return [self nativeWithId:PreprodNativeAdUnitId];
}

+ (CRRewardedAdUnit *)randomRewarded {
  return [self rewardedWithId:self.randomRewardedAdUnitId];
}

+ (CRRewardedAdUnit *)rewarded {
  return [self rewardedWithId:RewardedAdUnitId];
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

+ (NSString *)randomBannerAdUnitId {
  return @"Random-Banner-Ad-Unit";
}

+ (NSString *)randomInterstitialAdUnitId {
  return @"Random-Interstitial-Ad-Unit";
}

+ (NSString *)randomNativeAdUnitId {
  return @"Random-Native-Ad-Unit";
}

+ (NSString *)randomRewardedAdUnitId {
  return @"Random-Rewarded-Ad-Unit";
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

+ (CRRewardedAdUnit *)rewardedWithId:(NSString *)adUnitId {
  return [[CRRewardedAdUnit alloc] initWithAdUnitId:adUnitId];
}

@end
