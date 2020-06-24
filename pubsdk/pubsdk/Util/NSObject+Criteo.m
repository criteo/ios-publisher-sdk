//
//  NSObject+Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSObject+Criteo.h"
#import <objc/runtime.h>
#import "CR_BidManagerHelper.h"

@implementation NSObject (Criteo)

+ (BOOL)cr_object:(nullable id)obj1 isEqualTo:(nullable id)obj2 {
  if (obj1) {
    return [obj1 isEqual:obj2];  // isEqual returns NO if obj2 is nil
  } else {
    return !obj2;  // returns YES if obj1 and obj2 are both nil
  }
}

// FIXME move this to a Criteo Class load method as it is most likely not needed on NSObject
+ (void)load {
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      SEL loadAdSelector = NSSelectorFromString(@"loadAd");
      SEL newLoadAdSelector = NSSelectorFromString(@"cr_loadAd");
      Method originalMethod =
          class_getInstanceMethod(NSClassFromString(@"MPInterstitialAdController"), loadAdSelector);
      Method extendedMethod = class_getInstanceMethod(
          NSClassFromString(@"MPInterstitialAdController"), newLoadAdSelector);
      method_exchangeImplementations(originalMethod, extendedMethod);
#pragma clang diagnostic pop
    });
  });
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
- (void)cr_loadAd {
  [self cr_loadAd];
  [CR_BidManagerHelper removeCriteoBidsFromMoPubRequest:self];
}
#pragma clang diagnostic pop

@end
