//
//  CR_URLOpening.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_URLOpening.h"

@implementation CR_URLOpener

- (void)openExternalURL:(NSURL *)url {
  [self openExternalURL:url withCompletion:nil];
}

- (void)openExternalURL:(NSURL *)url withCompletion:(nullable CR_URLOpeningCompletion)completion {
  [self openExternalURL:url withOptions:@{} completion:completion];
}

- (void)openExternalURL:(NSURL *)url
            withOptions:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
             completion:(nullable CR_URLOpeningCompletion)completion {
  if (@available(iOS 10, *)) {
    [[UIApplication sharedApplication] openURL:url options:options completionHandler:completion];
  } else if (completion) {
    completion([[UIApplication sharedApplication] openURL:url]);
  }
}

@end
