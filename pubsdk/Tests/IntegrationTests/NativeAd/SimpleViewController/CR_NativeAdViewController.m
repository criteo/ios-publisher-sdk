//
//  CR_NativeAdViewController.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NativeAdViewController.h"
#import "Criteo.h"
#import "CRNativeLoader.h"
#import "CRNativeLoader+Internal.h"
#import "CRNativeAdUnit.h"
#import "CRNativeAd.h"
#import "CR_CustomNativeAdView.h"
#import "CR_URLOpenerMock.h"

@interface CR_NativeAdViewController () <CRNativeDelegate>

@property (strong, nonatomic) CRNativeLoader *adLoader;
@property (strong, nonatomic) CRNativeAd *ad;
@property (strong, nonatomic) CR_CustomNativeAdView *adView;

@property (assign, nonatomic) NSUInteger adLoadedCount;
@property (assign, nonatomic) NSUInteger detectClickCount;
@property (assign, nonatomic) NSUInteger leaveAppCount;

@end

@implementation CR_NativeAdViewController

+ (instancetype)nativeAdViewControllerWithCriteo:(Criteo *)criteo {
    CR_NativeAdViewController *ctrl = [[CR_NativeAdViewController alloc] init];
    ctrl.criteo = criteo;
    return ctrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect adViewFrame = (CGRect) {
        0, 0,
        self.view.frame.size.width,
        self.view.frame.size.height / 2
    };
    self.adView = [[CR_CustomNativeAdView alloc] initWithFrame:adViewFrame];
    self.adView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.adView];
}

- (void)setAdUnit:(CRNativeAdUnit *)adUnit {
    if (adUnit != _adUnit) {
        _adUnit = adUnit;
        self.adLoader = (_adUnit) ?
            [[CRNativeLoader alloc] initWithAdUnit:adUnit
                                            criteo:self.criteo
                                         urlOpener:[[CR_URLOpenerMock alloc] init]] :
            nil;
        self.adLoader.delegate = self;
    }
}

#pragma mark - CRNativeDelegate

 - (void)nativeLoader:(CRNativeLoader *)loader
         didReceiveAd:(CRNativeAd *)ad {
     self.ad = ad;
     self.adView.nativeAd = ad;
     self.adLoadedCount += 1;
}

-(void)nativeLoader:(CRNativeLoader *)loader
didFailToReceiveAdWithError:(NSError *)error {

}

- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader {

}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader {
    self.detectClickCount += 1;
}

-(void)nativeLoaderWillLeaveApplicationForNativeAd:(CRNativeLoader *)loader {
    self.leaveAppCount += 1;
}

@end
