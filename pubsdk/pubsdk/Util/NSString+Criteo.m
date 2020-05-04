//
//  NSString+Criteo.m
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSString+Criteo.h"

@implementation NSString (Criteo)

+ (nullable NSString *)stringWithStringOrNil:(nullable NSString *)string {
    if (string && [string isKindOfClass:NSString.class]) {
        return [NSString stringWithString:string];
    } else {
        return nil;
    }
}

+ (nullable NSString *)nonEmptyStringWithStringOrNil:(nullable NSString *)string {
    if (string && [string isKindOfClass:NSString.class] && string.length > 0) {
        return [NSString stringWithString:string];
    } else {
        return nil;
    }
}

@end
