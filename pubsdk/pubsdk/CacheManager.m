//
//  CacheManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "CacheManager.h"

@implementation CacheManager

- (instancetype) init {
    if(self = [super init]) {
        _bidCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) initSlots: (NSArray *) slots {
    for(NSString *slot in slots) {
        // ideally store the pointer to the private static empty object exposed by CdbBid class
        // instead of allocating a new empty object
        [_bidCache setObject:[CdbBid emptyBid] forKey:slot];
    }
}

- (void) setBid: (CdbBid *) bid
      forAdUnit: (AdUnit *) adUnit {
    @synchronized (_bidCache) {
        if(adUnit) {
            [_bidCache setObject:bid forKey:adUnit];
        } else {
            NSLog(@"Cache update failed because adUnit was nil. bid:  %@", bid);
        }
    }
}

- (CdbBid *) getBid: (AdUnit *) slotId {
    CdbBid *bid = [_bidCache objectForKey:slotId];
    if(bid) {
        // Don't know if setting it to empty directly will leak
        // so taking the safe route of remove first and then set to empty
        [_bidCache removeObjectForKey:slotId];
        [_bidCache setObject:[CdbBid emptyBid] forKey:slotId];
    }
    return bid;
}

@end
