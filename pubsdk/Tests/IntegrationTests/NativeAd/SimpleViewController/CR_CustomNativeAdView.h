//
//  CR_CustomNativeAdView.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAdView.h"

@class CRNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface CR_CustomNativeAdView : CRNativeAdView

@property (strong, nonatomic) CRNativeAd *nativeAd;

@end

NS_ASSUME_NONNULL_END
