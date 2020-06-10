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
 *
 * You need to call super if you override methods.
 */
@interface CRNativeAdView : UIControl

/**
 * The advanced native ad associated to the view.
 *
 * The assignation of the native ad is mandatory to track the impression and the clicks on the
 * advanced native ad.
 */
@property (strong, nonatomic, nullable) CRNativeAd *nativeAd;

@end

NS_ASSUME_NONNULL_END
