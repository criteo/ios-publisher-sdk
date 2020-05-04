//
//  CR_DeviceInfoMock.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_DeviceInfoMock.h"
#import "CR_ThreadManager.h"
#import "MockWKWebView.h"

NSString * const CR_DeviceInfoMockDefaultUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148";

@implementation CR_DeviceInfoMock

- (instancetype)init {
    MockWKWebView *webView = [[MockWKWebView alloc] init];
    CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
    self = [super initWithThreadManager:threadManager
                                webView:webView];
    if (self) {
        self.userAgent = CR_DeviceInfoMockDefaultUserAgent;
    }
    return self;
}

- (void)waitForUserAgent:(void (^ _Nullable)(void))completion {
    if (completion != nil) {
        completion();
    }
}

@end
