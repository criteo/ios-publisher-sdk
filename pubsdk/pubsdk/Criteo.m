//
//  Criteo.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_BidManagerBuilder.h"

// The shared instance is unscoped for allowing internal check within instance classes.
static Criteo *sharedInstance = nil;

@interface Criteo ()

@property (nonatomic, strong) NSMutableArray<CR_CacheAdUnit *> *registeredAdUnits;
@property (nonatomic, strong) CR_BidManager *bidManager;
@property (nonatomic, assign) bool hasPrefetched;

@end

@implementation Criteo

- (id<CR_NetworkManagerDelegate>) networkMangerDelegate
{
    return self.bidManager.networkMangerDelegate;
}

- (void) setNetworkMangerDelegate:(id<CR_NetworkManagerDelegate>)networkMangerDelegate
{
    self.bidManager.networkMangerDelegate = networkMangerDelegate;
}

+ (instancetype) sharedCriteo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
        sharedInstance = [[self alloc] initWithBidManagerBuilder:builder];
    });

    return sharedInstance;
}

- (instancetype)initWithBidManagerBuilder:(CR_BidManagerBuilder *)bidManagerBuilder {
    if (self = [super init]) {
        _registeredAdUnits = [[NSMutableArray alloc] init];
        _hasPrefetched = false;
        _bidManagerBuilder = bidManagerBuilder;
    }
    return self;
}

- (void) registerCriteoPublisherId:(NSString *) criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {

    // Checking if it is not shared instance allowes us to be able to
    // use this method multiple times in isolation in the tests.
    const BOOL isSharedInstance = (self == [[self class] sharedCriteo]);
    if (isSharedInstance) {
        static dispatch_once_t registrationToken;
        dispatch_once(&registrationToken, ^{
            [self _registerCriteoPublisherId:criteoPublisherId withAdUnits:adUnits];
        });
    } else {
        [self _registerCriteoPublisherId:criteoPublisherId withAdUnits:adUnits];
    }
}

- (void)_registerCriteoPublisherId:(NSString *) criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.bidManagerBuilder.criteoPublisherId = criteoPublisherId;
    self.bidManager = [self.bidManagerBuilder buildBidManager];

    CR_CacheAdUnitArray *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:adUnits];
    [self.registeredAdUnits addObjectsFromArray:cacheAdUnits];
    [self.bidManager setSlots:cacheAdUnits];
    [self prefetchAll];
}

- (void) prefetchAll {
    if (!self.hasPrefetched) {
        [self.bidManager prefetchBids:self.registeredAdUnits];
        self.hasPrefetched = YES;
    }
}

- (void) setBidsForRequest:(id)request
                withAdUnit:(CRAdUnit *)adUnit {
    [self.bidManager addCriteoBidToRequest:request
                            forAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]];
}

- (CRBidResponse *)getBidResponseForAdUnit:(CRAdUnit *)adUnit {
    return [self.bidManager bidResponseForCacheAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]
                                           adUnitType:adUnit.adUnitType];
}

- (CR_CdbBid *)getBid:(CR_CacheAdUnit *)slot {
    // bidManager is nil when adUnit is not registered
    if(self.bidManager == nil) {
        return [CR_CdbBid emptyBid];
    }
    return [self.bidManager getBid:slot];
}

- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType {
    return [self.bidManager tokenValueForBidToken:bidToken adUnitType:adUnitType];
}

- (CR_Config *)config {
    return self.bidManager.config;
}

@end
