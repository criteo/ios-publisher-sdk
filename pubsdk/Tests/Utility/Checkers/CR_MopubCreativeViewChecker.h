//
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MoPub.h>
#import <XCTest/XCTest.h>


@interface CR_MopubCreativeViewChecker : NSObject <MPAdViewDelegate, MPInterstitialAdControllerDelegate>

@property (strong, nonatomic, readonly) XCTestExpectation *adCreativeRenderedExpectation;
@property (weak, nonatomic, readonly) UIWindow *uiWindow;

- (instancetype)initWithBanner:(MPAdView *)adView;

- (instancetype)initWithInterstitial:(MPInterstitialAdController *)interstitialAdController;

- (void)initMopubSdkAndRenderAd:(id)someMopubAd;

- (BOOL)waitAdCreativeRendered;

@end
