//
//  Criteo+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef Criteo_Internal_h
#define Criteo_Internal_h

#import "CR_NetworkManagerDelegate.h"
#import "CR_CacheAdUnit.h"
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"
#import "Criteo.h"

@class CR_CdbBid;
@class CR_TokenValue;
@class CRBidToken;
@class CR_Config;
@class CR_BidManager;
@class CR_ThreadManager;
@class CR_DependencyProvider;

@interface Criteo ()

@property (strong, nonatomic, readonly) CR_DependencyProvider *dependencyProvider;
@property (weak, nonatomic) id<CR_NetworkManagerDelegate> networkManagerDelegate;
@property (strong, nonatomic, readonly) CR_Config *config;
@property (strong, nonatomic, readonly) CR_ThreadManager *threadManager;

- (CR_CdbBid *)getBid:(CR_CacheAdUnit *)slot;
- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType;

- (instancetype)initWithDependencyProvider:(CR_DependencyProvider *)dependencyProvider;
+ (instancetype)criteo;

@end


#endif /* Criteo_Internal_h */
