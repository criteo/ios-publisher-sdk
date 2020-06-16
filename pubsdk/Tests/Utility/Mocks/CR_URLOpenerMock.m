//
//  CR_URLOpenerMock.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_URLOpenerMock.h"

@implementation CR_URLOpenerMock

- (instancetype)init {
    self = [super init];
    if (self) {
        _successInCompletion = YES;
    }
    return self;
}

- (void)openExternalURL:(NSURL *)url {
    self.openExternalURLCount += 1;
}

- (void)openExternalURL:(NSURL *)url
         withCompletion:(nullable CR_URLOpeningCompletion)completion {
    self.openExternalURLCount += 1;
    completion(self.successInCompletion);
}

- (void)openExternalURL:(NSURL *)url
            withOptions:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
             completion:(nullable CR_URLOpeningCompletion)completion {
    self.openExternalURLCount += 1;
    completion(self.successInCompletion);
}


@end
