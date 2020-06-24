//
//  NSUserDefaults+Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSUserDefaults+Criteo.h"

@implementation NSUserDefaults (Criteo)

- (BOOL)cr_containsKey:(NSString *)key {
  return ([self objectForKey:key] != nil);
}

@end
