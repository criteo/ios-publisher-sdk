//
//  CRVNativeAdViewController.m
//  CriteoAdViewer
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

#import <CriteoPublisherSdk/CriteoPublisherSdk.h>
#import "CRVNativeAdViewController.h"
#import "CRVNativeAdView.h"
#import "LogManager.h"
#import "StandaloneLogger.h"

@interface CRVNativeAdViewController () <CRNativeLoaderDelegate>

@property(weak, nonatomic) IBOutlet UIView *adViewContainer;

@property(strong, nonatomic) CRNativeAdUnit *adUnit;
@property(strong, nonatomic) CRVNativeAdView *adView;
@property(strong, nonatomic) StandaloneLogger *logger;

@end

@implementation CRVNativeAdViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.logger = [[StandaloneLogger alloc] init];
}

#pragma mark - IBAction

- (IBAction)onStandaloneLoadClick:(UIButton *)button {
  NSAssert(self.delegate, @"");
  CRNativeAdUnit *adUnit = [self.delegate adUnitForViewController:self];
  CRNativeLoader *nativeLoader = [[CRNativeLoader alloc] initWithAdUnit:adUnit];
  nativeLoader.delegate = self;
  [nativeLoader loadAdWithContext:CRContextData.new];
}

#pragma mark - Properties

- (void)setAdView:(CRVNativeAdView *)adView {
  if (_adView != adView) {
    [_adView removeFromSuperview];
    _adView = adView;
    _adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _adView.frame = self.adViewContainer.bounds;
    [self.adViewContainer addSubview:_adView];
  }
}

#pragma mark - CRNativeDelegate

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
  [_logger nativeLoader:loader didReceiveAd:ad];
  NSBundle *bundle = [NSBundle mainBundle];
  CRVNativeAdView *view =
      [bundle loadNibNamed:@"CRVNativeAdView" owner:nil options:nil].firstObject;
  view.nativeAd = ad;
  view.titleLabel.text = ad.title;
  view.bodyLabel.text = ad.body;
  self.adView = view;
}

- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error {
  [_logger nativeLoader:loader didFailToReceiveAdWithError:error];
}

@end
