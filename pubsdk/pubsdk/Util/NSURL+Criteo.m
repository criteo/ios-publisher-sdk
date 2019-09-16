//
//  NSURL+Criteo.m
//  pubsdk
//
//  Created by Richard Clark on 9/16/19.
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
