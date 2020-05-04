//
//  CR_AdUnitHelper.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_CacheAdUnit.h"
#import "CRInterstitialAdUnit.h"
#import "CR_DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_AdUnitHelper : NSObject

+ (CR_CacheAdUnitArray *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits;

+ (CR_CacheAdUnit *)cacheAdUnitForAdUnit:(CRAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END
