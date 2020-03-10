//
//  GoogleDFPTableViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "GoogleDFPTableViewController.h"
#import "LogManager.h"
#import "GoogleDFPLogger.h"

@interface GoogleDFPTableViewController ()
@property (strong, nonatomic) LogManager *logManager;
@property (strong, nonatomic) GoogleDFPLogger *logger;

@property (weak, nonatomic) IBOutlet UIView *banner_320x50RedView;
@property (weak, nonatomic) IBOutlet UIView *banner_300x250RedView;
@property (weak, nonatomic) IBOutlet UIView *native_fluidRedView;

@property (nonatomic) DFPBannerView *dfpBannerView_320x50;
@property (nonatomic) DFPBannerView *dfpBannerView_300x250;
@property (nonatomic) DFPBannerView *dfpNativestyle_Fluid;
@property (nonatomic) DFPInterstitial *dfpInterstitial;

@end

@implementation GoogleDFPTableViewController

- (void)removeBannerView:(UIView *)bannerView {
    if (bannerView) {
        [bannerView removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logManager = [LogManager sharedInstance];
    self.logger = [[GoogleDFPLogger alloc] initWithInterstitialDelegate:self];
}

# pragma mark - actions

- (IBAction)banner_320x50Click:(id)sender {
    [self removeBannerView:self.dfpBannerView_320x50];
    self.dfpBannerView_320x50 = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.dfpBannerView_320x50.delegate = self.logger;
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
    [self removeBannerView:self.dfpBannerView_300x250];
    self.dfpBannerView_300x250 = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
    self.dfpBannerView_300x250.delegate = self.logger;
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
    [self removeBannerView:self.dfpNativestyle_Fluid];
    self.dfpNativestyle_Fluid = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeFluid];
    self.dfpNativestyle_Fluid.delegate = self.logger;
    self.dfpNativestyle_Fluid.adSizeDelegate = self.logger;
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
    [self.logManager logEvent:@"Interstitial requested" detail:@""];
    Criteo *criteo = [Criteo sharedCriteo];
    DFPRequest *request = [DFPRequest request];
    CRInterstitialAdUnit *adUnit = super.interstitialVideoSwitch.on
        ? self.homePageVC.criteoInterstitialVideoAdUnit
        : self.homePageVC.googleInterstitialAdUnit;
    [criteo setBidsForRequest:request withAdUnit:adUnit];
    self.dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:GOOGLEINTERSTITIALADUNITID];
    self.dfpInterstitial.delegate = self.logger;
    [self.dfpInterstitial loadRequest:request];
}
- (IBAction)clearButton:(id)sender {
    [self interstitialUpdated:NO];
    [self removeBannerView:self.dfpNativestyle_Fluid];
    [self removeBannerView:self.dfpBannerView_320x50];
    [self removeBannerView:self.dfpBannerView_300x250];
    self.banner_320x50RedView.backgroundColor = [UIColor clearColor];
    self.banner_300x250RedView.backgroundColor = [UIColor clearColor];
    self.native_fluidRedView.backgroundColor = [UIColor clearColor];

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
    if (textView) {
        textView.text = @"";
        [textView removeFromSuperview];
    }
}

- (void) debugPrintWebViewAfterSec:(NSUInteger)sec {
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

@end
