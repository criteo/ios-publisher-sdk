//
//  GoogleDFPLogger.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "GoogleDFPLogger.h"
#import "InterstitialUpdateDelegate.h"
#import "LogManager.h"

@interface GoogleDFPLogger ()

@property(weak, nonatomic) LogManager *logManager;
@property(weak, nonatomic) id<InterstitialUpdateDelegate> interstitialDelegate;

@end

@implementation GoogleDFPLogger

#pragma mark - Lifecycle

- (instancetype)initWithInterstitialDelegate:(id<InterstitialUpdateDelegate>)interstitialDelegate {
  if (self = [super init]) {
    self.logManager = [LogManager sharedInstance];
    self.interstitialDelegate = interstitialDelegate;
  }
  return self;
};

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView error:error];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad];
  [self.interstitialDelegate interstitialUpdated:YES];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(NSError *)error {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad error:error];
  [self.interstitialDelegate interstitialUpdated:NO];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad];
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad];
  [self.interstitialDelegate interstitialUpdated:NO];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:ad];
}

#pragma mark - GADAdSizeDelegate

- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:bannerView];
}

@end
