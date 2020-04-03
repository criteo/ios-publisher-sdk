//
//  CASObjectQueue+ArraySet.m
//  pubsdk
//
//  Created by Romain Lofaso on 4/3/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CASObjectQueue+ArraySet.h"

@implementation CASObjectQueue (ArraySet)

- (void)addSafely:(id<NSCoding>)data {
    NSAssert(![self contains:data],
             @"Add to the queue an existing element: %@",
             [self all]);
    [self add:data];
}

- (BOOL)contains:(id<NSObject>)data {
    NSArray *all = [self all];
    const BOOL contains = [all containsObject:data];
    return contains;
}

- (NSArray *)all {
    return [self peek:NSUIntegerMax];
}

@end
