//
//  MopubLogger.m
//  CriteoAdViewer
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

#import "MopubLogger.h"
#import "LogManager.h"
#import "InterstitialUpdateDelegate.h"

@interface MopubLogger ()

@property(weak, nonatomic) LogManager *logManager;
@property(weak, nonatomic) UIViewController *viewControllerForPresentingModalView;
@property(weak, nonatomic) id<InterstitialUpdateDelegate> interstitialDelegate;

@end

@implementation MopubLogger

#pragma mark - Lifecycle

- (instancetype)initWithInterstitialDelegate:
    (UIViewController<InterstitialUpdateDelegate> *)interstitialDelegate {
  if (self = [super init]) {
    self.logManager = [LogManager sharedInstance];
    self.interstitialDelegate = interstitialDelegate;
    self.viewControllerForPresentingModalView = interstitialDelegate;
  }
  return self;
};

#pragma mark - MPAdViewDelegate

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:view];
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:view error:error];
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

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
  [self.interstitialDelegate interstitialUpdated:YES];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
                          withError:(NSError *)error {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial error:error];
  [self.interstitialDelegate interstitialUpdated:NO];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialWillDismiss:(MPInterstitialAdController *)interstitial {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
  [self.interstitialDelegate interstitialUpdated:NO];
}

- (void)interstitialDidDismiss:(MPInterstitialAdController *)interstitial {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
  [self.logManager logEvent:NSStringFromSelector(_cmd) info:interstitial];
}

@end
