//
//  NSURL+Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSURL+Criteo.h"

@implementation NSURL (Criteo)

+ (nullable NSURL *)cr_URLWithStringOrNil:(nullable NSString *)string {
    if (string && [string isKindOfClass:NSString.class]) {
        return [NSURL URLWithString:string];
    } else {
        return nil;
    }
}

@end
