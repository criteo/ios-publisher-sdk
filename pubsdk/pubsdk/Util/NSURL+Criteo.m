//
//  NSURL+Criteo.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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

- (void)openExternalWithOptions:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
     completion:(void (^ __nullable)(BOOL success))completion {
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:self
                                           options:options
                                 completionHandler:completion];
    } else {
        completion([[UIApplication sharedApplication] openURL:self]);
    }
}

- (void)openExternal:(void (^ __nullable)(BOOL success))completion {
    [self openExternalWithOptions:@{} completion:completion];
}

- (void)openExternal {
    [self openExternal:nil];
}

@end
