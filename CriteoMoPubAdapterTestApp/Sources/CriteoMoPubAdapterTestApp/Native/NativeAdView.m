//
//  NativeAdView.m
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

#import "NativeAdView.h"

#define NIB_NAME @"NativeAdView"

@interface NativeAdView()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation NativeAdView

- (void)layoutSubviews {
  [super layoutSubviews];
}

+ (UINib *)nibForAd {
  NSLog(@"CriteoSDK Rendering %@", NIB_NAME);
  return [UINib nibWithNibName:NIB_NAME bundle:nil];
}

- (UILabel *)nativeMainTextLabel
{
    return self.mainTextLabel;
}

- (UILabel *)nativeTitleTextLabel
{
    return self.titleLabel;
}

- (UILabel *)nativeCallToActionTextLabel
{
    return self.callToActionLabel;
}

- (UILabel *)nativeSponsoredByCompanyTextLabel
{
    return self.sponsoredByLabel;
}

- (UIImageView *)nativeIconImageView
{
    return self.iconImageView;
}

- (UIImageView *)nativeMainImageView
{
    return self.mainImageView;
}

- (UIImageView *)nativePrivacyInformationIconImageView
{
    return self.privacyInformationIconImageView;
}

+ (NSString *)localizedSponsoredByTextWithSponsorName:(NSString *)sponsorName {
  return [NSString stringWithFormat:@"Sponsored by %@", sponsorName];
}

@end
