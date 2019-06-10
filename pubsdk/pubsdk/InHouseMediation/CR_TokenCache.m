//
//  CR_TokenCache.m
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 6/10/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_TokenCache.h"
#import "CRAdUnit+Internal.h"
#import "CRBidToken+Internal.h"

@interface CR_TokenCache()

@property (strong, nonatomic) NSMutableDictionary<CRBidToken *, CR_TokenValue *> *tokenMap;

@end

@implementation CR_TokenCache

- (instancetype) init {
    if (self = [super init]){
        _tokenMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (CRBidToken *) getTokenForBid:(CR_CdbBid *)cdbBid
                     adUnitType:(CRAdUnitType)adUnitType {
    if (!cdbBid) {
        return nil;
    }
    CRBidToken *token = [CR_TokenCache generateToken];
    [self.tokenMap setObject:[[CR_TokenValue alloc] initWithDisplayURL:cdbBid.displayUrl
                                                            insertTime:cdbBid.insertTime
                                                                   ttl:cdbBid.ttl
                                                            adUnitType:adUnitType]
                      forKey:token];
    return token;
}

- (CR_TokenValue *) getValueForToken:(CRBidToken *)token {
    CR_TokenValue *value = self.tokenMap[token];
    if (token){
        [self.tokenMap removeObjectForKey:token];
    }
    return value;
}

+ (CRBidToken *) generateToken {
    NSUUID *uuid = [NSUUID UUID];
    return [[CRBidToken alloc] initWithUUID:uuid];
}

@end
