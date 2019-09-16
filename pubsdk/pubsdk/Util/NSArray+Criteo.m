//
//  NSArray+Criteo.m
//  pubsdk
//
//  Created by Richard Clark on 9/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSArray+Criteo.h"

@implementation NSArray (Criteo)

- (NSArray *)splitIntoChunks:(NSUInteger)chunkSize {
    NSMutableArray *chunks = [NSMutableArray new];
    for (int i = 0; i < self.count; i += chunkSize) {
        [chunks addObject:[self subarrayWithRange:NSMakeRange(i, MIN(chunkSize, self.count - i))]];
    }
    return chunks;
}

@end
