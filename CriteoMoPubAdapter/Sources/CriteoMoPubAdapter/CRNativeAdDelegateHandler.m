//
//  CRNativeAdDelegateHandler.m
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

#import "CRNativeAdDelegateHandler.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>
#import "CRNativeAdAdapter.h"
#import "CRNativeCustomEvent.h"

@interface CRNativeAdDelegateHandler ()

@property(nonatomic, strong) CRNativeCustomEvent *customEvent;
@property(nonatomic, strong) CRNativeAdAdapter<MPNativeAdAdapter> *adapter;

@end

@implementation CRNativeAdDelegateHandler

- (instancetype)initWithCustomEvent:(CRNativeCustomEvent *)customEvent {
  self = [super init];
  if (self) {
    _customEvent = customEvent;
  }
  return self;
}

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
  self.adapter = [[CRNativeAdAdapter alloc] initWithNativeAd:ad];
  MPNativeAd *nativeAd = [[MPNativeAd alloc] initWithAdAdapter:self.adapter];
  [self.customEvent.delegate nativeCustomEvent:self.customEvent didLoadAd:nativeAd];
}

- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error {
  NSString *errorDescription =
      [NSString stringWithFormat:@"Criteo Native Ad failed to load with error: %@",
                                 error.localizedDescription];
  NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
                          localizedDescription:errorDescription];
  [self.customEvent.delegate nativeCustomEvent:self.customEvent
                      didFailToLoadAdWithError:mopubError];
}

- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader {
  [self.adapter nativeAdWillLogImpression];
}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader {
  [self.adapter nativeAdDidClick];
}

- (void)nativeLoaderWillLeaveApplicationForNativeAd:(CRNativeLoader *)loader {
  [self.adapter nativeAdWillLeaveApplication];
}

@end
