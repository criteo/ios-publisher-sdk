//
//  CRNativeAdView.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAdView.h"
#import "CR_AdChoice.h"

@interface CRNativeAdView ()

@property (strong, nonatomic, nullable) CR_AdChoice *adChoice;

@end

@implementation CRNativeAdView

- (void)setNativeAd:(CRNativeAd *)nativeAd {
    _nativeAd = nativeAd;
    self.adChoice.nativeAd = _nativeAd;
}

#pragma mark - Private

- (CR_AdChoice *)adChoice {
    if (_adChoice == nil) {
        _adChoice = [[CR_AdChoice alloc] init];
        [self addSubview:_adChoice];
    }
    return _adChoice;
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

@end
