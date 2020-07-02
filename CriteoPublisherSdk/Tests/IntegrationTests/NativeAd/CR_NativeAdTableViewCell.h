//
//  CR_NativeAdTableViewCell.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

@class CRMediaView;
@class CRNativeAdView;

NS_ASSUME_NONNULL_BEGIN

@interface CR_NativeAdTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet CRNativeAdView *nativeAdView;
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property(weak, nonatomic) IBOutlet UILabel *priceLabel;
@property(weak, nonatomic) IBOutlet UILabel *callToActionLabel;
@property(weak, nonatomic) IBOutlet CRMediaView *productMediaView;
@property(weak, nonatomic) IBOutlet UILabel *advertiserDescriptionLabel;
@property(weak, nonatomic) IBOutlet UILabel *advertiserDomainUrlLabel;
@property(weak, nonatomic) IBOutlet CRMediaView *advertiserLogoMediaView;

@end

NS_ASSUME_NONNULL_END
