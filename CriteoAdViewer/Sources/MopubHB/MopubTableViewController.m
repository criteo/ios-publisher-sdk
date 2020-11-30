//
//  MopubTableViewController.m
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

#import "MopubTableViewController.h"
#import "LogManager.h"
#import "MopubLogger.h"

@interface MopubTableViewController ()
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) LogManager *logManager;
@property(strong, nonatomic) MopubLogger *logger;

@property(nonatomic, strong) MPAdView *adView_320x50;
@property(nonatomic, strong) MPAdView *adView_300x250;
@property(nonatomic, strong) MPInterstitialAdController *interstitial;
@property(weak, nonatomic) IBOutlet UIView *adView_320x50RedView;
@property(weak, nonatomic) IBOutlet UIView *adView_300x250RedView;

@end

@implementation MopubTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self registerMoPub];
  self.criteo = [Criteo sharedCriteo];
  self.logManager = [LogManager sharedInstance];
  self.logger = [[MopubLogger alloc] initWithInterstitialDelegate:self];
}

#pragma mark - Controller

- (void)registerMoPub {
  MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc]
      initWithAdUnitIdForAppInitialization:MOPUBBANNERADUNITID_320X50];
  [[MoPub sharedInstance]
      initializeSdkWithConfiguration:sdkConfig
                          completion:^{
                            [self.logManager
                                logEvent:@"Mopub SDK initialized"
                                  detail:[NSString stringWithFormat:@"config: %@",
                                                                    [sdkConfig debugDescription]]];
                          }];
}

- (IBAction)banner320x50ButtonClick:(id)sender {
  [self removeBannerView:self.adView_320x50];
  self.adView_320x50 = [[MPAdView alloc] initWithAdUnitId:MOPUBBANNERADUNITID_320X50];
  self.adView_320x50.keywords = @"key1:value1,key2:value2";
  self.adView_320x50.delegate = self.logger;
  self.adView_320x50.frame = CGRectMake(0, 0, 320, 50);
  [self.adView_320x50RedView addSubview:self.adView_320x50];
  self.adView_320x50RedView.backgroundColor = [UIColor redColor];
  [self.criteo loadBidForAdUnit:self.homePageVC.moPubBannerAdUnit_320x50
                    withContext:self.contextData
                responseHandler:^(CRBid *bid) {
                  [self.criteo enrichAdObject:self.adView_320x50 withBid:bid];
                  [self.adView_320x50 loadAd];
                }];
}
- (IBAction)banner300x250ButtonClick:(id)sender {
  [self removeBannerView:self.adView_300x250];
  self.adView_300x250 = [[MPAdView alloc] initWithAdUnitId:MOPUBBANNERADUNITID_300X250];
  self.adView_300x250.keywords = @"key1:value1,key2:value2";
  self.adView_300x250.delegate = self.logger;
  self.adView_300x250.frame = CGRectMake(0, 0, 300, 250);
  [self.adView_300x250RedView addSubview:self.adView_300x250];
  self.adView_300x250RedView.backgroundColor = [UIColor redColor];
  [self.criteo loadBidForAdUnit:self.homePageVC.moPubBannerAdUnit_300x250
                    withContext:self.contextData
                responseHandler:^(CRBid *bid) {
                  [self.criteo enrichAdObject:self.adView_300x250 withBid:bid];
                  [self.adView_300x250 loadAd];
                }];
}

- (IBAction)interstitialButtonClick:(id)sender {
  [super onLoadInterstitial];
  self.interstitial =
      [MPInterstitialAdController interstitialAdControllerForAdUnitId:MOPUBINTERSTITIALADUNITID];
  CRInterstitialAdUnit *adUnit = super.interstitialVideoSwitch.on
                                     ? self.homePageVC.criteoInterstitialVideoAdUnit
                                     : self.homePageVC.moPubInterstitialAdUnit;
  self.interstitial.delegate = self.logger;
  [self.criteo loadBidForAdUnit:adUnit
                    withContext:self.contextData
                responseHandler:^(CRBid *bid) {
                  [self.criteo enrichAdObject:self.interstitial withBid:bid];
                  [self.interstitial loadAd];
                }];
}
- (IBAction)clearButton:(id)sender {
  [super interstitialUpdated:NO];
  [self removeBannerView:self.adView_300x250];
  [self removeBannerView:self.adView_320x50];
  self.adView_300x250RedView.backgroundColor = [UIColor clearColor];
  self.adView_320x50RedView.backgroundColor = [UIColor clearColor];
}

- (IBAction)showInterstitialClick:(id)sender {
  if (self.interstitial.ready) {
    [self.interstitial showFromViewController:self];
  }
}

- (void)removeBannerView:(UIView *)bannerView {
  if (bannerView) {
    [bannerView removeFromSuperview];
  }
}

@end
