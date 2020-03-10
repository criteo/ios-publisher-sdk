//
//  StandaloneViewControllerTableViewController.m
//  AdViewer
//
//  Created by Aleksandr Pakhmutov on 29/10/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "StandaloneTableViewController.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>
#import "LogManager.h"
#import "StandaloneLogger.h"

@interface StandaloneTableViewController ()
@property (strong, nonatomic) LogManager *logManager;
@property (strong, nonatomic) StandaloneLogger *logger;

@property (weak, nonatomic) IBOutlet UIView *banner_320x50View;

@property (nonatomic, strong) CRBannerView *cr_banner_320x50View;
@property (nonatomic, strong) CRInterstitial *cr_interstitialView;
@property (weak, nonatomic) IBOutlet UISwitch *bannerShouldCreateNewObject;
@property (weak, nonatomic) IBOutlet UISwitch *interstitialShouldCreateNewObject;

@end

@implementation StandaloneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logManager = [LogManager sharedInstance];
    self.logger = [[StandaloneLogger alloc] initWithInterstitialDelegate:self];
}

- (IBAction)banner320x50ButtonClick:(id)sender {
    if (self.bannerShouldCreateNewObject.on) {
        self.cr_banner_320x50View = [[CRBannerView alloc] initWithAdUnit:self.homePageVC.criteoBannerAdUnit_320x50];
        self.cr_banner_320x50View.delegate = self.logger;
    }

    [self.cr_banner_320x50View loadAd];
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

    [self.cr_interstitialView loadAd];
}

- (IBAction)showInterstitialClick:(id)sender {
    [self.cr_interstitialView presentFromRootViewController:self];
}

# pragma mark - Private

- (void) resetBannerView:(UIView *)bannerView {
    if (bannerView) {
        [bannerView removeFromSuperview];
    }
}

@end
