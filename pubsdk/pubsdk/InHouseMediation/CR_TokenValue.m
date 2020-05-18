//
//  CR_TokenValue.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_TokenValue.h"

@implementation CR_TokenValue

- (instancetype)initWithDisplayURL:(NSString *)displayURL
                        insertTime:(NSDate *)insertTime
                               ttl:(NSTimeInterval)ttl
                            adUnit:(CRAdUnit *)adUnit {
    if(self = [super init]) {
        _displayUrl = displayURL;
        _insertTime = insertTime;
        _adUnit = adUnit;
        _ttl = ttl;
    }
    return self;
}

- (BOOL)isExpired {
    return
    [[NSDate date]timeIntervalSinceReferenceDate] - [[self insertTime]timeIntervalSinceReferenceDate]
    > self.ttl;
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[CR_TokenValue class]]) {
        CR_TokenValue *other = object;

        if ([self.displayUrl isEqualToString:other.displayUrl] &&
            [self.insertTime isEqual:other.insertTime] &&
            [self.adUnit isEqualToAdUnit:other.adUnit] &&
            self.ttl == other.ttl) {
            return YES;
        }
    }
    return NO;
}

@end
