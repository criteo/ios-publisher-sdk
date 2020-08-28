//
//  GoogleDFPLogger.m
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
