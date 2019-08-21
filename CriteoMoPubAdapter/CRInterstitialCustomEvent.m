//
//  CRInterstitialCustomEvent.m
//  CriteoMoPubAdapter
//
//  Copyright © 2019 Criteo. All rights reserved.
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
#import "CRInterstitialCustomEvent+Internal.h"
#import "CRCustomEventHelper.h"

@interface CRInterstitialCustomEvent ()
@property (nonatomic, strong) CRInterstitial *interstitial;
@end

@implementation CRInterstitialCustomEvent

- (instancetype) init {
    self = [super init];
    return self;
}

- (void) dealloc {
    self.interstitial.delegate = nil;
}

- (instancetype) initWithInterstitial:(CRInterstitial *)crInterstitial {
    if(self = [super init]) {
        self.interstitial = crInterstitial;
    }
    return self;
}

- (void) requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    if(![CRCustomEventHelper checkValidInfo:info]) {
        if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate interstitialCustomEvent:self
                              didFailToLoadAdWithError:[NSError errorWithCode:MOPUBErrorServerError
                                                         localizedDescription:@"Criteo Interstitial ad request failed due to invalid server parameters."]];
            });
        }
        return;
    }

    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:info[@"adUnitId"]];

    [[Criteo sharedCriteo] registerCriteoPublisherId:info[@"cpId"] withAdUnits:@[interstitialAdUnit]];
    if(!self.interstitial) {
        self.interstitial = [[CRInterstitial alloc] initWithAdUnit:interstitialAdUnit];
    }
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (void) showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [self.interstitial presentFromRootViewController:rootViewController];
}

# pragma mark - MoPub required delegate methods
// These callbacks are called on the main thread from the Criteo SDK
- (void) interstitialDidReceiveAd:(CRInterstitial *)interstitial {
    // Signals that Criteo is willing to display an ad
    // Intentionally left blank
}

- (void) interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
        NSString *failure = [NSString stringWithFormat:@"Criteo Interstitial failed to load with error : %@"
                             , error.localizedDescription];
        NSError *finalError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:failure];
        [self.delegate interstitialCustomEvent:self
                      didFailToLoadAdWithError:finalError];
    }
}

- (void) interstitialWillAppear:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventWillAppear:)]) {
        [self.delegate interstitialCustomEventWillAppear:self];
    }
}

- (void) interstitialDidAppear:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventDidAppear:)]) {
        [self.delegate interstitialCustomEventDidAppear:self];
    }
}

- (void) interstitialWillDisappear:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventWillDisappear:)]) {
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
}

- (void) interstitialDidDisappear:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:(@selector(interstitialCustomEventDidDisappear:))]) {
        [self.delegate interstitialCustomEventDidDisappear:self];
    }
}

- (void) interstitialIsReadyToPresent:(CRInterstitial *)interstitial {
    if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:interstitial];
    }
}

- (void) interstitial:(CRInterstitial *)interstitial didFailToReceiveAdContentWithError:(NSError *)error {
    // Signals that there was an error when Criteo was attempting to fetch the ad content
    if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
        NSString *failure = [NSString stringWithFormat:@"Criteo Interstitial failed to load ad content with error : %@"
                             , error.localizedDescription];
        NSError *finalError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:failure];
        [self.delegate interstitialCustomEvent:self
                      didFailToLoadAdWithError:finalError];
    }
}

# pragma mark - MoPub delegate to track clicks
- (void) interstitialWillLeaveApplication:(CRInterstitial *)interstitial {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEventWillLeaveApplication:)]) {
        [self.delegate interstitialCustomEventWillLeaveApplication:self];
    }
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventDidReceiveTapEvent:)]) {
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    }
}

@end
