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
}

- (void)openExternalURL:(NSURL *)url
         withCompletion:(nullable CR_URLOpeningCompletion)completion {
    completion(self.successInCompletion);

}

- (void)openExternalURL:(NSURL *)url
             witOptions:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
             completion:(nullable CR_URLOpeningCompletion)completion {
    completion(self.successInCompletion);
}


@end
