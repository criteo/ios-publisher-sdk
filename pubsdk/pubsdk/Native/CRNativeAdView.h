//
//  CRNativeAdView.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

@import UIKit;

@class CRNativeAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * View that wrap a UIView for displaying an Advanced Native Ad.
 */
@interface CRNativeAdView : UIView

@property (strong, nonatomic, nullable) CRNativeAd *nativeAd;

@end

NS_ASSUME_NONNULL_END
