//
//  CRNativeLoader.h
//  pubsdk
//
//  Created by Romain Lofaso on 2/10/20.
//  Copyright © 2020 Criteo. All rights reserved.
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

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit
                      delegate:(id <CRNativeDelegate>)delegate;

/**
 * Load the native ad for standalone integration.
 */
- (void)loadAd;

@end

@protocol CRNativeDelegate <NSObject>

@optional

/**
 * Callback invoked when a native ad is successfully received. It is expected to display the native
 * ad.
 *
 * This callback is invoked on main dispatch queue, so it is safe to execute UI operations in the
 * implementation.
 *
 * @param nativeAd native ad with the data that may be used to render it
 */
-(void)native:(CRNativeLoader *)native didReceiveAd:(CRNativeAd *)nativeAd;

/**
 * Callback invoked when the SDK fails to provide a native ad.
 *
 * This callback is invoked on main dispatch queue, so it is safe to execute UI operations in the
 * implementation.
 *
 * @param error error indicating the reason of the failure
 */
-(void)native:(CRNativeLoader *)native didFailToReceiveAdWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
