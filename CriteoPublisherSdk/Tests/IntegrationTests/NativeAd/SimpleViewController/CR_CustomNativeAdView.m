//
//  CR_CustomNativeAdView.m
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

#import "CR_CustomNativeAdView.h"
#import "CRNativeAd.h"
#import "CRMediaView.h"

@interface CR_CustomNativeAdView ()

@property(strong, nonatomic, readonly) UILabel *label;

@end

@implementation CR_CustomNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.numberOfLines = 0;
    [self addSubview:_label];

    _productMediaView = [[CRMediaView alloc] initWithFrame:self.bounds];
    [self addSubview:_productMediaView];

    _advertiserLogoMediaView = [[CRMediaView alloc] initWithFrame:self.bounds];
    [self addSubview:_advertiserLogoMediaView];
  }
  return self;
}

- (void)setNativeAd:(CRNativeAd *)nativeAd {
  [super setNativeAd:nativeAd];
  [self clearLabel];
  [self addLabelValue:nativeAd.title forKey:@"title"];
  [self addLabelValue:nativeAd.body forKey:@"body"];
  [self addLabelValue:nativeAd.price forKey:@"price"];
  [self addLabelValue:nativeAd.callToAction forKey:@"callToAction"];
  [self addLabelValue:nativeAd.advertiserDescription forKey:@"advertiserDescription"];
  [self addLabelValue:nativeAd.advertiserDomain forKey:@"advertiserDomain"];
  [self addLabelValue:nativeAd.legalText forKey:@"legalText"];
  self.advertiserLogoMediaView.mediaContent = nativeAd.advertiserLogoMedia;
  self.productMediaView.mediaContent = nativeAd.productMedia;
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat verticalSeparator = CGRectGetWidth(self.bounds) * 0.75;
  CGFloat horizontalSeparator = CGRectGetHeight(self.bounds) / 2;
  self.label.frame = (CGRect){0, 0, verticalSeparator, CGRectGetHeight(self.bounds)};
  self.productMediaView.frame = (CGRect){
      verticalSeparator, 0, CGRectGetWidth(self.bounds) - verticalSeparator, horizontalSeparator};
  self.advertiserLogoMediaView.frame = (CGRect){verticalSeparator, horizontalSeparator,
                                                CGRectGetWidth(self.bounds) - verticalSeparator,
                                                CGRectGetHeight(self.bounds) - horizontalSeparator};
}

#pragma mark - Private

- (void)clearLabel {
  self.label.text = @"";
}

- (void)addLabelValue:(NSString *)value forKey:(NSString *)key {
  NSString *str = [[NSString alloc] initWithFormat:@"%@: %@", key, value];
  NSString *newText = [[NSString alloc] initWithFormat:@"%@\n%@", self.label.text, str];
  self.label.text = newText;
}

@end
