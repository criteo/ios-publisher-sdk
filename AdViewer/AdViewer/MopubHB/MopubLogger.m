//
//  MopubLogger.m
//  AdViewer
//
//  Created by Vincent Guerci on 10/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "MopubLogger.h"
#import "LogManager.h"
#import "InterstitialUpdateDelegate.h"

@interface MopubLogger ()

@property (weak, nonatomic) LogManager *logManager;
@property (weak, nonatomic) UIViewController *viewControllerForPresentingModalView;
@property (weak, nonatomic) id <InterstitialUpdateDelegate> interstitialDelegate;

@end

@implementation MopubLogger

#pragma mark - Lifecycle

- (instancetype)initWithInterstitialDelegate:(UIViewController <InterstitialUpdateDelegate> *)interstitialDelegate {
    if (self = [super init]) {
        self.logManager = [LogManager sharedInstance];
        self.interstitialDelegate = interstitialDelegate;
        self.viewControllerForPresentingModalView = interstitialDelegate;
    }
    return self;
};

# pragma mark - MPAdViewDelegate

- (void)adViewDidLoadAd:(MPAdView *)view {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:view];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:view];
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:view];
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:view];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:view];
}

# pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
    [self.interstitialDelegate interstitialUpdated:YES];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial error:error];
    [self.interstitialDelegate interstitialUpdated:NO];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
    [self.interstitialDelegate interstitialUpdated:NO];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

@end
