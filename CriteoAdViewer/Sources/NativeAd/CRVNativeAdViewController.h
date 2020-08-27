//
//  CRSimpleNativeAdViewController.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CRNativeAdUnit;
@protocol CRVNativeAdViewControllerDelegate;

@interface CRVNativeAdViewController : UIViewController

@property(nonatomic, weak) id<CRVNativeAdViewControllerDelegate> delegate;

@end

@protocol CRVNativeAdViewControllerDelegate <NSObject>

- (CRNativeAdUnit *)adUnitForViewController:(CRVNativeAdViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
