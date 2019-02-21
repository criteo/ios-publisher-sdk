//
//  CacheManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CacheManager.h"
#import "Logging.h"

@implementation CacheManager

- (instancetype) init {
    if(self = [super init]) {
        _bidCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) initSlots: (NSArray *) slots {
    for(CRAdUnit *slot in slots) {
        _bidCache[slot] = [CdbBid emptyBid];
    }
}

- (void) setBid: (CdbBid *) bid
      forAdUnit: (CRAdUnit *) adUnit {
    @synchronized (_bidCache) {
        if(adUnit) {
            _bidCache[adUnit] = bid;
        } else {
            CLog(@"Cache update failed because adUnit was nil. bid:  %@", bid);
        }
    }
}

- (CdbBid *) getBid: (CRAdUnit *) slotId {
    CdbBid *bid = [_bidCache objectForKey:slotId];
    if(bid) {
        _bidCache[slotId] = [CdbBid emptyBid];
        // check ttl hasn't elapsed
        if (bid.isExpired) {
            return [CdbBid emptyBid];
        }
    }
    return bid;
}

@end
