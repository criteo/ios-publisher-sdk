//
//  CR_HttpContent+AdUnit.m
//  CriteoPublisherSdkTests
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

#import "CR_HttpContent+AdUnit.h"
#import "CR_ApiQueryKeys.h"

@implementation CR_HttpContent (AdUnit)

- (BOOL)isHTTPRequestForCacheAdUnits:(CR_CacheAdUnitArray *)cacheAdUnits {
  for (CR_CacheAdUnit *adUnit in cacheAdUnits) {
    if (![self isHTTPRequestForCacheAdUnit:adUnit]) {
      return NO;
    }
  }
  return YES;
}

- (BOOL)isHTTPRequestForCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit {
  for (NSDictionary *slot in self.requestBody[CR_ApiQueryKeys.bidSlots]) {
    NSString *placementId = slot[CR_ApiQueryKeys.bidSlotsPlacementId];
    NSString *sizes = slot[CR_ApiQueryKeys.bidSlotsSizes][0];
    NSNumber *isNative = [slot objectForKey:CR_ApiQueryKeys.bidSlotsIsNative];
    NSNumber *isInterstitial = [slot objectForKey:CR_ApiQueryKeys.bidSlotsIsInterstitial];
    NSNumber *isRewarded = [slot objectForKey:CR_ApiQueryKeys.bidSlotsIsRewarded];
    const BOOL isExpectedAdUnitId = [cacheAdUnit.adUnitId isEqualToString:placementId];
    const BOOL isExpectedSize = [[cacheAdUnit cdbSize] isEqualToString:sizes];
    const BOOL hasNativeWellSet = (cacheAdUnit.adUnitType != CRAdUnitTypeNative) || isNative;
    const BOOL hasInterstitialWellSet =
        (cacheAdUnit.adUnitType != CRAdUnitTypeInterstitial) || isInterstitial;
    const BOOL hasRewardedWellSet = (cacheAdUnit.adUnitType != CRAdUnitTypeRewarded) || isRewarded;
    if (isExpectedAdUnitId && isExpectedSize && hasNativeWellSet && hasInterstitialWellSet &&
        hasRewardedWellSet) {
      return YES;
    }
  }
  return NO;
}

@end
