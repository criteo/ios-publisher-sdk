//
//  HomePageTableViewController.m
//  CriteoMoPubAdapterTestApp
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "HomePageTableViewController.h"
#import "NativeAdView.h"
#import "CriteoNativeAdView.h"
#import "MoPub.h"
#import <CriteoMoPubAdapter/CRNativeAdRenderer.h>

@interface HomePageTableViewController () <MPAdViewDelegate,
                                           MPInterstitialAdControllerDelegate,
                                           MPNativeAdDelegate>

@property(weak, nonatomic) IBOutlet UIView *bannerView;
@property(weak, nonatomic) IBOutlet UIButton *presentInterstitialButton;
@property(weak, nonatomic) IBOutlet UIView *nativeViewContainer;

@property(nonatomic) MPAdView *mpAdView;
@property(nonatomic) MPInterstitialAdController *interstitial;
@property(nonatomic) MPNativeAd *nativeAd;
@property(nonatomic) UIView *nativeView;

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

- (IBAction)loadNativeClicked:(id)sender {
  MPStaticNativeAdRendererSettings *mopubSettings = [[MPStaticNativeAdRendererSettings alloc] init];
  mopubSettings.renderingViewClass = [NativeAdView class];
  MPNativeAdRendererConfiguration *mopubRenderer =
      [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:mopubSettings];

  MPStaticNativeAdRendererSettings *criteoSettings =
      [[MPStaticNativeAdRendererSettings alloc] init];
  criteoSettings.renderingViewClass = [CriteoNativeAdView class];
  MPNativeAdRendererConfiguration *criteoRenderer =
      [CRNativeAdRenderer rendererConfigurationWithRendererSettings:criteoSettings];

  MPNativeAdRequest *adRequest =
      [MPNativeAdRequest requestWithAdUnitIdentifier:@"8dc4347f92944be29071bed7666ba7cf"
                              rendererConfigurations:@[ mopubRenderer, criteoRenderer ]];

  MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
  targeting.desiredAssets =
      [NSSet setWithObjects:kAdTitleKey, kAdTextKey, kAdCTATextKey, kAdIconImageKey,
                            kAdMainImageKey, kAdStarRatingKey,
                            nil];  // The constants correspond to the 6 elements of MoPub native ads
  adRequest.targeting = targeting;

  [adRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response,
                                          NSError *error) {
    if (error) {
      // Handle error.
    } else {
      self.nativeAd = response;
      self.nativeAd.delegate = self;
      [self removeNativeClicked:nil];
      self.nativeView = [response retrieveAdViewWithError:nil];
      self.nativeView.frame = self.nativeViewContainer.bounds;
      [self.nativeViewContainer addSubview:self.nativeView];
    }
  }];
}

- (IBAction)removeNativeClicked:(id)sender {
  [self.nativeView removeFromSuperview];
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
