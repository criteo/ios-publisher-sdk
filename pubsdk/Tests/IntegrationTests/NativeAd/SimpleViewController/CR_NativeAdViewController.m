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
#import "CR_SafeAreaView.h"
#import "CR_URLOpenerMock.h"

@interface CR_NativeAdViewController () <CRNativeLoaderDelegate>

@property (strong, nonatomic, nullable) CR_SafeAreaView *safeView API_AVAILABLE(ios(11.0));

@property (strong, nonatomic) CRNativeLoader *adLoader;
@property (strong, nonatomic) CRNativeAd *ad;
@property (strong, nonatomic) CR_CustomNativeAdView *adView;

@property (assign, nonatomic) NSUInteger adLoadedCount;
@property (assign, nonatomic) NSUInteger detectImpressionCount;
@property (assign, nonatomic) NSUInteger detectClickCount;
@property (assign, nonatomic) NSUInteger leaveAppCount;

@end

@implementation CR_NativeAdViewController

#pragma mark - Life Cycle

+ (instancetype)nativeAdViewControllerWithCriteo:(Criteo *)criteo {
    CR_NativeAdViewController *ctrl = [[CR_NativeAdViewController alloc] init];
    ctrl.criteo = criteo;
    return ctrl;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _adViewInSafeArea = YES;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        _adViewInSafeArea = YES;
    }
    return self;
}

#pragma mark - UIView

- (void)loadView {
    CGRect frame = [UIScreen mainScreen].bounds;
    if (@available(iOS 11.0, *)) {
        self.safeView = [[CR_SafeAreaView alloc] initWithFrame:frame];
        self.view = self.safeView;
    } else {
        self.view = [[UIView alloc] initWithFrame:frame];
    }
}

- (void)viewDidLoad {
    self.adView = [[CR_CustomNativeAdView alloc] initWithFrame:[self computedAdViewFrame]];
    self.adView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.adView];
}

#pragma mark - Public

- (void)setAdViewInSafeArea:(BOOL)adViewInSafeArea {
    if (_adViewInSafeArea != adViewInSafeArea) {
        _adViewInSafeArea = adViewInSafeArea;
        [self updateAdViewFrame];
    }
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
    self.detectImpressionCount += 1;
}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader {
    self.detectClickCount += 1;
}

-(void)nativeLoaderWillLeaveApplication:(CRNativeLoader *)loader {
    self.leaveAppCount += 1;
}

#pragma mark - Private

- (void)updateAdViewFrame {
    self.adView.frame = [self computedAdViewFrame];
}

- (CGRect)computedAdViewFrame {
    if (@available(iOS 11.0, *)) {
        if (self.isAdViewInSafeArea) {
            return UIEdgeInsetsInsetRect(self.view.bounds,
                                         self.view.safeAreaInsets);
        } else {
            return self.safeView.unsafeAreaFrame;
        }
    }
    return self.view.frame;
}

@end
