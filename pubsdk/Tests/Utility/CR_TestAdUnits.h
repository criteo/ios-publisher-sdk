//
// Created by Aleksandr Pakhmutov on 04/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRInterstitialAdUnit.h"
#import "CRBannerAdUnit.h"

@interface CR_TestAdUnits : NSObject

@property (class, nonatomic, readonly) CRBannerAdUnit *demoBanner320x50;
@property (class, nonatomic, readonly) CRBannerAdUnit *randomBanner320x50;

@property (class, nonatomic, readonly) CRInterstitialAdUnit *demoInterstitial;
@property (class, nonatomic, readonly) CRInterstitialAdUnit *randomInterstitial;

@end