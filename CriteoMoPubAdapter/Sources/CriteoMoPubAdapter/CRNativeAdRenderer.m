//
//  CRNativeAdRenderer.m
//  CriteoMoPubAdapter
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

#import "CRNativeAdRenderer.h"
#import "CRNativeAdAdapter.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

@interface CRNativeAdRenderer () <MPNativeAdRendererImageHandlerDelegate>

@property(nonatomic, strong) CRNativeAdAdapter *adapter;
@property(nonatomic, strong) CRNativeAdView<MPNativeAdRendering> *adView;
@property(nonatomic, strong) Class renderingViewClass;
@property(nonatomic) BOOL adViewInViewHierarchy;
@property(nonatomic) MPNativeAdRendererImageHandler *rendererImageHandler;

@end

@implementation CRNativeAdRenderer

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
  if (self = [super init]) {
    MPStaticNativeAdRendererSettings *settings =
        (MPStaticNativeAdRendererSettings *)rendererSettings;
    _renderingViewClass = settings.renderingViewClass;
    _viewSizeHandler = [settings.viewSizeHandler copy];
    _rendererImageHandler = [MPNativeAdRendererImageHandler new];
    _rendererImageHandler.delegate = self;
  }
  return self;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:
    (id<MPNativeAdRendererSettings>)rendererSettings {
  MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
  config.rendererClass = [self class];
  config.rendererSettings = rendererSettings;
  config.supportedCustomEvents = @[ @"CRNativeCustomEvent" ];
  return config;
}

- (UIView *)retrieveViewWithAdapter:(CRNativeAdAdapter<MPNativeAdAdapter> *)adapter
                              error:(NSError **)error {
  if (!adapter || ![adapter isKindOfClass:[CRNativeAdAdapter class]]) {
    if (error) {
      *error = MPNativeAdNSErrorForRenderValueTypeError();
    }

    return nil;
  }
  self.adapter = adapter;

  if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
    self.adView = (CRNativeAdView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd]
        instantiateWithOwner:nil
                     options:nil] firstObject];
  } else {
    self.adView = [[self.renderingViewClass alloc] init];
  }

  self.adView.nativeAd = [adapter nativeAd];

  self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

  if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
    self.adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
  }

  if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
    self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
  }

  if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)] &&
      self.adView.nativeCallToActionTextLabel) {
    self.adView.nativeCallToActionTextLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
  }

  if ([self hasMainMediaView]) {
    UIView *mediaView = [self.adapter mainMediaView];
    UIView *mainImageView = [self.adView nativeMainImageView];

    mediaView.frame = mainImageView.bounds;
    mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [mainImageView addSubview:mediaView];
  }

  if ([self hasIconView]) {
    UIView *iconView = [adapter iconMediaView];
    UIView *iconImageView = [self.adView nativeIconImageView];

    iconView.frame = iconImageView.bounds;
    iconView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [iconImageView addSubview:iconView];
  }

  return self.adView;
}

- (void)adViewWillMoveToSuperview:(UIView *)superview {
  self.adViewInViewHierarchy = (superview != nil);
}

#pragma mark - MPNativeAdRendererImageHandlerDelegate

- (BOOL)nativeAdViewInViewHierarchy {
  return self.adViewInViewHierarchy;
}

#pragma mark - Private

- (BOOL)hasMainMediaView {
  return [self.adapter respondsToSelector:@selector(mainMediaView)] &&
         [self.adapter mainMediaView] &&
         [self.adView respondsToSelector:@selector(nativeMainImageView)];
}

- (BOOL)hasIconView {
  return [self.adapter respondsToSelector:@selector(iconMediaView)] &&
         [self.adapter iconMediaView] &&
         [self.adView respondsToSelector:@selector(nativeIconImageView)];
}

@end
