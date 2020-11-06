//
//  GoogleDFPTableViewController.m
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

#import "GoogleDFPTableViewController.h"
#import "LogManager.h"
#import "GoogleDFPLogger.h"

@interface GoogleDFPTableViewController ()
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) LogManager *logManager;
@property(strong, nonatomic) GoogleDFPLogger *logger;
@property(strong, nonatomic) CRContextData *contextData;

@property(weak, nonatomic) IBOutlet UIView *banner_320x50RedView;
@property(weak, nonatomic) IBOutlet UIView *banner_300x250RedView;
@property(weak, nonatomic) IBOutlet UIView *native_fluidRedView;

@property(nonatomic) DFPBannerView *dfpBannerView_320x50;
@property(nonatomic) DFPBannerView *dfpBannerView_300x250;
@property(nonatomic) DFPBannerView *dfpNativestyle_Fluid;
@property(nonatomic) DFPInterstitial *dfpInterstitial;

@end

@implementation GoogleDFPTableViewController

#pragma mark - Lifecycle

- (void)removeBannerView:(UIView *)bannerView {
  if (bannerView) {
    [bannerView removeFromSuperview];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.criteo = [Criteo sharedCriteo];
  self.logManager = [LogManager sharedInstance];
  self.logger = [[GoogleDFPLogger alloc] initWithInterstitialDelegate:self];
  self.contextData = CRContextData.new;  // TODO
}

#pragma mark - Actions

- (IBAction)banner_320x50Click:(id)sender {
  [self removeBannerView:self.dfpBannerView_320x50];
  self.dfpBannerView_320x50 = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
  self.dfpBannerView_320x50.delegate = self.logger;
  self.dfpBannerView_320x50.adUnitID = self.homePageVC.googleBannerAdUnit_320x50.adUnitId;
  self.dfpBannerView_320x50.rootViewController = self;
  [self.criteo loadBidForAdUnit:self.homePageVC.googleBannerAdUnit_320x50
                        context:self.contextData
                responseHandler:^(CRBid *bid) {
                  DFPRequest *request = [DFPRequest request];
                  [self.criteo enrichAdObject:request withBid:bid];
                  [self.dfpBannerView_320x50 loadRequest:request];
                }];
  self.banner_320x50RedView.backgroundColor = [UIColor redColor];
  [self.banner_320x50RedView addSubview:self.dfpBannerView_320x50];
}
- (IBAction)banner_300x250Click:(id)sender {
  [self removeBannerView:self.dfpBannerView_300x250];
  self.dfpBannerView_300x250 = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
  self.dfpBannerView_300x250.delegate = self.logger;
  self.dfpBannerView_300x250.adUnitID = self.homePageVC.googleBannerAdUnit_300x250.adUnitId;
  self.dfpBannerView_300x250.rootViewController = self;
  [self.criteo loadBidForAdUnit:self.homePageVC.googleBannerAdUnit_300x250
                        context:self.contextData
                responseHandler:^(CRBid *bid) {
                  DFPRequest *request = [DFPRequest request];
                  [self.criteo enrichAdObject:request withBid:bid];
                  [self.dfpBannerView_300x250 loadRequest:request];
                }];
  self.banner_300x250RedView.backgroundColor = [UIColor redColor];
  [self.banner_300x250RedView addSubview:self.dfpBannerView_300x250];
}
- (IBAction)customNativeFluidClick:(id)sender {
  [self removeBannerView:self.dfpNativestyle_Fluid];
  self.dfpNativestyle_Fluid = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeFluid];
  self.dfpNativestyle_Fluid.delegate = self.logger;
  self.dfpNativestyle_Fluid.adSizeDelegate = self.logger;
  self.dfpNativestyle_Fluid.rootViewController = self;
  self.dfpNativestyle_Fluid.adUnitID = self.homePageVC.googleNativeAdUnit_Fluid.adUnitId;
  [self.criteo loadBidForAdUnit:self.homePageVC.googleNativeAdUnit_Fluid
                        context:self.contextData
                responseHandler:^(CRBid *bid) {
                  DFPRequest *request = [DFPRequest request];
                  [self.criteo enrichAdObject:request withBid:bid];
                  [self.dfpNativestyle_Fluid loadRequest:request];
                }];
  self.dfpNativestyle_Fluid.frame = CGRectMake(0, 0, self.native_fluidRedView.frame.size.width, 0);
  self.native_fluidRedView.backgroundColor = [UIColor redColor];
  [self.native_fluidRedView addSubview:self.dfpNativestyle_Fluid];
}
- (IBAction)interstitialClick:(id)sender {
  [self.interstitalSpinner startAnimating];
  [self.logManager logEvent:@"Interstitial requested" detail:@""];
  self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:GOOGLEINTERSTITIALADUNITID];
  self.dfpInterstitial.delegate = self.logger;
  Criteo *criteo = [Criteo sharedCriteo];
  CRInterstitialAdUnit *adUnit = super.interstitialVideoSwitch.on
                                     ? self.homePageVC.criteoInterstitialVideoAdUnit
                                     : self.homePageVC.googleInterstitialAdUnit;
  [criteo loadBidForAdUnit:adUnit
                   context:self.contextData
           responseHandler:^(CRBid *bid) {
             DFPRequest *request = [DFPRequest request];
             [criteo enrichAdObject:request withBid:bid];
             [self.dfpInterstitial loadRequest:request];
           }];
}
- (IBAction)clearButton:(id)sender {
  [self interstitialUpdated:NO];
  [self removeBannerView:self.dfpNativestyle_Fluid];
  [self removeBannerView:self.dfpBannerView_320x50];
  [self removeBannerView:self.dfpBannerView_300x250];
  self.banner_320x50RedView.backgroundColor = [UIColor clearColor];
  self.banner_300x250RedView.backgroundColor = [UIColor clearColor];
  self.native_fluidRedView.backgroundColor = [UIColor clearColor];

  if (self.banner_320x50RedView.subviews.count == 1) {
    [self resetErrorTextView:[self.banner_320x50RedView.subviews objectAtIndex:0]];
  }
  if (self.banner_300x250RedView.subviews.count == 1) {
    [self resetErrorTextView:[self.banner_300x250RedView.subviews objectAtIndex:0]];
  }
  if (self.native_fluidRedView.subviews.count == 1) {
    [self resetErrorTextView:[self.native_fluidRedView.subviews objectAtIndex:0]];
  }
}

- (IBAction)showInterstitialClick:(id)sender {
  if (self.dfpInterstitial.isReady) {
    [self.dfpInterstitial presentFromRootViewController:self];
  }
}

- (void)resetErrorTextView:(UITextView *)textView {
  if (textView) {
    textView.text = @"";
    [textView removeFromSuperview];
  }
}

@end
