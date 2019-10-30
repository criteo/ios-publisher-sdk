//
//  MopubViewController.m
//  AdViewer
//
//  Created by Sneha Pathrose on 9/13/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "MopubTableViewController.h"
#import "Criteo+Internal.h"

@interface MopubTableViewController ()

@property (nonatomic, strong) MPAdView *adView_320x50;
@property (nonatomic, strong) MPAdView *adView_300x250;
@property (nonatomic, strong) MPInterstitialAdController *interstitial;
@property (weak, nonatomic) IBOutlet UIView *adView_320x50RedView;
@property (weak, nonatomic) IBOutlet UIView *adView_300x250RedView;
@property (nonatomic) UITextView *errorTextView;

@end

@implementation MopubTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerMoPub];
    Criteo.sharedCriteo.networkMangerDelegate = self.homePageVC;
}

- (void)registerMoPub {
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:MOPUBBANNERADUNITID_320X50];
    [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
        NSLog(@"Mopub SDK initialization complete");
    }];
}

- (IBAction)banner320x50ButtonClick:(id)sender {
    [self resetDfpBannerView:self.adView_320x50];
    self.adView_320x50 = [[MPAdView alloc] initWithAdUnitId:MOPUBBANNERADUNITID_320X50
                                                size:MOPUB_BANNER_SIZE];
    self.adView_320x50.keywords = @"key1:value1,key2:value2";
    Criteo *criteo = [Criteo sharedCriteo];
    [criteo setBidsForRequest:self.adView_320x50 withAdUnit:self.homePageVC.moPubBannerAdUnit_320x50];

    self.adView_320x50.delegate = self;
    self.adView_320x50.frame = CGRectMake((self.adView_320x50RedView.bounds.size.width - MOPUB_BANNER_SIZE.width) / 2,
                                   self.adView_320x50RedView.bounds.size.height - MOPUB_BANNER_SIZE.height,
                                   MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    [self.adView_320x50RedView addSubview:self.adView_320x50];
    self.adView_320x50RedView.backgroundColor = [UIColor redColor];
    [self.adView_320x50 loadAd];
}
- (IBAction)banner300x250ButtonClick:(id)sender {
    [self resetDfpBannerView:self.adView_300x250];
    self.adView_300x250 = [[MPAdView alloc] initWithAdUnitId:MOPUBBANNERADUNITID_300X250
                                                       size:MOPUB_MEDIUM_RECT_SIZE];
    self.adView_300x250.keywords = @"key1:value1,key2:value2";
    Criteo *criteo = [Criteo sharedCriteo];
    [criteo setBidsForRequest:self.adView_300x250 withAdUnit:self.homePageVC.moPubBannerAdUnit_300x250];
    self.adView_300x250.delegate = self;
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
    [criteo setBidsForRequest:self.interstitial withAdUnit:self.homePageVC.moPubInterstitialAdUnit];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}
- (IBAction)clearButton:(id)sender {
    [super updateInterstitialButtonsForAdLoaded:NO];
    [self resetDfpBannerView:self.adView_300x250];
    [self resetDfpBannerView:self.adView_320x50];
    self.adView_300x250RedView.backgroundColor = [UIColor clearColor];
    self.adView_320x50RedView.backgroundColor = [UIColor clearColor];
    self.textFeedBack.text = @"";
    if(self.adView_320x50RedView.subviews.count == 1) {
        [self resetErrorTextView:[self.adView_320x50RedView.subviews objectAtIndex:0]];
    }
    if(self.adView_300x250RedView.subviews.count == 1) {
        [self resetErrorTextView:[self.adView_300x250RedView.subviews objectAtIndex:0]];
    }
}

- (IBAction)showInterstitialClick:(id)sender {
    if (self.interstitial.ready) {
        [self.interstitial showFromViewController:self];
    }
}

- (void)resetErrorTextView:(UITextView *)textView {
    if(textView) {
        textView.text = @"";
        [textView removeFromSuperview];
        textView = nil;
    }
}

- (void) resetDfpBannerView:(UIView *)bannerView {
    if (bannerView) {
        [bannerView removeFromSuperview];
        bannerView = nil;
    }
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view {
    NSLog(@"adViewDidLoadAd: delegate invoked with keywords %@", view.keywords);
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    NSString *errorString = @"adViewDidFailToLoadAd: delegate invoked";
    NSLog(@"%@", errorString);
    self.errorTextView = [[UITextView alloc] initWithFrame:view.superview.frame];
    self.errorTextView.text = errorString;
    self.errorTextView.backgroundColor = [UIColor clearColor];
    self.errorTextView.textColor = [UIColor blackColor];
    UIView *superView = view.superview;
    [view removeFromSuperview];
    [superView addSubview:self.errorTextView];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view {
    NSLog(@"willLeaveApplicationFromAd: delegate invoked");
}

#pragma mark - <MPInterstitialAdControllerDelegate>
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidLoadAd: delegate invoked with keywords %@", self.interstitial.keywords);
    [self updateInterstitialButtonsForAdLoaded:YES];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidFailToLoadAd: delegate invoked");
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error {
    NSLog(@"interstitialDidFailToLoadAd:withError: delegate invoked with error %@", error.localizedDescription);
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialWillAppear: delegate invoked");
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
     NSLog(@"interstitialDidAppear: delegate invoked");
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialWillDisappear: delegate invoked");
    [self updateInterstitialButtonsForAdLoaded:NO];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidDisappear: delegate invoked");
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidReceiveTapEvent: delegate invoked");
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidExpire: delegate invoked");
}

@end
