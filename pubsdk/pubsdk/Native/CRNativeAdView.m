//
//  CRNativeAdView.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAdView.h"
#import "CR_AdChoice.h"
#import "CRNativeAd+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CR_NativeProduct.h"

@interface CRNativeAdView ()

@property (weak, nonatomic, readonly) CRNativeLoader *loader;
@property (strong, nonatomic, nullable) CR_AdChoice *adChoice;

@end

@implementation CRNativeAdView

#pragma mark - Properties

- (void)setNativeAd:(CRNativeAd *)nativeAd {
    if (_nativeAd != nativeAd) {
        _nativeAd = nativeAd;
        self.adChoice.nativeAd = _nativeAd;
        [self addTarget:self action:@selector(adClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Private

- (CR_AdChoice *)adChoice {
    if (_adChoice == nil) {
        _adChoice = [[CR_AdChoice alloc] init];
        [self addSubview:_adChoice];
    }
    return _adChoice;
}

- (CRNativeLoader *)loader {
    return self.nativeAd.loader;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutAdChoice];
}

- (void)layoutAdChoice {
    // Frontmost
    [self bringSubviewToFront:_adChoice];
    // Top right
    CGSize adChoiceSize = _adChoice.bounds.size;
    CGFloat top = 0;
    CGFloat right = self.bounds.size.width - adChoiceSize.width;
    _adChoice.frame = (CGRect) {right, top, adChoiceSize};
}

#pragma mark - Events

- (void)adClicked:(id)control {
    [self.loader handleClickOnNativeAd:self.nativeAd];
}

@end
