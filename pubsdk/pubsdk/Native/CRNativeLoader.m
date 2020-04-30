//
//  CRNativeLoader.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/10/20.
//  Copyright © 2020 Criteo. All rights reserved.
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

    CR_NativeAssets *assets = bid.nativeAssets;
    CR_NativeProduct *product = assets.products[0];

    CRNativeAd *ad = [[CRNativeAd alloc] initWithTitle:product.title
                                                  body:product.description
                                                 price:product.price
                                          callToAction:product.callToAction
                                       productImageUrl:product.image.url
                                 advertiserDescription:assets.advertiser.description
                                      advertiserDomain:assets.advertiser.domain
                                advertiserLogoImageUrl:assets.advertiser.logoImage.url];
    [self notifyDidReceiveAd:ad];
}

#pragma mark - Delegate call

- (void)notifyFailToReceiveAdWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(native:didFailToReceiveAdWithError:)]) {
            [self.delegate native:self didFailToReceiveAdWithError:error];
        }
    });
}

- (void)notifyDidReceiveAd:(CRNativeAd *)ad {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(native:didReceiveAd:)]) {
            [self.delegate native:self didReceiveAd:ad];
        }
    });
}

@end

