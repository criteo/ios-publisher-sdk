//
//  CRBannerCustomEvent.m
//  CriteoGoogleAdapter
//
//  Copyright © 2018-2022 Criteo. All rights reserved.
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

#import "CRBannerCustomEvent.h"
#include <stdatomic.h>
#import "CRGoogleMediationParameters.h"

@interface CRBannerCustomEvent () <GADMediationBannerAd, CRBannerViewDelegate> {
  //  The banner completion handler to call when the ad loading succeeds or fails.
  GADMediationBannerLoadCompletionHandler _completionHandler;
  // The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
  id<GADMediationBannerAdEventDelegate> _delegate;
}

@property(nonatomic, strong) CRBannerView *bannerView;

- (void)loadBannerForAdUnit:(CRBannerAdUnit *)adUnit
            mediationParams:(CRGoogleMediationParameters *)params
     childDirectedTreatment:(NSNumber *)childDirectedTreatment;

@end

@implementation CRBannerCustomEvent

#pragma mark Private methods.
- (void)loadBannerForAdUnit:(CRBannerAdUnit *)adUnit
            mediationParams:(CRGoogleMediationParameters *)params
     childDirectedTreatment:(NSNumber *)childDirectedTreatment {
  /// Set the publicher id to
  [Criteo.sharedCriteo registerCriteoPublisherId:params.publisherId withAdUnits:@[ adUnit ]];
  /// Set child directed treatment flag to Criteo SDK.
  [Criteo.sharedCriteo setChildDirectedTreatment:childDirectedTreatment];
  if (self.bannerView == nil) {
    self.bannerView = [[CRBannerView alloc] initWithAdUnit:adUnit];
  }
  [self.bannerView setDelegate:self];
  [self.bannerView loadAd];
}

#pragma mark GADMediationAdapter implementation for Banner ad.
- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
  __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
  __block GADMediationBannerLoadCompletionHandler originalCompletionHandler =
      [completionHandler copy];
  _completionHandler = ^id<GADMediationBannerAdEventDelegate>(_Nullable id<GADMediationBannerAd> ad,
                                                              NSError *_Nullable error) {
    // Only allow completion handler to be called once.
    if (atomic_flag_test_and_set(&completionHandlerCalled)) {
      return nil;
    }

    id<GADMediationBannerAdEventDelegate> delegate = nil;
    if (originalCompletionHandler) {
      // Call original handler and hold on to its return value.
      delegate = originalCompletionHandler(ad, error);
    }

    // Release reference to handler. Objects retained by the handler will also be released.
    originalCompletionHandler = nil;

    return delegate;
  };

  /// Extract ad unit id from the ad configuration.
  NSString *json = adConfiguration.credentials.settings[@"parameter"];
  NSError *jsonError;
  CRGoogleMediationParameters *params =
      [CRGoogleMediationParameters parametersFromJSONString:json error:&jsonError];
  if (jsonError) {
    _delegate = completionHandler(nil, [self noFillError:jsonError]);
    return;
  }
  /// Create an ad unit
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:params.adUnitId
                                                               size:adConfiguration.adSize.size];
  /// Load ad banner
  [self loadBannerForAdUnit:adUnit
             mediationParams:params
      childDirectedTreatment:adConfiguration.childDirectedTreatment];
}

#pragma mark GADMediationBannerAd implementation

- (nonnull UIView *)view {
  return self.bannerView;
}

#pragma mark CRBannerViewDelegate implementation

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
  _delegate = _completionHandler(self, nil);
}

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSError *bannerError = [self noFillError:error];
  _delegate = _completionHandler(nil, bannerError);
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
  [_delegate reportClick];
}

@end
