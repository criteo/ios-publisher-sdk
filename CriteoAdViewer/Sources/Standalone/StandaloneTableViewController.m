//
//  StandaloneTableViewController.m
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

#import "StandaloneTableViewController.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>
#import "LogManager.h"
#import "StandaloneLogger.h"

@interface StandaloneTableViewController ()
@property(strong, nonatomic) StandaloneLogger *logger;

@property(weak, nonatomic) IBOutlet UIView *banner_320x50View;

@property(nonatomic, strong) CRBannerView *cr_banner_320x50View;
@property(nonatomic, strong) CRInterstitial *cr_interstitialView;
@property(weak, nonatomic) IBOutlet UISwitch *bannerShouldCreateNewObject;
@property(weak, nonatomic) IBOutlet UISwitch *interstitialShouldCreateNewObject;

@end

@implementation StandaloneTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.logger = [[StandaloneLogger alloc] init];
  self.logger.interstitialDelegate = self;
}

- (IBAction)banner320x50ButtonClick:(id)sender {
  if (self.bannerShouldCreateNewObject.on) {
    self.cr_banner_320x50View =
        [[CRBannerView alloc] initWithAdUnit:self.homePageVC.criteoBannerAdUnit_320x50];
    self.cr_banner_320x50View.delegate = self.logger;
  }

  [self.cr_banner_320x50View loadAdWithContext:self.contextData];
  [self.banner_320x50View addSubview:self.cr_banner_320x50View];
}

- (IBAction)clearButton:(id)sender {
  [self resetBannerView:self.cr_banner_320x50View];
  [super interstitialUpdated:NO];
  self.cr_interstitialView = nil;
}

- (IBAction)loadInterstitialClick:(id)sender {
  [super onLoadInterstitial];

  if (self.interstitialShouldCreateNewObject.on) {
    CRInterstitialAdUnit *adUnit = super.interstitialVideoSwitch.on
                                       ? self.homePageVC.criteoInterstitialVideoAdUnit
                                       : self.homePageVC.criteoInterstitialAdUnit;
    self.cr_interstitialView = [[CRInterstitial alloc] initWithAdUnit:adUnit];
    self.cr_interstitialView.delegate = self.logger;
  }

  [self.cr_interstitialView loadAdWithContext:self.contextData];
}

- (IBAction)showInterstitialClick:(id)sender {
  [self.cr_interstitialView presentFromRootViewController:self];
}

#pragma mark - Private

- (void)resetBannerView:(UIView *)bannerView {
  if (bannerView) {
    [bannerView removeFromSuperview];
  }
}

@end
