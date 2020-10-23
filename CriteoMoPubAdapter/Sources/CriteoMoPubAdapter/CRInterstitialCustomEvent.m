//
//  CRInterstitialCustomEvent.m
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

#import <Foundation/Foundation.h>
#import "CRInterstitialCustomEvent.h"
#import "CRCustomEventHelper.h"
#import "NSString+MPConsentStatus.h"

@interface CRInterstitialCustomEvent ()

@property(nonatomic, strong) CRInterstitial *interstitial;

@end

@implementation CRInterstitialCustomEvent

@synthesize delegate;
@synthesize localExtras;

- (instancetype)init {
  self = [super init];
  return self;
}

- (void)dealloc {
  self.interstitial.delegate = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
  if (![CRCustomEventHelper checkValidInfo:info]) {
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapter:
                                               didFailToLoadAdWithError:)]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate
                 fullscreenAdAdapter:self
            didFailToLoadAdWithError:
                [NSError errorWithCode:MOPUBErrorServerError
                    localizedDescription:
                        @"Criteo Interstitial ad request failed due to invalid server parameters."]];
      });
    }
    return;
  }

  [Criteo.sharedCriteo
      setMopubConsent:[NSString stringFromConsentStatus:MoPub.sharedInstance.currentConsentStatus]];
  CRInterstitialAdUnit *interstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:info[@"adUnitId"]];

  [[Criteo sharedCriteo] registerCriteoPublisherId:info[@"cpId"]
                                       withAdUnits:@[ interstitialAdUnit ]];
  if (!self.interstitial) {
    self.interstitial = [[CRInterstitial alloc] initWithAdUnit:interstitialAdUnit];
  }
  self.interstitial.delegate = self;
  [self.interstitial loadAd];
}

#pragma mark - MoPub required overrides

- (BOOL)enableAutomaticImpressionAndClickTracking {
  return YES;
}

- (BOOL)isRewardExpected {
  return NO;
}

- (void)setHasAdAvailable:(BOOL)hasAdAvailable {
}

- (BOOL)hasAdAvailable {
  return self.interstitial.isAdLoaded;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
  [self.interstitial presentFromRootViewController:viewController];
}

#pragma mark - MoPub required delegate methods

// These callbacks are called on the main thread from the Criteo SDK
- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial {
  if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterDidLoadAd:)]) {
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
  }
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapter:didFailToLoadAdWithError:)]) {
    NSString *failure =
        [NSString stringWithFormat:@"Criteo Interstitial failed to load with error : %@",
                                   error.localizedDescription];
    NSError *finalError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
                            localizedDescription:failure];
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:finalError];
  }
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial {
  if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdWillAppear:)]) {
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
  }
}

- (void)interstitialDidAppear:(CRInterstitial *)interstitial {
  if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidAppear:)]) {
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
  }
}

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial {
  if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdWillDisappear:)]) {
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
  }
}

- (void)interstitialDidDisappear:(CRInterstitial *)interstitial {
  if ([self.delegate respondsToSelector:(@selector(fullscreenAdAdapterAdDidDisappear:))]) {
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
  }
}

#pragma mark - MoPub delegate to track clicks

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial {
  if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterWillLeaveApplication:)]) {
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
  }
  if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterDidReceiveTap:)]) {
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
  }
}

@end
