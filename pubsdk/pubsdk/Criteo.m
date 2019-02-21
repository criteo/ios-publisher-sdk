//
//  Criteo.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "Criteo.h"
#import "Criteo+Internal.h"

#import "CR_BidManager.h"

static NSMutableArray<CRAdUnit *> *registeredAdUnits;
static CR_BidManager *bidManager;
static bool hasPrefetched;
static Criteo *sharedInstance;

@implementation Criteo

- (id<NetworkManagerDelegate>) networkMangerDelegate
{
    return bidManager.networkMangerDelegate;
}

- (void) setNetworkMangerDelegate:(id<NetworkManagerDelegate>)networkMangerDelegate
{
    bidManager.networkMangerDelegate = networkMangerDelegate;
}

+ (CR_BidManager*) createBidManagerWithNetworkId:(NSUInteger) networkId
{
    Config *config = [[Config alloc] initWithNetworkId:@(networkId)];
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    NetworkManager *networkManager = [[NetworkManager alloc] initWithDeviceInfo:deviceInfo];
    ApiHandler *apiHandler = [[ApiHandler alloc] initWithNetworkManager:networkManager];
    ConfigManager *configManager = [[ConfigManager alloc] initWithApiHandler:apiHandler];

    CacheManager *cacheManager = [[CacheManager alloc] init];
    GdprUserConsent *gdpr = [[GdprUserConsent alloc] init];
    CR_AppEvents *appEvents = [[CR_AppEvents alloc] initWithApiHandler:apiHandler
                                                                config:config
                                                                  gdpr:gdpr
                                                            deviceInfo:deviceInfo];

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:apiHandler
                                                             cacheManager:cacheManager
                                                                   config:config
                                                            configManager:configManager
                                                               deviceInfo:deviceInfo
                                                          gdprUserConsent:gdpr
                                                           networkManager:networkManager
                                                                appEvents:appEvents
                                                           timeToNextCall:0];

    return bidManager;
}

+ (instancetype) sharedCriteo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registeredAdUnits = [[NSMutableArray alloc] init];
        hasPrefetched = false;
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (void) registerNetworkId:(NSUInteger) networkId
               withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    static dispatch_once_t registrationToken;
    dispatch_once(&registrationToken, ^{
        bidManager = [Criteo createBidManagerWithNetworkId:networkId];
    });

    [registeredAdUnits addObjectsFromArray:adUnits];
    [bidManager setSlots:adUnits];
    [self prefetchAll];
}

- (void) prefetchAll {
    if(!hasPrefetched) {
        for(CRAdUnit *unit in registeredAdUnits) {
            [bidManager prefetchBid:unit];
        }
        hasPrefetched = YES;
    }
}

- (void) setBidsForRequest:(id)request
                withAdUnit:(CRAdUnit *)adUnit {
    [bidManager addCriteoBidToRequest:request forAdUnit:adUnit];
}
@end
