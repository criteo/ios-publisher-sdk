//
//  BidManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "BidManager.h"

@implementation BidManager

- (instancetype) init {
    if(self = [super init]) {
        _cacheManager = [[CacheManager alloc] init];
        _apiHandler = [[ApiHandler alloc] init];
        _gdpr = [[GdprUserConsent alloc] init];
    }
    return self;
}

- (void) setSlots: (NSArray<AdUnit*> *) slots {
    [_cacheManager initSlots:slots];
    // TODO: should we prefetch here as well?
}

- (NSDictionary *) getBids: (NSArray<AdUnit*> *) slots {
    NSMutableDictionary *bids = [[NSMutableDictionary alloc] init];
    for(AdUnit *slot in slots) {
        CdbBid *bid = [self getBid:slot];
        [bids setObject:bid forKey:slot];
    }
    return bids;
}

- (CdbBid *) getBid:(AdUnit *) slot {
    CdbBid *bid = [_cacheManager getBid:slot];
    if(bid) {
        // Whether a valid bid was returned or not
        // fire call to prefetch here
        [self prefetchBid:slot];
    }
    // if the cache returns nil it means the key wasn't in the cache
    // return an empty bid
    else {
        // TODO: ideally store the pointer to the private static empty object exposed by CdbBid class
        // instead of allocating a new empty object
        bid = [CdbBid emptyBid];
    }
    return bid;
}

// TODO: Figure out a way to test this
- (void) prefetchBid:(AdUnit *) slotId {
    // move the async to the api handler
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.apiHandler callCdb:slotId gdprConsent:[self gdpr] ahCdbResponseHandler:^(NSArray *cdbBids) {
            for(CdbBid *bid in cdbBids) {
                [self.cacheManager setBid:bid forAdUnit:slotId];
            }
        }];
    });
}

- (void) setNetworkId:(NSNumber *)networkId {
    _networkId = networkId;
}

- (NSNumber *) getNetworkId {
    return _networkId;
}

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(AdUnit *) adUnit {
    CdbBid *fetchedBid = [self getBid:adUnit];
    if ([fetchedBid isEmpty]) {
        return;
    }
    
    SEL dfpCustomTargeting = @selector(customTargeting);
    SEL dfpSetCustomTargeting = @selector(setCustomTargeting:);
    if([adRequest respondsToSelector:dfpCustomTargeting] && [adRequest respondsToSelector:dfpSetCustomTargeting]) {
        id targeting = [adRequest performSelector:dfpCustomTargeting];
        if([targeting isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *customTargeting = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) targeting];
            [customTargeting setObject:fetchedBid.cpm.stringValue forKey:@"CRTO_cpm"];
            [customTargeting setObject:fetchedBid.displayUrl forKey:@"CRTO_displayUrl"];
            NSDictionary *updatedDictionary = [NSDictionary dictionaryWithDictionary:customTargeting];
            [adRequest performSelector:dfpSetCustomTargeting withObject:updatedDictionary];
        }
    }
}

@end
