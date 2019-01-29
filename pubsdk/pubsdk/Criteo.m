//
//  Criteo.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "Criteo.h"

#import "BidManager.h"

static NSMutableArray<AdUnit *> *registeredAdUnits;
static BidManager *bidManager;
static bool hasPrefetched;
static Criteo *sharedInstance;

@implementation Criteo

+ (BidManager*) createBidManager
{
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    NetworkManager *networkManager = [[NetworkManager alloc] initWithDeviceInfo:deviceInfo];
    ApiHandler *apiHandler = [[ApiHandler alloc] initWithNetworkManager:networkManager];
    ConfigManager *configManager = [[ConfigManager alloc] initWithApiHandler:apiHandler];

    CacheManager *cacheManager = [[CacheManager alloc] init];
    GdprUserConsent *gdpr = [[GdprUserConsent alloc] init];

    BidManager *bidManager = [[BidManager alloc] initWithApiHandler:apiHandler
                                                       cacheManager:cacheManager
                                                             config:nil
                                                      configManager:configManager
                                                         deviceInfo:deviceInfo
                                                    gdprUserConsent:gdpr
                                                     networkManager:networkManager];

    return bidManager;
}

+ (instancetype) sharedCriteo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registeredAdUnits = [[NSMutableArray alloc] init];
        bidManager = [Criteo createBidManager];
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
