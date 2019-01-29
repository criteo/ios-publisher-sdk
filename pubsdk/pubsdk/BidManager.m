//
//  BidManager.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "BidManager.h"

@implementation BidManager
{
    ConfigManager *configManager;
    DeviceInfo *deviceInfo;
    NetworkManager *networkManager;
}

- (instancetype) init {
    if(self = [super init]) {
        deviceInfo = [[DeviceInfo alloc] init];
        networkManager = [[NetworkManager alloc] initWithDeviceInfo:deviceInfo];
        _apiHandler = [[ApiHandler alloc] initWithNetworkManager:networkManager];
        configManager = [[ConfigManager alloc] initWithApiHandler:_apiHandler];

        _cacheManager = [[CacheManager alloc] init];
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
        bid = [CdbBid emptyBid];
    }
    return bid;
}

// TODO: Figure out a way to test this
- (void) prefetchBid:(AdUnit *) slotId {
    if(![self config]) {
        NSLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/BidManagerTests.m
    } else if ([[self config] killSwitch]) {
        NSLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }
    // move the async to the api handler
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.apiHandler callCdb:slotId gdprConsent:[self gdpr] config:[self config] ahCdbResponseHandler:^(NSArray *cdbBids) {
            for(CdbBid *bid in cdbBids) {
                [self.cacheManager setBid:bid forAdUnit:slotId];
            }
        }];
    });
}

- (void) initConfigWithNetworkId:(NSNumber *)networkId {
    if(!networkId) {
        NSLog(@"initConfigWithNetworkId is missing the following required value networkId = %@", networkId);
        return;
    }
    if(![self config]) {
        _config = [[Config alloc] initWithNetworkId:networkId];
    }

    [self refreshConfig];
}

- (void) refreshConfig {
    if (self.config) {
        [configManager refreshConfig:_config];
    }
}

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(AdUnit *) adUnit {
    if(![self config]) {
        NSLog(@"Config hasn't been fetched. So no bids will be fetched.");
        return;
        // TODO : move kill switch logic out of bid manager
        // http://review.criteois.lan/#/c/461220/10/pubsdk/pubsdkTests/BidManagerTests.m
    } else if ([[self config] killSwitch]) {
        NSLog(@"killSwitch is engaged. No bid will be fetched.");
        return;
    }
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
            [customTargeting setObject:fetchedBid.cpm.stringValue forKey:@"crt_cpm"];
            [customTargeting setObject:fetchedBid.displayUrl forKey:@"crt_displayUrl"];
            NSDictionary *updatedDictionary = [NSDictionary dictionaryWithDictionary:customTargeting];
            [adRequest performSelector:dfpSetCustomTargeting withObject:updatedDictionary];
        }
    }
}

@end
