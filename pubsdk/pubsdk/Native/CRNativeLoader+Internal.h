//
//  CRNativeLoader+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeLoader.h"
#import "Criteo.h"

@class CR_ThreadManager;

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeLoader ()

@property (nonatomic, strong, readonly) Criteo *criteo;
@property (nonatomic, strong, readonly) CRNativeAdUnit *adUnit;
@property (nonatomic, strong, readonly) CR_ThreadManager *threadManager;

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit
                        criteo:(Criteo *)criteo;

- (void)handleImpressionOnNativeAd:(CRNativeAd *)nativeAd;
- (void)handleClickOnNativeAd:(CRNativeAd *)nativeAd;

- (void)notifyDidDetectImpression;
- (void)notifyDidDetectClick;
- (void)notifyWillLeaveApplicationForNativeAd;

@end

NS_ASSUME_NONNULL_END
