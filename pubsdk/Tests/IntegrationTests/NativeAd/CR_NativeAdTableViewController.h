//
//  CR_NativeAdTableViewController.h
//  pubsdkITests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CRNativeAdUnit;
@class Criteo;
@class CR_NativeAdTableViewCell;
@class CRNativeLoader;

extern const NSUInteger kNativeAdCount;

@interface CR_NativeAdTableViewController : UITableViewController

+ (instancetype)nativeAdTableViewControllerWithCriteo:(Criteo *)criteo;

@property (strong, nonatomic) Criteo *criteo;
@property (strong, nonatomic) CRNativeAdUnit *adUnit;
@property (strong, nonatomic, readonly) CRNativeLoader *adLoader;
/**
 * If nil, a default value is assigned,
 */
@property (strong, nonatomic) NSArray<NSIndexPath *> *nativeAdIndexPaths;
@property (strong, nonatomic, readonly) CR_NativeAdTableViewCell *lastFilledAdCell;
@property (strong, nonatomic) UIImage *mediaPlaceholder;

#pragma Properties to verify the delegate

@property (assign, nonatomic, readonly) NSUInteger adLoadedCount;

@end

NS_ASSUME_NONNULL_END
