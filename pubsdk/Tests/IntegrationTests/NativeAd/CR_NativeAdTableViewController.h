//
//  CR_NativeAdTableViewController.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CRNativeAdUnit;
@class Criteo;
@class CR_NativeAdTableViewCell;
@class CRNativeLoader;

@interface CR_NativeAdTableViewController : UITableViewController

+ (instancetype)nativeAdTableViewControllerWithCriteo:(Criteo *)criteo;

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CRNativeAdUnit *adUnit;
@property(strong, nonatomic, readonly) CRNativeLoader *adLoader;
/**
 * If nil, a default value is assigned,
 */
@property(strong, nonatomic) NSArray<NSIndexPath *> *nativeAdIndexPaths;
@property(strong, nonatomic, readonly) CR_NativeAdTableViewCell *lastFilledAdCell;
@property(strong, nonatomic) UIImage *mediaPlaceholder;

#pragma Properties to verify the delegate

@property(assign, nonatomic, readonly) NSUInteger adLoadedCount;
@property(assign, nonatomic, readonly) NSUInteger detectImpressionCount;
@property(assign, nonatomic, readonly) NSUInteger detectClickCount;
@property(assign, nonatomic, readonly) NSUInteger leaveAppCount;

/**
 * Scroll at a given index path.
 *
 * The scroll is dispatch after less than one second. A lot of hours of debug
 * have shown that if the tableview is reloading its data while we scroll, the
 * scroll doesn't work and finish in the middle of nowhere. This approach may
 * induce flackiness on slow devices. The time and the experience will show it (or not).
 */
- (void)scrollAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Tap on the native ad at the given index path.
 *
 * It use a retry mechanism to be sure that the tap is done when the cell is well configured.
 * Indeed, there are some cases where the try to tap on a cell that has just been reloaded
 * with [self.tableView reloadData] and the cell doesn't contain the native ad yet.
 */
- (void)tapOnNativeAdAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
