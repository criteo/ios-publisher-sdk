//
//  Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_ThreadManager.h"
#import "Logging.h"
#import "CR_DependencyProvider.h"

@interface Criteo ()

@property (nonatomic, strong) NSMutableArray<CR_CacheAdUnit *> *registeredAdUnits;
@property (nonatomic, strong, readonly) CR_BidManager *bidManager;
@property (nonatomic, assign) bool hasPrefetched;
@property (nonatomic, assign) bool registered;

@end

@implementation Criteo

- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut
{
    const CR_CcpaCriteoState state = usPrivacyOptOut ?
        CR_CcpaCriteoStateOptOut:
        CR_CcpaCriteoStateOptIn;
    self.bidManager.consent.usPrivacyCriteoState = state;
}

- (void)setMopubConsent:(NSString *)mopubConsent {
    self.bidManager.consent.mopubConsent = mopubConsent;
}

- (id<CR_NetworkManagerDelegate>) networkManagerDelegate
{
    return self.bidManager.networkManagerDelegate;
}

- (void) setNetworkManagerDelegate:(id<CR_NetworkManagerDelegate>)networkManagerDelegate
{
    self.bidManager.networkManagerDelegate = networkManagerDelegate;
}

+ (instancetype) sharedCriteo
{
    static Criteo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self criteo];
    });

    return sharedInstance;
}

+ (instancetype)criteo {
    CR_DependencyProvider *dependencyProvider = [[CR_DependencyProvider alloc] init];
    return [[self alloc] initWithDependencyProvider:dependencyProvider];
}

- (instancetype)initWithDependencyProvider:(CR_DependencyProvider *)dependencyProvider {
    if (self = [super init]) {
        _registeredAdUnits = [[NSMutableArray alloc] init];
        _registered = false;
        _hasPrefetched = false;
        _dependencyProvider = dependencyProvider;
    }
    return self;
}

- (void) registerCriteoPublisherId:(NSString *) criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    @synchronized (self) {
        if (!self.registered) {
            self.registered = true;
            @try {
                [self.dependencyProvider.threadManager dispatchAsyncOnGlobalQueue:^{
                    [self _registerCriteoPublisherId:criteoPublisherId withAdUnits:adUnits];
                }];
            }
            @catch (NSException *exception) {
                CLogException(exception);
            }
        }
    }
}

- (void)_registerCriteoPublisherId:(NSString *)criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.config.criteoPublisherId = criteoPublisherId;

    CR_CacheAdUnitArray *cacheAdUnits = [CR_AdUnitHelper cacheAdUnitsForAdUnits:adUnits];
    [self.registeredAdUnits addObjectsFromArray:cacheAdUnits];
    [self.bidManager registerWithSlots:cacheAdUnits];
    [self prefetchAll];
}

- (CR_BidManager *)bidManager {
    return self.dependencyProvider.bidManager;
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
    return [self.bidManager getBid:slot];
}

- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType {
    return [self.bidManager tokenValueForBidToken:bidToken adUnitType:adUnitType];
}

- (CR_Config *)config {
    return self.dependencyProvider.config;
}

- (CR_ThreadManager *)threadManager {
    return self.dependencyProvider.threadManager;
}

@end
