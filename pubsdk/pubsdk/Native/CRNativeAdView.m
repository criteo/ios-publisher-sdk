//
//  CRNativeAdView.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAdView.h"
#import "CRNativeAd+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CR_AdChoice.h"
#import "CR_ImpressionDetector.h"
#import "CR_NativeProduct.h"
#import "NSURL+Criteo.h"


@interface CRNativeAdView () <CR_ImpressionDetectorDelegate>

@property (weak, nonatomic, readonly) CRNativeLoader *loader;
@property (strong, nonatomic, nullable) CR_AdChoice *adChoice;
@property (strong, nonatomic, readonly) CR_ImpressionDetector *impressionDetector;

@end

@implementation CRNativeAdView

#pragma mark - Life cycle

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

#pragma mark - Properties

- (void)setNativeAd:(CRNativeAd *)nativeAd {
    if (_nativeAd != nativeAd) {
        _nativeAd = nativeAd;
        self.adChoice.nativeAd = nativeAd;
        self.adChoice.hidden = (nativeAd == nil);
        [self detectImpressionIfNeededForNativeAd:nativeAd];
    }
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutAdChoice];
}

#pragma mark - Private

- (void)sharedInit {
    _adChoice = [[CR_AdChoice alloc] init];
    _adChoice.hidden = YES;
    [self addSubview:_adChoice];
    _impressionDetector = [[CR_ImpressionDetector alloc] initWithView:self];
    _impressionDetector.delegate = self;
    [self addTarget:self
              action:@selector(adClicked:)
    forControlEvents:UIControlEventTouchUpInside];
}

- (void)detectImpressionIfNeededForNativeAd:(nullable CRNativeAd *)nativeAd {
    BOOL dontNeedDetection = (nativeAd == nil) || nativeAd.isImpressed;
    if (dontNeedDetection) {
        [self.impressionDetector stopDetection];
        return;
    }

    [self.impressionDetector startDetection];
}

- (CRNativeLoader *)loader {
    return self.nativeAd.loader;
}

- (void)layoutAdChoice {
    // Frontmost
    [self bringSubviewToFront:_adChoice];
    // Top right
    CGSize adChoiceSize = _adChoice.bounds.size;
    CGFloat top = 0;
    CGFloat right = self.bounds.size.width - adChoiceSize.width;
    self.adChoice.frame = (CGRect) {right, top, adChoiceSize};
}

#pragma mark - Events

- (void)adClicked:(id)control {
    [self.loader handleClickOnNativeAd:self.nativeAd];
}

#pragma mark Impression Detection

- (void)impressionDetectorDidDetectImpression:(CR_ImpressionDetector *)detector {
    [self.loader handleImpressionOnNativeAd:self.nativeAd];
}

@end
