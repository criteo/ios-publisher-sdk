//
//  CR_AdUnitHelper.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_AdUnitHelper.h"
#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"
#import "CR_DeviceInfo.h"
#import "Logging.h"

@implementation CR_AdUnitHelper

static const CGSize nativeSize = {2.0, 2.0};

// return an array of cacheAdUnits
+ (CR_CacheAdUnitArray *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  NSMutableArray<CR_CacheAdUnit *> *cacheAdUnits = [NSMutableArray new];
  for (int i = 0; i < [adUnits count]; i++) {
    [cacheAdUnits addObject:[CR_AdUnitHelper cacheAdUnitForAdUnit:adUnits[i]]];
  }
  return [cacheAdUnits copy];
}

+ (CR_CacheAdUnit *)cacheAdUnitForAdUnit:(CRAdUnit *)adUnit {
  switch ([adUnit adUnitType]) {
    case CRAdUnitTypeBanner:
      return [[CR_CacheAdUnit alloc] initWithAdUnitId:[adUnit adUnitId]
                                                 size:[(CRBannerAdUnit *)adUnit size]
                                           adUnitType:CRAdUnitTypeBanner];
    case CRAdUnitTypeInterstitial:
      return [CR_CacheAdUnit cacheAdUnitForInterstialWithAdUnitId:adUnit.adUnitId
                                                             size:[CR_DeviceInfo getScreenSize]];
    case CRAdUnitTypeNative:
      return [[CR_CacheAdUnit alloc] initWithAdUnitId:adUnit.adUnitId
                                                 size:nativeSize
                                           adUnitType:CRAdUnitTypeNative];
    default:
      CLog(@"cacheAdUnitsFromAdUnits got an unexpected AdUnitType: %d", [adUnit adUnitType]);
      return nil;
  }
}

@end
