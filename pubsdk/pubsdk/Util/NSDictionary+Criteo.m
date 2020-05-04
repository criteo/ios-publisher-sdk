//
//  NSDictionary+Criteo.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSDictionary+Criteo.h"

@implementation NSDictionary (Criteo)

- (NSDictionary *)dictionaryWithNewValue:(nullable id)value forKey:(id)key {
    NSMutableDictionary *mutableDict = [NSMutableDictionary new];
    [mutableDict addEntriesFromDictionary:self];
    mutableDict[key] = value;
    return mutableDict;
}

- (nullable NSDictionary *)dictionaryWithNewValue:(nullable id)value forKeys:(NSArray *)keys {
    if (keys.count == 0) { return nil; }
    id key = keys[0];
    if (!key) { return nil; }
    if (keys.count == 1) {
        return [self dictionaryWithNewValue:value forKey:key];
    } else {
        if (!self[key] || ![self[key] isKindOfClass:NSDictionary.class]) { return nil; }
        NSDictionary *subDict = self[key];
        NSArray *remainingKeys = [keys subarrayWithRange:NSMakeRange(1, keys.count - 1)];
        NSDictionary *modifiedSubDict = [subDict dictionaryWithNewValue:value forKeys:remainingKeys];
        if (!modifiedSubDict) { return nil; }
        return [self dictionaryWithNewValue:modifiedSubDict forKey:key];
    }
}

@end
