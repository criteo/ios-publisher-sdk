//
// Created by Aleksandr Pakhmutov on 17/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MoPub.h>
#import <XCTest/XCTest.h>


@interface CR_MopubCreativeViewChecker : NSObject <MPAdViewDelegate, MPInterstitialAdControllerDelegate>

@property(nonatomic, readonly) XCTestExpectation *adCreativeRenderedExpectation;
@property(nonatomic, readonly) UIWindow *uiWindow;

- (instancetype)initWithBanner:(MPAdView *)adView;

- (instancetype)initWithInterstitial:(MPInterstitialAdController *)interstitialAdController;

- (void)initMopubSdkAndRenderAd:(id)someMopubAd;

- (BOOL)waitAdCreativeRendered;

@end