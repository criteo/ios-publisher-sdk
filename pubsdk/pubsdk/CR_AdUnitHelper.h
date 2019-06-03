//
//  CR_AdUnitHelper.h
//  pubsdk
//
//  Created by Sneha Pathrose on 6/3/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRCacheAdUnit.h"
#import "CRInterstitialAdUnit.h"
#import "CR_DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_AdUnitHelper : NSObject

+ (NSArray<CRCacheAdUnit *> *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits
                                          deviceInfo:(CR_DeviceInfo *)deviceInfo;

+ (CRCacheAdUnit *)cacheAdUnitForAdUnit:(CRAdUnit *)adUnit
                             deviceInfo:(CR_DeviceInfo *)deviceInfo;

+ (CRCacheAdUnit *)interstitialCacheAdUnitForAdUnitId:(NSString *)adUnitId
                                           screenSize:(CGSize)size;
// helper methods
+ (CGSize)closestSupportedInterstitialSize:(CGSize)screenSize;

@end

NS_ASSUME_NONNULL_END
