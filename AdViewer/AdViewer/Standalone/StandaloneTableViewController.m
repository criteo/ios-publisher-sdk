//
//  StandaloneViewControllerTableViewController.m
//  AdViewer
//
//  Created by Aleksandr Pakhmutov on 29/10/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "StandaloneTableViewController.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

@interface StandaloneTableViewController () <CRBannerViewDelegate, CRInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UIView *banner_320x50View;

@property (nonatomic, strong) CRBannerView *cr_banner_320x50View;
@property (nonatomic, strong) CRInterstitial *cr_interstitialView;
@property (weak, nonatomic) IBOutlet UITextView *logsTextView;
@property (weak, nonatomic) IBOutlet UISwitch *bannerShouldCreateNewObject;
@property (weak, nonatomic) IBOutlet UISwitch *interstitialShouldCreateNewObject;


@end

@implementation StandaloneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logsTextView.text = @"...\n";
}

- (IBAction)banner320x50ButtonClick:(id)sender {
    [self appendToLogsWithTime:@"banner320x50ButtonClick"];

    if (self.bannerShouldCreateNewObject.on) {
        self.cr_banner_320x50View = [[CRBannerView alloc] initWithAdUnit:self.homePageVC.criteoBannerAdUnit_320x50];
        self.cr_banner_320x50View.delegate = self;
    }

    [self.cr_banner_320x50View loadAd];

    [self.banner_320x50View addSubview:self.cr_banner_320x50View];
}

- (IBAction)clearButton:(id)sender {
    [self resetBannerView:self.cr_banner_320x50View];
    [super updateInterstitialButtonsForAdLoaded:NO];
    self.cr_interstitialView = nil;
    [self clearLogsClick:nil];
}

- (IBAction)loadInterstitialClick:(id)sender {
    [super onLoadInterstitial];

    if (self.interstitialShouldCreateNewObject.on) {
        CRInterstitialAdUnit *adUnit = super.interstitialVideoSwitch.on
            ? self.homePageVC.criteoInterstitialVideoAdUnit
            : self.homePageVC.criteoInterstitialAdUnit;
        self.cr_interstitialView = [[CRInterstitial alloc] initWithAdUnit:adUnit];
        self.cr_interstitialView.delegate = self;
    }

    [self.cr_interstitialView loadAd];
}

- (IBAction)showInterstitialClick:(id)sender {
    [self.cr_interstitialView presentFromRootViewController:self];
}

- (IBAction)clearLogsClick:(id)sender {
    self.logsTextView.text = @"";
    [self appendToLogsWithTime:@"Logs cleared"];
}


# pragma mark - CRInterstitialDelegate methods

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    NSString *errorMessage = [NSString stringWithFormat:@"CRInterstitialDelegate.interstitial didFailToReceiveAdWithError: %@", error.localizedDescription];
    NSLog(@"%@", errorMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:errorMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
    [super updateInterstitialButtonsForAdLoaded:NO];
}

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial {
    {[self appendToLogsWithTime:@"interstitialWillDisappear"];}
    [super updateInterstitialButtonsForAdLoaded:NO];
}

- (void)interstitialDidDisappear:(CRInterstitial *)interstitial {
    [self appendToLogsWithTime:@"interstitialDidDisappear"];
}

- (void)interstitialIsReadyToPresent:(CRInterstitial *)interstitial {
    [self appendToLogsWithTime:@"interstitialIsReadyToPresent"];
    [super updateInterstitialButtonsForAdLoaded:YES];
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial {
    [self appendToLogsWithTime:@"interstitialWillAppear"];
}

- (void)interstitialDidAppear:(CRInterstitial *)interstitial {
    [self appendToLogsWithTime:@"interstitialDidAppear"];
}

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial {
    [self appendToLogsWithTime:@"interstitialWillLeaveApplication"];
}
- (void)interstitialWasClicked:(CRInterstitial *)interstitial {
    [self appendToLogsWithTime:@"interstitialWasClicked"];
}

# pragma mark - CRBannerViewDelegate methods

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
    [self appendToLogsWithTime:@"bannerDidReceiveAd"];
}

- (void)bannerWasClicked:(CRBannerView *)bannerView {
    [self appendToLogsWithTime:@"bannerWasClicked"];
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
    [self appendToLogsWithTime:@"bannerWillLeaveApplication"];
}

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    [self appendToLogsWithTime:@"banner didFailToReceiveAdWithError"];
    NSLog(@"didFailToReceiveAdWithError with error: %@", error.localizedDescription);
}

# pragma mark - Private

- (void) resetBannerView:(UIView *)bannerView {
    if (bannerView) {
        [bannerView removeFromSuperview];
        bannerView = nil;
    }
}

- (NSString *) dateTimeNowString {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"[HH:mm:ss.SSS]"];
    return [format stringFromDate:[NSDate date]];
}

- (void) appendToLogsWithTime: (NSString *) line {
    [self appendToLogs:[[self dateTimeNowString] stringByAppendingFormat:@" %@", line]];
}

- (void) appendToLogs:(NSString *) line {
    self.logsTextView.text = [self.logsTextView.text stringByAppendingFormat:@"%@\n", line];
}

@end
