//
//  GoogleDFPTableViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "GoogleDFPTableViewController.h"
#import "Criteo+Internal.h"
#import <Foundation/Foundation.h>
@import GoogleMobileAds;

@interface GoogleDFPTableViewController () <GADBannerViewDelegate, GADInterstitialDelegate, GADAdSizeDelegate>
@property (weak, nonatomic) IBOutlet UIView *banner_320x50RedView;
@property (weak, nonatomic) IBOutlet UIView *banner_300x250RedView;
@property (weak, nonatomic) IBOutlet UIView *native_fluidRedView;

@property (nonatomic) DFPBannerView *dfpBannerView_320x50;
@property (nonatomic) DFPBannerView *dfpBannerView_300x250;
@property (nonatomic) DFPBannerView *dfpNativestyle_Fluid;
@property (nonatomic) DFPInterstitial *dfpInterstitial;
@property (nonatomic) UITextView *errorTextView;

@end

@implementation GoogleDFPTableViewController

- (void) resetDfpBannerView:(UIView *)bannerView {
    if (bannerView) {
        [bannerView removeFromSuperview];
        bannerView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Criteo.sharedCriteo.networkMangerDelegate = self.homePageVC;
}

# pragma mark - actions

- (IBAction)banner_320x50Click:(id)sender {
    [self resetDfpBannerView:self.dfpBannerView_320x50];
    self.dfpBannerView_320x50 = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.dfpBannerView_320x50.delegate = self;
    self.dfpBannerView_320x50.adUnitID = self.homePageVC.googleBannerAdUnit_320x50.adUnitId;
    self.dfpBannerView_320x50.rootViewController = self;
    DFPRequest *request = [DFPRequest request];
    Criteo *criteo = [Criteo sharedCriteo];
    [criteo setBidsForRequest:request withAdUnit:self.homePageVC.googleBannerAdUnit_320x50];
    [self.dfpBannerView_320x50 loadRequest:request];
    self.banner_320x50RedView.backgroundColor = [UIColor redColor];
    [self.banner_320x50RedView addSubview:self.dfpBannerView_320x50];
//    [self debugPrintWebViewAfterSec:5];
}
- (IBAction)banner_300x250Click:(id)sender {
    [self resetDfpBannerView:self.dfpBannerView_300x250];
    self.dfpBannerView_300x250 = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
    self.dfpBannerView_300x250.delegate = self;
    self.dfpBannerView_300x250.adUnitID = self.homePageVC.googleBannerAdUnit_300x250.adUnitId;
    self.dfpBannerView_300x250.rootViewController = self;
    DFPRequest *request = [DFPRequest request];
    Criteo *criteo = [Criteo sharedCriteo];
    [criteo setBidsForRequest:request withAdUnit:self.homePageVC.googleBannerAdUnit_300x250];
    [self.dfpBannerView_300x250 loadRequest:request];
    self.banner_300x250RedView.backgroundColor = [UIColor redColor];
    [self.banner_300x250RedView addSubview:self.dfpBannerView_300x250];
}
- (IBAction)customNativeFluidClick:(id)sender {
    [self resetDfpBannerView:self.dfpNativestyle_Fluid];
    self.dfpNativestyle_Fluid = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeFluid];
    self.dfpNativestyle_Fluid.delegate = self;
    self.dfpNativestyle_Fluid.adSizeDelegate = self;
    self.dfpNativestyle_Fluid.rootViewController = self;
    self.dfpNativestyle_Fluid.adUnitID = self.homePageVC.googleNativeAdUnit_Fluid.adUnitId;
    DFPRequest *request = [DFPRequest request];
    [Criteo.sharedCriteo setBidsForRequest:request withAdUnit:self.homePageVC.googleNativeAdUnit_Fluid];
    self.dfpNativestyle_Fluid.frame = CGRectMake(0, 0, self.native_fluidRedView.frame.size.width, 0);
    [self.dfpNativestyle_Fluid loadRequest:request];
    self.native_fluidRedView.backgroundColor = [UIColor redColor];
    [self.native_fluidRedView addSubview:self.dfpNativestyle_Fluid];
}
- (IBAction)interstitialClick:(id)sender {
    [self.interstitalSpinner startAnimating];
     self.textFeedback.text = [self.textFeedback.text stringByAppendingString:@"\nREQUESTED INTERSTITIAL LOAD"];
    Criteo *criteo = [Criteo sharedCriteo];
    DFPRequest *request = [DFPRequest request];
    CRInterstitialAdUnit *adUnit = super.interstitialVideoSwitch.on
        ? self.homePageVC.criteoInterstitialVideoAdUnit
        : self.homePageVC.googleInterstitialAdUnit;
    [criteo setBidsForRequest:request withAdUnit:adUnit];
    self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:GOOGLEINTERSTITIALADUNITID];
    self.dfpInterstitial.delegate = self;
    [self.dfpInterstitial loadRequest:request];
}
- (IBAction)clearButton:(id)sender {
    [self updateInterstitialButtonsForAdLoaded:NO];
    [self resetDfpBannerView:self.dfpNativestyle_Fluid];
    [self resetDfpBannerView:self.dfpBannerView_320x50];
    [self resetDfpBannerView:self.dfpBannerView_300x250];
    self.banner_320x50RedView.backgroundColor = [UIColor clearColor];
    self.banner_300x250RedView.backgroundColor = [UIColor clearColor];
    self.native_fluidRedView.backgroundColor = [UIColor clearColor];
    self.textFeedback.text = @"";
    if(self.banner_320x50RedView.subviews.count == 1) {
        [self resetErrorTextView:[self.banner_320x50RedView.subviews objectAtIndex:0]];
    }
    if(self.banner_300x250RedView.subviews.count == 1) {
        [self resetErrorTextView:[self.banner_300x250RedView.subviews objectAtIndex:0]];
    }
    if(self.native_fluidRedView.subviews.count == 1) {
        [self resetErrorTextView:[self.native_fluidRedView.subviews objectAtIndex:0]];
    }
}

