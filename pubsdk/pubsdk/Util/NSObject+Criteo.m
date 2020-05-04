//
//  NSObject+Criteo.m
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSObject+Criteo.h"
#import <objc/runtime.h>
#import "CR_BidManagerHelper.h"

@implementation NSObject (Criteo)

+ (BOOL)object:(nullable id)obj1 isEqualTo:(nullable id)obj2 {
    if (obj1) {
        return [obj1 isEqual:obj2];   // isEqual returns NO if obj2 is nil
    } else {
        return !obj2;   // returns YES if obj1 and obj2 are both nil
    }
}

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
