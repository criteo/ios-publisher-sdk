//
//  Criteo+Internal.h
//  pubsdk
//
//  Created by Paul Davis on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
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
@class CR_BidManagerBuilder;

@interface Criteo ()

@property (nonatomic) id<CR_NetworkManagerDelegate> networkMangerDelegate;
@property (nonatomic, readonly) CR_Config *config;
@property (nonatomic, readonly, strong) CR_BidManagerBuilder *bidManagerBuilder;

- (CR_CdbBid *)getBid:(CR_CacheAdUnit *)slot;
- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType;

- (instancetype)initWithBidManagerBuilder:(CR_BidManagerBuilder *)bidManagerBuilder;

@end


#endif /* Criteo_Internal_h */
