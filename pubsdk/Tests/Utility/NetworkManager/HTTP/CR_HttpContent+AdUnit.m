//
//  CR_HttpContent+AdUnit.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
        const BOOL isExpectedAdUnitId = [cacheAdUnit.adUnitId isEqualToString:placementId];
        const BOOL isExpectedSize = [[cacheAdUnit cdbSize] isEqualToString:sizes];
        const BOOL hasNativeWellSet = (cacheAdUnit.adUnitType != CRAdUnitTypeNative) || isNative;
        const BOOL hasInterstitialWellSet = (cacheAdUnit.adUnitType != CRAdUnitTypeInterstitial) || isInterstitial;
        if (isExpectedAdUnitId && isExpectedSize && hasNativeWellSet && hasInterstitialWellSet) {
            return YES;
        }
    }
    return NO;
}

@end
