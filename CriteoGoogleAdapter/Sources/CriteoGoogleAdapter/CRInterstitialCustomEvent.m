//
//  CRInterstitialCustomEvent.m
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

#import "CRInterstitialCustomEvent.h"
#import "CRGoogleMediationParameters.h"
#include <stdatomic.h>
@import GoogleMobileAds;

@interface CRInterstitialCustomEvent () <CRInterstitialDelegate, GADMediationInterstitialAd> {
  /// The completion handler to call when the ad loading succeeds or fails.
  GADMediationInterstitialLoadCompletionHandler _completionHandler;
  /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
  id<GADMediationInterstitialAdEventDelegate> _delegate;
}

@property(nonatomic, strong) CRInterstitial *interstitial;

- (void)loadInterstitialForAdUnit:(CRInterstitialAdUnit *)adUnit
                  adConfiguration:(CRGoogleMediationParameters *)params
           childDirectedTreatment:(NSNumber *)childDirectedTreatment;
@end

@implementation CRInterstitialCustomEvent

#pragma mark Private methods.
- (void)loadInterstitialForAdUnit:(CRInterstitialAdUnit *)adUnit
                  adConfiguration:(CRGoogleMediationParameters *)params
           childDirectedTreatment:(NSNumber *)childDirectedTreatment {
  [Criteo.sharedCriteo registerCriteoPublisherId:params.publisherId
                                     withStoreId:params.storeId
                                     withAdUnits:@[ adUnit ]];
  /// Set child directed treatment flag to Criteo SDK.
  [Criteo.sharedCriteo setChildDirectedTreatment:childDirectedTreatment];
  if (!self.interstitial) {
    self.interstitial = [[CRInterstitial alloc] initWithAdUnit:adUnit];
  }
  [self.interstitial setDelegate:self];
  [self.interstitial loadAd];
}

#pragma mark GADMediationAdapter implementation for Interstitial ad.
- (void)loadInterstitialForAdConfiguration:
            (GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
                             (GADMediationInterstitialLoadCompletionHandler)completionHandler {
  __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
  __block GADMediationInterstitialLoadCompletionHandler originalCompletionHandler =
      [completionHandler copy];

  _completionHandler = ^id<GADMediationInterstitialAdEventDelegate>(
      _Nullable id<GADMediationInterstitialAd> ad, NSError *_Nullable error) {
    // Only allow completion handler to be called once.
    if (atomic_flag_test_and_set(&completionHandlerCalled)) {
      return nil;
    }

    id<GADMediationInterstitialAdEventDelegate> delegate = nil;
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
  /// Create the ad unit
  CRInterstitialAdUnit *adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:params.adUnitId];
  NSNumber *childDirectedTreatment =
      GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment;
  /// Load Interstitial ad.
  [self loadInterstitialForAdUnit:adUnit
                  adConfiguration:params
           childDirectedTreatment:childDirectedTreatment];
}

#pragma mark GADMediationInterstitialAd implementation
- (void)presentFromViewController:(nonnull UIViewController *)viewController {
  if ([self.interstitial isAdLoaded]) {
    [self.interstitial presentFromRootViewController:viewController];
  } else {
    NSDictionary *userInfo = [[NSDictionary alloc] init];
    [userInfo setValue:@"The interstitial ad failed to present because the ad was not loaded."
                forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:GADErrorDomain
                                         code:GADErrorInvalidArgument
                                     userInfo:userInfo];
    _delegate = _completionHandler(nil, error);
  }
}

#pragma mark CRInterstitialDelegate implementation
// These callbacks are called on the main thread from the Criteo SDK
- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial {
  _delegate = _completionHandler(self, nil);
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
  NSError *interstitialError = [self noFillError:error];
  _delegate = _completionHandler(nil, interstitialError);
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial {
  [_delegate willPresentFullScreenView];
  [_delegate reportImpression];
}

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial {
  [_delegate willDismissFullScreenView];
}

- (void)interstitialDidDisappear:(CRInterstitial *)interstitial {
  [_delegate didDismissFullScreenView];
}

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial {
  [_delegate reportClick];
}

@end
