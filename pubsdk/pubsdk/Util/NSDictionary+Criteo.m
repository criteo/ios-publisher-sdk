//
//  NSDictionary+Criteo.m
//  pubsdk
//
//  Created by Richard Clark on 9/14/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSDictionary+Criteo.h"

@implementation NSDictionary (Criteo)

- (NSDictionary *)dictionaryWithNewValue:(id _Nullable)value forKey:(id)key  {
    NSMutableDictionary *mutableDict = [NSMutableDictionary new];
    [mutableDict addEntriesFromDictionary:self];
    mutableDict[key] = value;
    return mutableDict;
}

@end
