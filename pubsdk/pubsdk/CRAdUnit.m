//
//  CRAdUnit.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/7/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRAdUnit.h"

@implementation CRAdUnit
{
    NSUInteger _hash;
}

- (instancetype) init {
    CGSize size = CGSizeMake(0.0,0.0);
    return [self initWithAdUnitId:nil size:size];
}

- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                             size:(CGSize)size {
    if(self = [super init]) {
        _adUnitId = adUnitId;
        _size = size;
        // to get rid of the decimal point
        NSUInteger width = floor(size.width);
        NSUInteger height = floor(size.height);
        _hash = [[NSString stringWithFormat:@"%@_x_%lu_x_%lu", _adUnitId, width, height] hash];
    }
    return self;
}

- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                            width:(CGFloat)width
                           height:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    return [self initWithAdUnitId:adUnitId size:size];
}

- (NSUInteger) hash {
    return _hash;
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[CRAdUnit class]]) {
        return NO;
    }
    CRAdUnit *obj = (CRAdUnit *) object;
    return self.hash == obj.hash;
}

- (instancetype) copyWithZone:(NSZone *)zone {
    CRAdUnit *copy = [[CRAdUnit alloc] initWithAdUnitId:self.adUnitId size:self.size];
    return copy;
}

- (NSString *) cdbSize {
    return [NSString stringWithFormat:@"%lux%lu"
            , (NSUInteger)self.size.width
            , (NSUInteger)self.size.height];
}
@end
