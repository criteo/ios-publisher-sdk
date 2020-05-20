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

@interface CR_NativeAdTableViewController : UITableViewController

+ (instancetype)nativeAdTableViewControllerWithCriteo:(Criteo *)criteo;

@property (strong, nonatomic) Criteo *criteo;
@property (strong, nonatomic) CRNativeAdUnit *adUnit;
@property (assign, nonatomic, readonly, getter=isAdLoaded) BOOL adLoaded;

@end

NS_ASSUME_NONNULL_END
