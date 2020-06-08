//
//  StandaloneLogger.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "StandaloneLogger.h"
#import "LogManager.h"
#import "InterstitialUpdateDelegate.h"

@interface StandaloneLogger ()

@property (weak, nonatomic) LogManager *logManager;

@end

@implementation StandaloneLogger

#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        self.logManager = [LogManager sharedInstance];
    }
    return self;
};

# pragma mark - CRBannerViewDelegate

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView error:error];
}

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

- (void)bannerWasClicked:(CRBannerView *)bannerView {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

# pragma mark - CRInterstitialDelegate

- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
    if ([self.interstitialDelegate respondsToSelector:@selector(interstitialUpdated:)]) {
        [self.interstitialDelegate interstitialUpdated:YES];
    }
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial error:error];
    if ([self.interstitialDelegate respondsToSelector:@selector(interstitialUpdated:)]) {
        [self.interstitialDelegate interstitialUpdated:NO];
    }
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidAppear:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
    if ([self.interstitialDelegate respondsToSelector:@selector(interstitialUpdated:)]) {
        [self.interstitialDelegate interstitialUpdated:NO];
    }
}

- (void)interstitialDidDisappear:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialWasClicked:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialIsReadyToPresent:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
    if ([self.interstitialDelegate respondsToSelector:@selector(interstitialUpdated:)]) {
        [self.interstitialDelegate interstitialUpdated:YES];
    }
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdContentWithError:(NSError *)error {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial error:error];
}

# pragma mark - CRNativeDelegate

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad];
}

- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:loader error:error];
}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:loader];
}

- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:loader];
}

- (void)nativeLoaderWillLeaveApplicationForNativeAd:(CRNativeLoader *)loader {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:loader];
}

@end