- (IBAction)showInterstitialClick:(id)sender {
    if(self.dfpInterstitial.isReady) {
        [self.dfpInterstitial presentFromRootViewController:self];
    }
}

- (void)resetErrorTextView:(UITextView *)textView {
    if(textView) {
        textView.text = @"";
        [textView removeFromSuperview];
        textView = nil;
    }
}

- (void) debugPrintWebViewAfterSec:(NSUInteger)sec
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dfpBannerView_320x50.subviews.count > 0) {
            NSLog(@"Banner view has a GADOAdView!");
            UIView *gadoAdView = self.dfpBannerView_320x50.subviews[0];

            if (gadoAdView.subviews.count > 1) {
                NSLog(@"GADOAdView has a GADOUIKitWebView!");
                UIView *gadouikitwebview = gadoAdView.subviews[1];

                if (gadouikitwebview.subviews.count > 0) {
                    NSLog(@"GADOUIKitWebView has an inner web view!");
                    UIWebView *innerWebView = (UIWebView*)gadouikitwebview.subviews[0];
                    NSString *webViewContent = [innerWebView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
                    NSLog(@"\n\nINNER WEB VIEW CONTENTS\n\n%@\n\nEND INNER WEB VIEW CONTENTS\n\n", webViewContent);
                } else {
                    NSLog(@"GADOUIKitWebView has no subviews");
                }
            } else {
                NSLog(@"GADOAdView has no subviews");
            }
        } else {
            NSLog(@"DFP Banner view has no subviews");
        }
    });
}

# pragma mark - Banner Delegate methods
/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(DFPBannerView *)adView {
    NSLog(@"adViewDidReceiveAd: delegate invoked");

}

/// Tells the delegate an ad request failed.
- (void)adView:(DFPBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSString *errorString = [NSString stringWithFormat:@"adView:didFailToReceiveAdWithError: delegate invoked with error %@", [error localizedDescription]];
    NSLog(@"%@", errorString);
    self.errorTextView = [[UITextView alloc] initWithFrame:adView.superview.frame];
    self.errorTextView.text = errorString;
    self.errorTextView.backgroundColor = [UIColor clearColor];
    self.errorTextView.textColor = [UIColor blackColor];
    UIView *superView = adView.superview;
    [adView removeFromSuperview];
    [superView addSubview:self.errorTextView];
}

/// Tells the delegate that a full-screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(DFPBannerView *)adView {
    NSLog(@"adViewWillPresentScreen: delegate invoked");
}

/// Tells the delegate that the full-screen view will be dismissed.
- (void)adViewWillDismissScreen:(DFPBannerView *)adView {
    NSLog(@"adViewWillDismissScreen: delegate invoked");
}

/// Tells the delegate that the full-screen view has been dismissed.
- (void)adViewDidDismissScreen:(DFPBannerView *)adView {
    NSLog(@"adViewDidDismissScreen: delegate invoked");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(DFPBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication: delegate invoked");
}

# pragma mark - Interstitial Delegate methods
/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(DFPInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd: delegate invoked");
    [self updateInterstitialButtonsForAdLoaded:YES];
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(DFPInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: delegate invoked with error %@", [error localizedDescription]);
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(DFPInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen: delegate invoked");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(DFPInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen: delegate invoked");
    [self updateInterstitialButtonsForAdLoaded:NO];
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(DFPInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen: delegate invoked");
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(DFPInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication: delegate invoked");
}

#pragma mark - GADAdSize Delegate
- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size {
    NSLog(@"adView:willChangeAdSizeTo: delegate invoked");
}

#pragma mark - Private

- (void) updateInterstitialButtonsForAdLoaded:(BOOL)adLoaded {
    NSString* mainButtonTitle = adLoaded ? @"Ad loaded" : @"Load interstitial";
    [self.loadInterstitialButton setTitle:mainButtonTitle forState:UIControlStateNormal];
    [self.interstitalSpinner stopAnimating];
    self.loadInterstitialButton.enabled = !adLoaded;
    self.showInterstitialButton.enabled = adLoaded;
}

@end
