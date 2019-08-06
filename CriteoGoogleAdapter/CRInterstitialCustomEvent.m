//
//  CRInterstitialCustomEvent.m
//  CriteoGoogleAdapter
//
// Copyright © 2019 Criteo. All rights reserved.
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

#import "CRInterstitialCustomEvent.h"
#import "CRGoogleMediationParameters.h"

@interface CRInterstitialCustomEvent ()
@property (nonatomic, strong)CRInterstitial *interstitial;
@end

@implementation CRInterstitialCustomEvent

- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];
}

- (void)requestInterstitialAdWithParameter:(nullable NSString *)serverParameter
                                     label:(nullable NSString *)serverLabel
                                   request:(nonnull GADCustomEventRequest *)request {
    NSError *jsonError = nil;
    CRGoogleMediationParameters *parameters = [CRGoogleMediationParameters parametersFromJSONString:serverParameter
                                                                                              error:&jsonError];
    if(jsonError) {
        [self dispatchCustomEventDidFailAdWithError:jsonError];
        return;
    }
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:parameters.adUnitId];
    Criteo *criteo = [Criteo sharedCriteo];
    [criteo registerCriteoPublisherId:parameters.publisherId withAdUnits:@[interstitialAdUnit]];
    self.interstitial = [[CRInterstitial alloc] initWithAdUnit:interstitialAdUnit];
    [self.interstitial loadAd];
}

- (void)dispatchCustomEventDidFailAdWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
        [self.delegate customEventInterstitial:self didFailAd:error];
    }
}

@end
