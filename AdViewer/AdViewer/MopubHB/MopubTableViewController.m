//
//  MopubViewController.m
//  AdViewer
//
//  Created by Sneha Pathrose on 9/13/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "MopubTableViewController.h"
#import "LogManager.h"
#import "MopubLogger.h"

@interface MopubTableViewController ()
@property (strong, nonatomic) LogManager *logManager;
@property (strong, nonatomic) MopubLogger *logger;

@property (nonatomic, strong) MPAdView *adView_320x50;
@property (nonatomic, strong) MPAdView *adView_300x250;
@property (nonatomic, strong) MPInterstitialAdController *interstitial;
@property (weak, nonatomic) IBOutlet UIView *adView_320x50RedView;
@property (weak, nonatomic) IBOutlet UIView *adView_300x250RedView;

@end

@implementation MopubTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerMoPub];
    self.logManager = [LogManager sharedInstance];
    self.logger = [[MopubLogger alloc] initWithInterstitialDelegate:self];
}

- (void)registerMoPub {
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:MOPUBBANNERADUNITID_320X50];
    [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
        [self.logManager logEvent:@"Mopub SDK initialized"
                           detail:[NSString stringWithFormat:@"config: %@", [sdkConfig debugDescription]]];
    }];
}

- (IBAction)banner320x50ButtonClick:(id)sender {
    [self removeBannerView:self.adView_320x50];
    self.adView_320x50 = [[MPAdView alloc] initWithAdUnitId:MOPUBBANNERADUNITID_320X50
                                                size:MOPUB_BANNER_SIZE];
    self.adView_320x50.keywords = @"key1:value1,key2:value2";
    Criteo *criteo = [Criteo sharedCriteo];
    [criteo setBidsForRequest:self.adView_320x50 withAdUnit:self.homePageVC.moPubBannerAdUnit_320x50];

    self.adView_320x50.delegate = self.logger;
    self.adView_320x50.frame = CGRectMake((self.adView_320x50RedView.bounds.size.width - MOPUB_BANNER_SIZE.width) / 2,
                                   self.adView_320x50RedView.bounds.size.height - MOPUB_BANNER_SIZE.height,
                                   MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    [self.adView_320x50RedView addSubview:self.adView_320x50];
    self.adView_320x50RedView.backgroundColor = [UIColor redColor];
    [self.adView_320x50 loadAd];
}
- (IBAction)banner300x250ButtonClick:(id)sender {
    [self removeBannerView:self.adView_300x250];
    self.adView_300x250 = [[MPAdView alloc] initWithAdUnitId:MOPUBBANNERADUNITID_300X250
                                                       size:MOPUB_MEDIUM_RECT_SIZE];
    self.adView_300x250.keywords = @"key1:value1,key2:value2";
    Criteo *criteo = [Criteo sharedCriteo];
    [criteo setBidsForRequest:self.adView_300x250 withAdUnit:self.homePageVC.moPubBannerAdUnit_300x250];
    self.adView_300x250.delegate = self.logger;
    self.adView_300x250.frame = CGRectMake((self.adView_300x250RedView.bounds.size.width - MOPUB_MEDIUM_RECT_SIZE.width) / 2,
                                          self.adView_300x250RedView.bounds.size.height - MOPUB_MEDIUM_RECT_SIZE.height,
                                          MOPUB_MEDIUM_RECT_SIZE.width, MOPUB_MEDIUM_RECT_SIZE.height);
    [self.adView_300x250RedView addSubview:self.adView_300x250];
    self.adView_300x250RedView.backgroundColor = [UIColor redColor];
    [self.adView_300x250 loadAd];
}

- (IBAction)interstitialButtonClick:(id)sender {
    [super onLoadInterstitial];
    self.interstitial = [MPInterstitialAdController
                         interstitialAdControllerForAdUnitId:MOPUBINTERSTITIALADUNITID];
    Criteo *criteo = [Criteo sharedCriteo];
    CRInterstitialAdUnit *adUnit = super.interstitialVideoSwitch.on
        ? self.homePageVC.criteoInterstitialVideoAdUnit
        : self.homePageVC.moPubInterstitialAdUnit;
    [criteo setBidsForRequest:self.interstitial withAdUnit:adUnit];
    self.interstitial.delegate = self.logger;
    [self.interstitial loadAd];
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
