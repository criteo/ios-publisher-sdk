//
//  NSURL+Criteo.m
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSURL+Criteo.h"

@implementation NSURL (Criteo)

+ (nullable NSURL *)URLWithStringOrNil:(nullable NSString *)string {
    if (string && [string isKindOfClass:NSString.class]) {
        return [NSURL URLWithString:string];
    } else {
        return nil;
    }
}

@end
