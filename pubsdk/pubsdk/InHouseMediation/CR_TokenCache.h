//
//  CR_TokenCache.h
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 6/10/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBidToken.h"
#import "CR_CdbBid.h"
#import "CR_TokenValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_TokenCache : NSObject

- (instancetype) init;

- (CRBidToken *) getTokenForBid:(CR_CdbBid *)cdbBid
                     adUnitType:(CRAdUnitType)adUnitType;

- (CR_TokenValue *) getValueForToken:(CRBidToken *)token
                          adUnitType:(CRAdUnitType)adUnitType;

- (void)setTokenMapWithValue:(CR_TokenValue *)tokenValue
                      forKey:(CRBidToken *)token;

- (CR_TokenValue *)tokenValueForKey:(CRBidToken *)token;

@end

NS_ASSUME_NONNULL_END
