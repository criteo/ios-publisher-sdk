//
//  CR_TokenValue.m
//  pubsdk
//
//  Created by Sneha Pathrose on 6/4/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_TokenValue.h"

@implementation CR_TokenValue

- (instancetype)initWithDisplayURL:(NSString *)displayURL
                        insertTime:(NSDate *)insertTime
                               ttl:(NSTimeInterval)ttl
                        adUnitType:(CRAdUnitType)adUnitType {
    if(self = [super init]) {
        _displayUrl = displayURL;
        _insertTime = insertTime;
        _adUnitType = adUnitType;
        _ttl = ttl;
    }
    return self;
}

- (BOOL)isExpired {
    return
    [[NSDate date]timeIntervalSinceReferenceDate] - [[self insertTime]timeIntervalSinceReferenceDate]
    > self.ttl;
}

@end
