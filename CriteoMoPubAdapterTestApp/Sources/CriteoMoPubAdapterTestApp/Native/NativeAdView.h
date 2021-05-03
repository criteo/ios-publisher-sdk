//
//  NativeAdView.h
//  CriteoMoPubAdapterTestApp
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

#import "MoPub.h"

NS_ASSUME_NONNULL_BEGIN

@interface NativeAdView : UIView <MPNativeAdRendering>

@property(strong, nonatomic) IBOutlet UILabel *titleLabel;
@property(strong, nonatomic) IBOutlet UILabel *mainTextLabel;
@property(strong, nonatomic) IBOutlet UILabel *callToActionLabel;
@property(strong, nonatomic) IBOutlet UILabel *sponsoredByLabel;
@property(strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property(strong, nonatomic) IBOutlet UIImageView *mainImageView;
@property(strong, nonatomic) IBOutlet UIImageView *privacyInformationIconImageView;

@end

NS_ASSUME_NONNULL_END
