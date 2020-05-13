//
//  CR_AdUnitHelper.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_CacheAdUnit.h"
#import "CRInterstitialAdUnit.h"
#import "CR_DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * TODO: Remove this class by switching to a Class Cluster
 * https://developer.apple.com/library/archive/documentation/General/Conceptual/CocoaEncyclopedia/ClassClusters/ClassClusters.html
 */
@interface CR_AdUnitHelper : NSObject

+ (CR_CacheAdUnitArray *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits;

+ (CR_CacheAdUnit *)cacheAdUnitForAdUnit:(CRAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END
