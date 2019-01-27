//
//  Criteo.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "Criteo.h"

static NSMutableArray<AdUnit *> *registeredAdUnits;
static BidManager *bidManager;
static bool hasPrefetched;
static Criteo *sharedInstance;

@implementation Criteo

+ (instancetype) sharedCriteo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registeredAdUnits = [[NSMutableArray alloc] init];
        bidManager = [[BidManager alloc] init];
        hasPrefetched = false;
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (void) registerAdUnit: (AdUnit *) adUnit {
    [registeredAdUnits addObject:adUnit];
    [bidManager setSlots: @[ adUnit ] ];
    
}

- (void) registerAdUnits:(NSArray<AdUnit *> *)adUnits {
    [registeredAdUnits addObjectsFromArray:adUnits];
    [bidManager setSlots:adUnits];
}

- (void) registerNetworkId:(NSUInteger)networkId {
    [bidManager initConfigWithNetworkId:@(networkId)];
}

- (void) prefetchAll {
    if(!hasPrefetched) {
        for(AdUnit *unit in registeredAdUnits) {
            [bidManager prefetchBid:unit];
        }
        hasPrefetched = YES;
    }
}

- (void) addCriteoBidToRequest:(id)request
                     forAdUnit:(AdUnit *)adUnit {
    [bidManager addCriteoBidToRequest:request forAdUnit:adUnit];
}
@end
