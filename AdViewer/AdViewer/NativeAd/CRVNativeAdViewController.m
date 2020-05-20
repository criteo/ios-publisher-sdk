//
//  CRSimpleNativeAdViewController.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <CriteoPublisherSdk/CriteoPublisherSdk.h>
#import "CRVNativeAdViewController.h"
#import "CRVNativeAdView.h"
#import "LogManager.h"
#import "StandaloneLogger.h"

@interface CRVNativeAdViewController () <CRNativeDelegate>

@property (weak, nonatomic) IBOutlet UIView *adViewContainer;

@property (strong, nonatomic) CRNativeAdUnit *adUnit;
@property (strong, nonatomic) CRVNativeAdView *adView;
@property (strong, nonatomic) StandaloneLogger *logger;

@end

@implementation CRVNativeAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logger = [[StandaloneLogger alloc] init];
}

#pragma mark - IBAction

- (IBAction)onStandaloneLoadClick:(UIButton *)button {
    NSAssert(self.delegate, @"");
    CRNativeAdUnit *adUnit = [self.delegate adUnitForViewController:self];
    CRNativeLoader *nativeLoader = [[CRNativeLoader alloc] initWithAdUnit:adUnit];
    nativeLoader.delegate = self;
    [nativeLoader loadAd];
}

#pragma mark - Properties

- (void)setAdView:(CRVNativeAdView *)adView {
    if (_adView != adView) {
        [_adView removeFromSuperview];
        _adView = adView;
        _adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _adView.frame = self.adViewContainer.bounds;
        [self.adViewContainer addSubview:_adView];
    }
}

#pragma mark - CRNativeDelegate

-(void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
    [_logger nativeLoader:loader didReceiveAd:ad];
    NSBundle *bundle = [NSBundle mainBundle];
    CRVNativeAdView *view = [bundle loadNibNamed:@"CRVNativeAdView" owner:nil options:nil].firstObject;
    view.nativeAd = ad;
    view.titleLabel.text = ad.title;
    view.bodyLabel.text = ad.body;
    self.adView = view;
}

- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error {
    [_logger nativeLoader:loader didFailToReceiveAdWithError:error];
}

@end


