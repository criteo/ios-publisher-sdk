//
//  CR_NativeAdTableViewCell.h
//  pubsdkITests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRMediaView;
@class CRNativeAdView;

NS_ASSUME_NONNULL_BEGIN

@interface CR_NativeAdTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CRNativeAdView *nativeAdView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;
@property (weak, nonatomic) IBOutlet CRMediaView *productMediaView;
@property (weak, nonatomic) IBOutlet UILabel *advertiserDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *advertiserDomainUrlLabel;
@property (weak, nonatomic) IBOutlet CRMediaView *advertiserLogoMediaView;

@end

NS_ASSUME_NONNULL_END
