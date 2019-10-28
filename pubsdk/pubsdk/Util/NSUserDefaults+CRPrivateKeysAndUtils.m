//
//  NSUserDefaults+CRPrivateKeysAndUtils.m
//  pubsdk
//
//  Created by Romain Lofaso on 10/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSUserDefaults+CRPrivateKeysAndUtils.h"

NSString * const NSUserDefaultsKillSwitchKey = @"CRITEO_KillSwitch";

@implementation NSUserDefaults (CRPrivateKeysAndUtils)

- (BOOL)containsKey: (NSString *)key
{
    return ([self objectForKey:key] != nil);
}

@end


