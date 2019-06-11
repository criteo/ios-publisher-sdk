//
//  CR_AdUnitHelper.h
//  pubsdk
//
//  Created by Sneha Pathrose on 6/3/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_CacheAdUnit.h"
#import "CRInterstitialAdUnit.h"
#import "CR_DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_AdUnitHelper : NSObject

+ (NSArray<CR_CacheAdUnit *> *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits
                                          deviceInfo:(CR_DeviceInfo *)deviceInfo;

+ (CR_CacheAdUnit *)cacheAdUnitForAdUnit:(CRAdUnit *)adUnit
                             deviceInfo:(CR_DeviceInfo *)deviceInfo;

+ (CR_CacheAdUnit *)interstitialCacheAdUnitForAdUnitId:(NSString *)adUnitId
                                           screenSize:(CGSize)size;
// helper methods
+ (CGSize)closestSupportedInterstitialSize:(CGSize)screenSize;

@end

NS_ASSUME_NONNULL_END
