//
//  CRNativeCustomEvent.m
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

#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

#if __has_include("MoPub.h")
#import "MPNativeAdError.h"
#import "NSString+MPConsentStatus.h"
#endif

#import "CRCustomEventHelper.h"
#import "CRNativeCustomEvent.h"
#import "CRNativeAdDelegateHandler.h"

@interface CRNativeCustomEvent ()

@property(strong, nonatomic, readonly) Criteo *criteo;
@property(strong, nonatomic, readonly) MoPub *mopub;

@property(strong, nonatomic) CRNativeLoader *loader;
@property(strong, nonatomic) CRNativeAdDelegateHandler *delegateHandler;

@end

@implementation CRNativeCustomEvent

- (instancetype)init {
  self = [super init];
  if (self) {
    _criteo = [Criteo sharedCriteo];
    _mopub = [MoPub sharedInstance];
    _delegateHandler = [[CRNativeAdDelegateHandler alloc] initWithCustomEvent:self];
  }
  return self;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
  if (![CRCustomEventHelper checkValidInfo:info]) {
    if ([self.delegate respondsToSelector:@selector(nativeCustomEvent:didFailToLoadAdWithError:)]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate nativeCustomEvent:self
                didFailToLoadAdWithError:
                    MPNativeAdNSErrorForInvalidAdServerResponse(
                        @"Criteo Native ad request failed due to invalid server parameters.")];
      });
    }
    return;
  }

  [self updateMopubConsent];

  [self loadAdwithEventInfo:info];
}

#pragma mark - Private

- (CRNativeAdUnit *)adUnitWithEventInfo:(NSDictionary *)info {
  NSString *adUnitId = info[kCRCustomEventHelperAdUnitId];
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:adUnitId];
  return adUnit;
}

- (void)loadAdwithEventInfo:(NSDictionary *)info {
  CRNativeAdUnit *adUnit = [self adUnitWithEventInfo:info];
  NSString *publisherId = info[kCRCustomEventHelperCpId];
  [self.criteo registerCriteoPublisherId:publisherId withAdUnits:@[ adUnit ]];

  self.loader = [[CRNativeLoader alloc] initWithAdUnit:adUnit];
  self.loader.delegate = self.delegateHandler;
  [self.loader loadAd];
}

- (void)updateMopubConsent {
  NSString *consentStatusStr = [NSString stringFromConsentStatus:self.mopub.currentConsentStatus];
  [self.criteo setMopubConsent:consentStatusStr];
}

@end
