//
//  NSUserDefaults+CRPrivateKeysAndUtils.m
//  pubsdk
//
//  Created by Romain Lofaso on 10/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSUserDefaults+CR_Utils.h"

@implementation NSUserDefaults (CR_Utils)

- (BOOL)containsKey: (NSString *)key
{
    return ([self objectForKey:key] != nil);
}

@end


