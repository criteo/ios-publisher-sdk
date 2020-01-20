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
#import "CR_DataProtectionConsent.h"

@interface Criteo ()

@property (nonatomic, strong) NSMutableArray<CR_CacheAdUnit *> *registeredAdUnits;
@property (nonatomic, strong) CR_BidManager *bidManager;
@property (nonatomic, assign) bool hasPrefetched;
@property (nonatomic, assign) dispatch_once_t registrationToken;

@end

@implementation Criteo

- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut
{
    const CR_UsPrivacyCriteoState state = usPrivacyOptOut ?
        CR_UsPrivacyCriteoStateOptOut:
        CR_UsPrivacyCriteoStateOptIn;
    self.bidManager.consent.usPrivacyCriteoState = state;
}

- (void)setMopubContent:(NSString *)mopubContent {
    self.bidManager.consent.mopubConsent = mopubContent;
}

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
    static Criteo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
        CR_BidManager *bidManager = [builder buildBidManager];
        sharedInstance = [[self alloc] initWithBidManager:bidManager];
    });

    return sharedInstance;
}

- (instancetype)initWithBidManager:(CR_BidManager *)bidManager {
    if (self = [super init]) {
        _registeredAdUnits = [[NSMutableArray alloc] init];
        _hasPrefetched = false;
        _bidManager = bidManager;
    }
    return self;
}

- (void) registerCriteoPublisherId:(NSString *) criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    dispatch_once(&_registrationToken, ^{
        [self _registerCriteoPublisherId:criteoPublisherId withAdUnits:adUnits];
    });
}

- (void)_registerCriteoPublisherId:(NSString *)criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.config.criteoPublisherId = criteoPublisherId;

    CR_CacheAdUnitArray *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:adUnits];
    [self.registeredAdUnits addObjectsFromArray:cacheAdUnits];
    [self.bidManager registerWithSlots:cacheAdUnits];
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
