//
//  StandaloneViewControllerTableViewController.m
//  AdViewer
//
//  Created by Aleksandr Pakhmutov on 29/10/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "StandaloneTableViewController.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

@interface StandaloneTableViewController () <CRInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UIView *banner_320x50View;

@property (nonatomic, strong) CRBannerView *cr_banner_320x50View;
@property (nonatomic, strong) CRInterstitial *cr_interstitialView;

@end

@implementation StandaloneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)banner320x50ButtonClick:(id)sender {
    self.cr_banner_320x50View = [[CRBannerView alloc] initWithAdUnit:self.homePageVC.criteoBannerAdUnit_320x50];

    [self.cr_banner_320x50View loadAd];

    [self.banner_320x50View addSubview:self.cr_banner_320x50View];
}

- (IBAction)clearButton:(id)sender {
    [self resetBannerView:self.cr_banner_320x50View];
    [super updateInterstitialButtonsForAdLoaded:NO];
    self.cr_interstitialView = nil;
}

- (IBAction)loadInterstitialClick:(id)sender {
    [super onLoadInterstitial];
    self.cr_interstitialView = [[CRInterstitial alloc] initWithAdUnit:[super adUnitForInterstitial]];
    self.cr_interstitialView.delegate = self;
    [self.cr_interstitialView loadAd];
}

- (IBAction)showInterstitialClick:(id)sender {
    [self.cr_interstitialView presentFromRootViewController:self];
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
    [super updateInterstitialButtonsForAdLoaded:NO];
}

- (void)interstitialIsReadyToPresent:(CRInterstitial *)interstitial {
    [super updateInterstitialButtonsForAdLoaded:YES];
}

# pragma mark - Private

- (void) resetBannerView:(UIView *)bannerView {
    if (bannerView) {
        [bannerView removeFromSuperview];
        bannerView = nil;
    }
}

@end
