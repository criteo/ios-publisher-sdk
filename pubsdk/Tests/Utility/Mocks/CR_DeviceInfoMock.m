//
//  CR_DeviceInfoMock.m
//  pubsdk
//
//  Created by Romain Lofaso on 1/27/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_DeviceInfoMock.h"
#import "MockWKWebView.h"

NSString * const CR_DeviceInfoMockDefaultUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148";

@implementation CR_DeviceInfoMock

- (instancetype)init {
    if (self = [super initWithWKWebView:[[MockWKWebView alloc] init]]) {
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
