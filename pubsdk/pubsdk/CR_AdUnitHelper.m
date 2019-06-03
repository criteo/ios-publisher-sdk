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

+ (CGSize)interstitialSizeForCurrentScreenOrientation:(CGSize)screenSize {
    CGSize interstitialSize = supportedInterstitialSizes[0];
    for (int i = 0; i < ((sizeof supportedInterstitialSizes) / (sizeof supportedInterstitialSizes[0])); ++i){
        //original orientation of the device
        if (screenSize.width >= supportedInterstitialSizes[i].width){
            interstitialSize = supportedInterstitialSizes[i];
        }
    }
    return interstitialSize;
}

+ (NSArray<CRCacheAdUnit *> *) interstitialCacheAdUnitsForAdUnit:(CRInterstitialAdUnit *)adUnit
                                                      deviceInfo:(CR_DeviceInfo *)deviceInfo{
    //first get the screen size
    CGSize screenSizeCurrentOrientation = [deviceInfo screenSize];
    // supported size check happens here
    CGSize interstitialSizeCurrentOrientation = [CR_AdUnitHelper interstitialSizeForCurrentScreenOrientation:screenSizeCurrentOrientation];
    CRCacheAdUnit *cacheAdUnitCurrentOrientation = [[CRCacheAdUnit alloc] initWithAdUnitId:[adUnit adUnitId] size:interstitialSizeCurrentOrientation];

    CGSize screenSizeOtherOrientation = CGSizeMake(screenSizeCurrentOrientation.height, screenSizeCurrentOrientation.width);
    CGSize interstitialSizeOtherOrientation = [CR_AdUnitHelper interstitialSizeForCurrentScreenOrientation:screenSizeOtherOrientation];
    CRCacheAdUnit *cacheAdUnitOtherOrientation = [[CRCacheAdUnit alloc] initWithAdUnitId:[adUnit adUnitId] size:interstitialSizeOtherOrientation];
    return @[cacheAdUnitCurrentOrientation, cacheAdUnitOtherOrientation];
}

+ (NSArray<CRCacheAdUnit *> *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits
                                          deviceInfo:(CR_DeviceInfo *)deviceInfo{
    NSMutableArray<CRCacheAdUnit *> *cacheAdUnits = [NSMutableArray new];
    for(int i = 0; i < [adUnits count]; i++) {
        switch([adUnits[i] adUnitType]) {
            case CRAdUnitTypeBanner:
                [cacheAdUnits addObject:[[CRCacheAdUnit alloc] initWithAdUnitId:[adUnits[i] adUnitId]
                                                                           size:[(CRBannerAdUnit *)adUnits[i] size]]];
                break;
            case CRAdUnitTypeInterstitial:
                [cacheAdUnits addObjectsFromArray:[CR_AdUnitHelper interstitialCacheAdUnitsForAdUnit:(CRInterstitialAdUnit *)adUnits[i]
                                                                                          deviceInfo:deviceInfo]];
                break;
            default:
                CLog(@"cacheAdUnitsFromAdUnits got an unexpected AdUnitType: %d", [adUnits[i] adUnitType]);
                break;
        }
    }
    return [cacheAdUnits copy];
}

@end
