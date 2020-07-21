//
//  HomePageTableViewController.m
//  CriteoMoPubAdapterTestApp
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "HomePageTableViewController.h"
#import "MoPub.h"

@interface HomePageTableViewController () <MPAdViewDelegate, MPInterstitialAdControllerDelegate>

@property(weak, nonatomic) IBOutlet UIView *bannerView;
@property(weak, nonatomic) IBOutlet UIButton *presentInterstitialButton;

@property(nonatomic) MPAdView *mpAdView;
@property(nonatomic) MPInterstitialAdController *interstitial;

@end

@implementation HomePageTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.presentInterstitialButton.enabled = NO;
}

- (IBAction)loadBannerClicked:(id)sender {
  self.mpAdView = [[MPAdView alloc] initWithAdUnitId:@"5f6c4592630f4f96bc3106b6ed0cc3f1"];
  self.mpAdView.frame = CGRectMake(0, 0, 320, 50);
  self.mpAdView.delegate = self;
  [self.bannerView addSubview:self.mpAdView];
  [self.mpAdView loadAdWithMaxAdSize:kMPPresetMaxAdSizeMatchFrame];
}

- (IBAction)removeBannerClicked:(id)sender {
  [self.mpAdView removeFromSuperview];
  self.mpAdView = nil;
}

- (IBAction)loadInterstitialClicked:(id)sender {
  self.presentInterstitialButton.enabled = NO;
  self.interstitial = [MPInterstitialAdController
      interstitialAdControllerForAdUnitId:@"8e011bf4cf7a42cb9db61fde30a2af58"];

  self.interstitial.delegate = self;
  [self.interstitial loadAd];
}

- (IBAction)presentInterstitialClicked:(id)sender {
  if (self.interstitial.ready) {
    self.presentInterstitialButton.enabled = NO;
    [self.interstitial showFromViewController:self];
  }
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
  return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
  NSLog(@"MPAdViewDelegate.adViewDidLoadAd");
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
  NSLog(@"MPAdViewDelegate.didFailToLoadAdWithError: %@", error.localizedDescription);
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
  self.presentInterstitialButton.enabled = YES;
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
  NSLog(@"MPInterstitialAdControllerDelegate.interstitialDidFailToLoadAd");
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
                          withError:(NSError *)error {
  NSLog(@"MPInterstitialAdControllerDelegate.interstitialDidFailToLoadAd withError: %@",
        error.localizedDescription);
}

@end
