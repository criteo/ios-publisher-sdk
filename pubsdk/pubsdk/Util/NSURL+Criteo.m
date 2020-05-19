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

- (void)cr_openExternalWithOptions:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
                        completion:(void (^ __nullable)(BOOL success))completion {
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:self
                                           options:options
                                 completionHandler:completion];
    } else {
        completion([[UIApplication sharedApplication] openURL:self]);
    }
}

- (void)cr_openExternal:(void (^ __nullable)(BOOL success))completion {
    [self cr_openExternalWithOptions:@{} completion:completion];
}

- (void)cr_openExternal {
    [self cr_openExternal:nil];
}

@end
