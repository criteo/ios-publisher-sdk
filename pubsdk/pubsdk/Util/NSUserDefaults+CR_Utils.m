//
//  NSUserDefaults+CRPrivateKeysAndUtils.m
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSUserDefaults+CR_Utils.h"

@implementation NSUserDefaults (CR_Utils)

- (BOOL)containsKey: (NSString *)key
{
    return ([self objectForKey:key] != nil);
}

@end


