//
//  CRNativeLoader.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "Criteo+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CRNativeAdUnit.h"
#import "CRNativeAd+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_CdbBid.h"
#import "NSError+CRErrors.h"
#import "Logging.h"

@implementation CRNativeLoader

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit
                      delegate:(id <CRNativeDelegate>)delegate {
    return [self initWithAdUnit:adUnit
                       delegate:delegate
                         criteo:[Criteo sharedCriteo]];
}

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit
                      delegate:(id <CRNativeDelegate>)delegate
                        criteo:(Criteo *)criteo {
    if (self = [super init]) {
        _adUnit = adUnit;
        _delegate = delegate;
        _criteo = criteo;
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

- (void)unsafeLoadAd {
    CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:self.adUnit];
    CR_CdbBid *bid = [self.criteo getBid:cacheAdUnit];

    if (bid.isEmpty) {
        NSError *error = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
        [self notifyFailToReceiveAdWithError:error];
        return;
    }

    CRNativeAd *ad = [[CRNativeAd alloc] initWithNativeAssets:bid.nativeAssets];
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

- (void)notifyDidReceiveAd:(CRNativeAd *)ad {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(nativeLoader:didReceiveAd:)]) {
            [self.delegate nativeLoader:self didReceiveAd:ad];
        }
    });
}

@end

