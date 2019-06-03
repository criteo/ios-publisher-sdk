//
//  Criteo.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"

static NSMutableArray<CRCacheAdUnit *> *registeredAdUnits;
static CR_BidManager *bidManager;
static bool hasPrefetched;
static Criteo *sharedInstance;

@implementation Criteo

- (id<CR_NetworkManagerDelegate>) networkMangerDelegate
{
    return bidManager.networkMangerDelegate;
}

- (void) setNetworkMangerDelegate:(id<CR_NetworkManagerDelegate>)networkMangerDelegate
{
    bidManager.networkMangerDelegate = networkMangerDelegate;
}

+ (CR_BidManager*) createBidManagerWithCriteoPublisherId:(NSString *) criteoPublisherId
{
    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:criteoPublisherId];
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] init];
    CR_NetworkManager *networkManager = [[CR_NetworkManager alloc] initWithDeviceInfo:deviceInfo];
    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:networkManager];
    CR_ConfigManager *configManager = [[CR_ConfigManager alloc] initWithApiHandler:apiHandler];

    CR_CacheManager *cacheManager = [[CR_CacheManager alloc] init];
    CR_GdprUserConsent *gdpr = [[CR_GdprUserConsent alloc] init];
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

- (void) registerCriteoPublisherId:(NSString *) criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    static dispatch_once_t registrationToken;
    dispatch_once(&registrationToken, ^{
        bidManager = [Criteo createBidManagerWithCriteoPublisherId:criteoPublisherId];
    });
    NSArray<CRCacheAdUnit *> *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:adUnits
                                                                          deviceInfo:[CR_DeviceInfo new]];
    [registeredAdUnits addObjectsFromArray:cacheAdUnits];
    [bidManager setSlots:cacheAdUnits];
    [self prefetchAll];
}

- (void) prefetchAll {
    if(!hasPrefetched) {
        for(CRCacheAdUnit *unit in registeredAdUnits) {
            [bidManager prefetchBid:unit];
        }
        hasPrefetched = YES;
    }
}

- (void) setBidsForRequest:(id)request
                withAdUnit:(CRAdUnit *)adUnit {
     NSArray<CRCacheAdUnit *> * cachedAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:@[adUnit]
                                                                             deviceInfo:[CR_DeviceInfo new]];
    [bidManager addCriteoBidToRequest:request forAdUnit:[cachedAdUnits objectAtIndex:0]];
}

- (CR_BidManager *)bidManager {
    return bidManager;
}

- (CR_CdbBid *)getBid:(CRCacheAdUnit *)slot {
    return [self.bidManager getBid:slot];
}

@end
