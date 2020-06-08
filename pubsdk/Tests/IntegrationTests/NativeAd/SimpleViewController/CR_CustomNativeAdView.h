//
//  CR_CustomNativeAdView.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAdView.h"

@class CRNativeAd;
@class CRMediaView;

NS_ASSUME_NONNULL_BEGIN

@interface CR_CustomNativeAdView : CRNativeAdView

@property (strong, nonatomic) CRMediaView *productMediaView;
@property (strong, nonatomic) CRMediaView *advertiserLogoMediaView;

@end

NS_ASSUME_NONNULL_END
