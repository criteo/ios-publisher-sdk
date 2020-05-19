//
//  CRNativeLoader.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

@import Foundation;

@class CRNativeAdUnit;
@class CRNativeAd;
@protocol CRNativeDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * Advanced Native Ad Loader
 */
@interface CRNativeLoader : NSObject

@property (nonatomic, weak) id<CRNativeDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit;

/**
 * Load the native ad for standalone integration.
 */
- (void)loadAd;

@end

/**
 * All the methods of the CRNativeDelegate are invoked on main dispatch queue,
 * so it is safe to execute UI operations in the implementation.
 */
@protocol CRNativeDelegate <NSObject>

@optional

/**
 * Callback invoked when a native ad is successfully received. It is expected to display the native
 * ad.
 *
 * @param loader Native loader invoking the callback
 * @param ad native ad with the data that may be used to render it
 */
-(void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad;

/**
 * Callback invoked when the SDK fails to provide a native ad.
 *
 * @param loader Native loader invoking the callback
 * @param error error indicating the reason of the failure
 */
-(void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error;

/**
 * Callback invoked when a native ad impression is detected.
 *
 * @param loader Native loader invoking the callback
 */
- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader;

/**
 * Callback invoked when a native ad is clicked.
 *
 * @param loader Native loader invoking the callback
 */
- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader;

/**
 * Callback invoked when user clicks on an Ad or AdChoice button, opening its associated URL
 *
 * @param loader Native loader invoking the callback
 */
-(void)nativeLoaderWillLeaveApplicationForNativeAd:(CRNativeLoader *)loader;

@end

NS_ASSUME_NONNULL_END
