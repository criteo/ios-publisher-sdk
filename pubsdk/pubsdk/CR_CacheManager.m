//
//  CR_CacheManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CR_CacheManager.h"
#import "Logging.h"

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

- (void) setBid: (CR_CdbBid *) bid {
    if (!bid) { return; }
    BOOL isNative = bid.nativeAssets ? YES : NO;
    if (!bid.isValid) {
        CLog(@"Cache update failed because bid is not valid. bid:  %@", bid);
        return;
    }
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:bid.placementId
                                                                 size:CGSizeMake(bid.width.floatValue, bid.height.floatValue)
                                                             isNative:isNative];
    if (!adUnit.isValid) {
        CLog(@"Cache update failed because adUnit was not valid. bid:  %@", bid);
        return;
    }
    @synchronized (_bidCache) {
        _bidCache[adUnit] = bid;
    }
}

- (CR_CdbBid *) getBidForAdUnit: (CR_CacheAdUnit *) adUnit {
    CR_CdbBid *bid = [_bidCache objectForKey:adUnit];
    return bid;
}

- (void) removeBidForAdUnit: (CR_CacheAdUnit *) adUnit {
    _bidCache[adUnit] = nil;
}

@end
