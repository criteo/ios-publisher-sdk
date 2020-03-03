//
//  CR_CacheManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CR_CacheManager.h"
#import "Logging.h"
#import "CR_DeviceInfo.h"

@implementation CR_CacheManager

- (instancetype) init {
    if(self = [super init]) {
        _bidCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) initSlots: (NSArray *) slots {
    for(CR_CacheAdUnit *slot in slots) {
        _bidCache[slot] = [CR_CdbBid emptyBid];
    }
}

- (CRAdUnitType)adUnitTypeFromBid:(CR_CdbBid *)bid {
    if(bid.nativeAssets) {
        return CRAdUnitTypeNative;
    }
    if([CR_DeviceInfo validScreenSize:CGSizeMake(bid.width.floatValue, bid.height.floatValue)]) {
        return CRAdUnitTypeInterstitial;
    }
    return CRAdUnitTypeBanner;
}

- (CR_CacheAdUnit *) setBid: (CR_CdbBid *) bid {
    if (!bid) { return nil; }
    if (!bid.isValid) {
        CLog(@"Cache update failed because bid is not valid. bid:  %@", bid);
        return nil;
    }
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:bid.placementId
                                                                 size:CGSizeMake(bid.width.floatValue, bid.height.floatValue)
                                                           adUnitType:[self adUnitTypeFromBid:bid]];
    if (!adUnit.isValid) {
        CLog(@"Cache update failed because adUnit was not valid. bid:  %@", bid);
        return nil;
    }
    @synchronized (_bidCache) {
        CLogInfo(@"[INFO][CACH] setBid: %@", adUnit);
        _bidCache[adUnit] = bid;
    }
    return adUnit;
}

- (CR_CdbBid *) getBidForAdUnit: (CR_CacheAdUnit *) adUnit {
    CR_CdbBid *bid = _bidCache[adUnit];
    CLogInfo(@"[INFO][CACH] getBidForAdUnit: %@, isNil: %d", adUnit, bid == nil);
    return bid;
}

- (void) removeBidForAdUnit: (CR_CacheAdUnit *) adUnit {
    CLogInfo(@"[INFO][CACH] removeBidForAdUnit: %@", adUnit);
    _bidCache[adUnit] = nil;
}

@end
