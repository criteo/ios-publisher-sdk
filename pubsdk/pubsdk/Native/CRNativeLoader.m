//
//  CRNativeLoader.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "Criteo+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CRNativeAdUnit.h"
#import "CRNativeAd+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_CdbBid.h"
#import "NSError+Criteo.h"
#import "Logging.h"
#import "CR_DefaultMediaDownloader.h"

@implementation CRNativeLoader

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit {
    return [self initWithAdUnit:adUnit criteo:[Criteo sharedCriteo]];
}

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit criteo:(Criteo *)criteo {
    if (self = [super init]) {
        _adUnit = adUnit;
        _criteo = criteo;
        _mediaDownloader = [[CR_DefaultMediaDownloader alloc] init];
    }
    return self;
}

- (void)loadAd {
    @try {
        [self unsafeLoadAd];
    }
    @catch (NSException *exception) {
        CLogException(exception);
    }
}

- (BOOL)canConsumeBid {
    return self.canNotifyDidReceiveAd;
}

- (void)unsafeLoadAd {
    if (!self.canConsumeBid) {
        return;
    }

    CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:self.adUnit];
    CR_CdbBid *bid = [self.criteo getBid:cacheAdUnit];

    if (bid.isEmpty) {
        NSError *error = [NSError cr_errorWithCode:CRErrorCodeNoFill];
        [self notifyFailToReceiveAdWithError:error];
        return;
    }

    CRNativeAd *ad = [[CRNativeAd alloc] initWithLoader:self assets:bid.nativeAssets];
    [self notifyDidReceiveAd:ad];
}

#pragma mark - Delegate call

- (void)notifyFailToReceiveAdWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(nativeLoader:didFailToReceiveAdWithError:)]) {
            [self.delegate nativeLoader:self didFailToReceiveAdWithError:error];
        }
    });
}

- (BOOL)canNotifyDidReceiveAd {
    return [self.delegate respondsToSelector:@selector(nativeLoader:didReceiveAd:)];
}

- (void)notifyDidReceiveAd:(CRNativeAd *)ad {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.canNotifyDidReceiveAd) {
            [self.delegate nativeLoader:self didReceiveAd:ad];
        }
    });
}

- (void)notifyDidDetectImpression {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(nativeLoaderDidDetectImpression:)]) {
            [self.delegate nativeLoaderDidDetectImpression:self];
        }
    });
}

- (void)notifyDidDetectClick {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(nativeLoaderDidDetectClick:)]) {
            [self.delegate nativeLoaderDidDetectClick:self];
        }
    });
}

- (void)notifyWillLeaveApplicationForNativeAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(nativeLoaderWillLeaveApplicationForNativeAd:)]) {
            [self.delegate nativeLoaderWillLeaveApplicationForNativeAd:self];
        }
    });
}

@end

