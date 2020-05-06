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
@property (weak, nonatomic) id <InterstitialUpdateDelegate> interstitialDelegate;

@end

@implementation StandaloneLogger

#pragma mark - Lifecycle

- (instancetype)initWithInterstitialDelegate:(id <InterstitialUpdateDelegate>)interstitialDelegate {
    if (self = [super init]) {
        self.logManager = [LogManager sharedInstance];
        self.interstitialDelegate = interstitialDelegate;
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
    [self.interstitialDelegate interstitialUpdated:YES];
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial error:error];
    [self.interstitialDelegate interstitialUpdated:NO];
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidAppear:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
    [self.interstitialDelegate interstitialUpdated:NO];
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
    [self.interstitialDelegate interstitialUpdated:YES];
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdContentWithError:(NSError *)error {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial error:error];
}

@end
