//
//  CRCustomEvent.m
//  CriteoAdViewer
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

#import "CRCustomEvent.h"
#import "Criteo+Internal.h"
#include <stdatomic.h>
#import "CRGoogleMediationParameters.h"

@interface CRCustomEvent () <GADMediationBannerAd, CRBannerViewDelegate> {
    //  The banner ad.
    CRBannerView *_bannerAd;
    //  The completion handler to call when the ad loading succeeds or fails.
    GADMediationBannerLoadCompletionHandler _bannerLoadCompletionHandler;
    // The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
    id<GADMediationBannerAdEventDelegate> _bannerAdEventDelegate;
}
@end

@implementation CRCustomEvent
+ (GADVersionNumber)adSDKVersion {
    NSArray *versionComponents = [CRITEO_PUBLISHER_SDK_VERSION componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count >= 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

+ (GADVersionNumber)adapterVersion {
    return [CRCustomEvent adSDKVersion];
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return Nil;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    // This is where you you will initialize the SDK that this custom event is built for.
    // Upon finishing the SDK initialization, call the completion handler with success.
    completionHandler(nil);
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationBannerLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    _bannerLoadCompletionHandler = ^id<GADMediationBannerAdEventDelegate>(
        _Nullable id<GADMediationBannerAd> ad, NSError *_Nullable error) {
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
    CRGoogleMediationParameters *params = [CRGoogleMediationParameters parametersFromJSONString:adConfiguration.credentials.settings[@"parameter"] error:nil];
    NSString *adUnitId = params.adUnitId;
    /// Create an ad unit
    CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId
                                                                    size:adConfiguration.adSize.size];
    /// Set the publicher id to 
    NSString *publisherId = params.publisherId;
    [Criteo.sharedCriteo registerCriteoPublisherId:publisherId withAdUnits:@[ adUnit ]];
    /// Set child directed treatment flag to Criteo SDK.
    [Criteo.sharedCriteo setChildDirectedTreatment:adConfiguration.childDirectedTreatment];
    _bannerAd = [[CRBannerView alloc] initWithAdUnit:adUnit];
    _bannerAd.delegate = self;
    [_bannerAd loadAd];
}

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler {
    //  sampleInterstitial = [[SampleCustomEventInterstitial alloc] init];
    //  [sampleInterstitial loadInterstitialForAdConfiguration:adConfiguration
    //                                       completionHandler:completionHandler];
}

#pragma mark GADMediationBannerAd implementation

- (nonnull UIView *)view {
    return _bannerAd;
}

#pragma mark CRBannerViewDelegate implementation

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
    _bannerAdEventDelegate = _bannerLoadCompletionHandler(self, nil);
}

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSError *bannerError = [NSError errorWithDomain:GADErrorDomain
                                           code:GADErrorNoFill
                                       userInfo:[NSDictionary dictionaryWithObject:error.description
                                                                            forKey:NSLocalizedDescriptionKey]];
    _bannerAdEventDelegate = _bannerLoadCompletionHandler(nil, bannerError);
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
    [_bannerAdEventDelegate reportClick];
}

@end
