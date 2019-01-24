//
//  Criteo.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "Criteo.h"

@implementation Criteo

static NSMutableArray<AdUnit *> *registeredAdUnits = nil;
static BidManager *bidManager = nil;
static BOOL hasPrefetched = NO;

+ (instancetype) sharedCriteo {
    static Criteo *sharedCriteoInstance = nil;
    @synchronized (self) {
        if (sharedCriteoInstance == nil) {
            sharedCriteoInstance = [[self alloc] init];
            registeredAdUnits = [[NSMutableArray alloc] init];
            bidManager = [[BidManager alloc] init];
        }
    }
    return sharedCriteoInstance;
}

- (void) registerAdUnit: (AdUnit *) adUnit {
    
    
    [registeredAdUnits addObject:adUnit];
    NSArray *adUnits = [[NSArray alloc] initWithObjects:adUnit, nil];
    [bidManager setSlots:adUnits];
    
}

- (void) registerAdUnits:(NSArray<AdUnit *> *)adUnits {
    
    [registeredAdUnits addObjectsFromArray:adUnits];
    [bidManager setSlots:adUnits];
    
}

- (void) registerNetworkId:(NSNumber *)networkId {
    
    [bidManager setNetworkId:networkId];
    
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
