//
//  CR_CacheAdUnit.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/7/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_CacheAdUnit.h"

@implementation CR_CacheAdUnit
{
    NSUInteger _hash;
}

- (instancetype) init {
    CGSize size = CGSizeMake(0.0,0.0);
    return [self initWithAdUnitId:@"" size:size];
}

- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                             size:(CGSize)size {
    if(self = [super init]) {
        _adUnitId = adUnitId;
        _size = size;
        // to get rid of the decimal point
        NSUInteger width = roundf(size.width);
        NSUInteger height = roundf(size.height);
        _hash = [[NSString stringWithFormat:@"%@_x_%lu_x_%lu", _adUnitId, (unsigned long)width, (unsigned long)height] hash];
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
    if (![object isKindOfClass:[CR_CacheAdUnit class]]) {
        return NO;
    }
    CR_CacheAdUnit *obj = (CR_CacheAdUnit *) object;
    return self.hash == obj.hash;
}

- (BOOL) isValid {
    return self.adUnitId.length > 0 && roundf(self.size.width) > 0 && roundf(self.size.height) > 0;
}

- (instancetype) copyWithZone:(NSZone *)zone {
    CR_CacheAdUnit *copy = [[CR_CacheAdUnit alloc] initWithAdUnitId:self.adUnitId size:self.size];
    return copy;
}

- (NSString *) cdbSize {
    return [NSString stringWithFormat:@"%lux%lu"
            , (unsigned long)self.size.width
            , (unsigned long)self.size.height];
}
@end
