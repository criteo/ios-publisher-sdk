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
@property (nonatomic, strong)CRInterstitialAdUnit *interstitialAdUnit;
@end

@implementation CRInterstitialCustomEvent

- (instancetype)initWithInterstitial:(CRInterstitial *)interstitial adUnit:(CRInterstitialAdUnit *)adUnit {
    if(self = [super init]) {
        _interstitial = interstitial;
        _interstitialAdUnit = adUnit;
    }
    return self;
}

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
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
                [self.delegate customEventInterstitial:self didFailAd:jsonError];
            }
        });
        return;
    }
    if(!_interstitialAdUnit) {
        self.interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:parameters.adUnitId];
    }
    [Criteo.sharedCriteo registerCriteoPublisherId:parameters.publisherId
                                       withAdUnits:@[self.interstitialAdUnit]];
    if(!_interstitial) {
        self.interstitial = [[CRInterstitial alloc] initWithAdUnit:self.interstitialAdUnit];
    }
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

#pragma mark CRInterstitialDelegate Implementation

- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(customEventInterstitialDidReceiveAd:)]) {
        [self.delegate customEventInterstitialDidReceiveAd:self];
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else if([self.delegate respondsToSelector:@selector(customEventInterstitial:didReceiveAd:)]) {
        [self.delegate customEventInterstitial:self didReceiveAd:interstitial];
    }
    #pragma clang diagnostic pop
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
        [self.delegate customEventInterstitial:self didFailAd:[NSError errorWithDomain:kGADErrorDomain
                                                                                  code:kGADErrorNoFill
                                                                              userInfo:[NSDictionary dictionaryWithObject:error.description forKey:NSLocalizedDescriptionKey]]];
    }
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(customEventInterstitialWillPresent:)]) {
        [self.delegate customEventInterstitialWillPresent:self];
    }
}

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(customEventInterstitialWillDismiss:)]) {
        [self.delegate customEventInterstitialWillDismiss:self];
    }
}

- (void)interstitialDidDisappear:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(customEventInterstitialDidDismiss:)]) {
        [self.delegate customEventInterstitialDidDismiss:self];
    }
}

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(customEventInterstitialWasClicked:)]) {
        [self.delegate customEventInterstitialWasClicked:self];
    }
    if([self.delegate respondsToSelector:@selector(customEventInterstitialWillLeaveApplication:)]) {
        [self.delegate customEventInterstitialWillLeaveApplication:self];
    }
}

@end
