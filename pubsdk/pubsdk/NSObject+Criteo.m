//
//  NSObject+Criteo.m
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 7/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSObject+Criteo.h"
#import <objc/runtime.h>
#import "CR_BidManagerHelper.h"

@implementation NSObject (Criteo)

+ (void)load {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            SEL loadAdSelector = NSSelectorFromString(@"loadAd");
            SEL newLoadAdSelector = NSSelectorFromString(@"crt_loadAd");
            Method originalMethod = class_getInstanceMethod(NSClassFromString(@"MPInterstitialAdController"), loadAdSelector);
            Method extendedMethod = class_getInstanceMethod(NSClassFromString(@"MPInterstitialAdController"), newLoadAdSelector);
            method_exchangeImplementations(originalMethod, extendedMethod);
#pragma clang diagnostic pop
        });
    });
}

- (void) crt_loadAd {
    [self crt_loadAd];
    [CR_BidManagerHelper removeCriteoBidsFromMoPubRequest:self];
}

@end
