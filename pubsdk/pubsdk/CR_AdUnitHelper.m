//
//  CR_AdUnitHelper.m
//  pubsdk
//
//  Created by Sneha Pathrose on 6/3/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_AdUnitHelper.h"
#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"
#import "Logging.h"

@implementation CR_AdUnitHelper
//needs to be sorted from smallest to largest in width
static const CGSize supportedInterstitialSizes[] = {
    { .width = 320.0, .height = 480.0 },
    { .width = 360.0, .height = 640.0 },
    { .width = 480.0, .height = 320.0 },
    { .width = 640.0, .height = 360.0 }
};

+ (CGSize)closestSupportedInterstitialSize:(CGSize)screenSize {
    CGSize interstitialSize = supportedInterstitialSizes[0];
    for (int i = 0; i < ((sizeof supportedInterstitialSizes) / (sizeof supportedInterstitialSizes[0])); ++i){
        //original orientation of the device
        if (screenSize.width >= supportedInterstitialSizes[i].width){
            interstitialSize = supportedInterstitialSizes[i];
        }
    }
    return interstitialSize;
}

// return an array as interstitial will return two cache adUnits for both orientations
+ (NSArray<CR_CacheAdUnit *> *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits
                                           deviceInfo:(CR_DeviceInfo *)deviceInfo{
    NSMutableArray<CR_CacheAdUnit *> *cacheAdUnits = [NSMutableArray new];
    for(int i = 0; i < [adUnits count]; i++) {
        switch([adUnits[i] adUnitType]) {
            case CRAdUnitTypeBanner:
                [cacheAdUnits addObject:[[CR_CacheAdUnit alloc] initWithAdUnitId:adUnits[i].adUnitId
                                                                            size:[(CRBannerAdUnit *)adUnits[i] size]]];
                break;
            case CRAdUnitTypeInterstitial:
            {
                CGSize currentOrientationSize = [deviceInfo screenSize];
                [cacheAdUnits addObject:[CR_AdUnitHelper interstitialCacheAdUnitForAdUnitId:[adUnits[i] adUnitId]
                                                                                 screenSize:currentOrientationSize]];
                break;
            }
            default:
                CLog(@"cacheAdUnitsFromAdUnits got an unexpected AdUnitType: %d", [adUnits[i] adUnitType]);
                break;
        }
    }
    return [cacheAdUnits copy];
}

+ (CR_CacheAdUnit *)cacheAdUnitForAdUnit:(CRAdUnit *)adUnit
                              deviceInfo:(CR_DeviceInfo *)deviceInfo {
    switch([adUnit adUnitType]) {
        case CRAdUnitTypeBanner:
            return [[CR_CacheAdUnit alloc] initWithAdUnitId:[adUnit adUnitId]
                                                       size:[(CRBannerAdUnit *)adUnit size]];
            break;
        case CRAdUnitTypeInterstitial:
            return [CR_AdUnitHelper interstitialCacheAdUnitForAdUnitId:[adUnit adUnitId]
                                                            screenSize:[deviceInfo screenSize]];
            break;
        default:
            CLog(@"cacheAdUnitsFromAdUnits got an unexpected AdUnitType: %d", [adUnit adUnitType]);
            break;
    }
}
// used by loadAd
+ (CR_CacheAdUnit *)interstitialCacheAdUnitForAdUnitId:(NSString *)adUnitId
                                            screenSize:(CGSize)size{
    CGSize adSize = [CR_AdUnitHelper closestSupportedInterstitialSize:size];
    return [[CR_CacheAdUnit alloc] initWithAdUnitId:adUnitId size:adSize];
}

@end
