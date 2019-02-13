//
//  Criteo.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "Criteo.h"
#import "Criteo+Internal.h"

#import "BidManager.h"

static NSMutableArray<AdUnit *> *registeredAdUnits;
static BidManager *bidManager;
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

+ (BidManager*) createBidManagerWithNetworkId:(NSUInteger) networkId
{
    Config *config = [[Config alloc] initWithNetworkId:@(networkId)];
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    NetworkManager *networkManager = [[NetworkManager alloc] initWithDeviceInfo:deviceInfo];
    ApiHandler *apiHandler = [[ApiHandler alloc] initWithNetworkManager:networkManager];
    ConfigManager *configManager = [[ConfigManager alloc] initWithApiHandler:apiHandler];

    CacheManager *cacheManager = [[CacheManager alloc] init];
    GdprUserConsent *gdpr = [[GdprUserConsent alloc] init];
    AppEvents *appEvents = [[AppEvents alloc] initWithApiHandler:apiHandler
                                                          config:config
                                                            gdpr:gdpr
                                                      deviceInfo:deviceInfo];

    BidManager *bidManager = [[BidManager alloc] initWithApiHandler:apiHandler
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
               withAdUnits:(NSArray<AdUnit *> *)adUnits {
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
        for(AdUnit *unit in registeredAdUnits) {
            [bidManager prefetchBid:unit];
        }
        hasPrefetched = YES;
    }
}

- (void) setBidsForRequest:(id)request
                withAdUnit:(AdUnit *)adUnit {
    [bidManager addCriteoBidToRequest:request forAdUnit:adUnit];
}
@end
