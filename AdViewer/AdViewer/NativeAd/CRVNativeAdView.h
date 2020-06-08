//
//  CRNativeAdView.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

@import UIKit;
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRVNativeAdView : CRNativeAdView<CRNativeDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *bodyLabel;
@property (nonatomic, weak) IBOutlet CRMediaView *productMediaView;
@property (nonatomic, weak) IBOutlet CRMediaView *advertiserMediaView;
@property (nonatomic, weak) IBOutlet UILabel *advertiserDescriptionLabel;

@end

NS_ASSUME_NONNULL_END
