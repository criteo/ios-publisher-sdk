//
//  CR_TestAdUnits.h
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
