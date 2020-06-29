//
//  CR_NativeAdViewController.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Criteo;
@class CRNativeAdUnit;
@class CRNativeLoader;
@class CR_SafeAreaView;
@class CR_CustomNativeAdView;

@interface CR_NativeAdViewController : UIViewController

+ (instancetype)nativeAdViewControllerWithCriteo:(Criteo *)criteo;

@property(assign, nonatomic, getter=isAdViewInSafeArea)
    BOOL adViewInSafeArea API_AVAILABLE(ios(11.0));  // Default YES

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CRNativeAdUnit *adUnit;
@property(strong, nonatomic, readonly) CRNativeLoader *adLoader;
@property(strong, nonatomic, readonly) CR_CustomNativeAdView *adView;

#pragma mark Delegate counters

@property(assign, nonatomic, readonly) NSUInteger adLoadedCount;
@property(assign, nonatomic, readonly) NSUInteger detectImpressionCount;
@property(assign, nonatomic, readonly) NSUInteger detectClickCount;
@property(assign, nonatomic, readonly) NSUInteger leaveAppCount;

@end

NS_ASSUME_NONNULL_END
