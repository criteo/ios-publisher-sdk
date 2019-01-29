//
//  DeviceInfo.m
//  pubsdk
//
//  Created by Paul Davis on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "DeviceInfo.h"

@interface DeviceInfo ()

- (void) setupUserAgent;

@end

@implementation DeviceInfo
{
    WKWebView *webView;
}

- (instancetype) init
{
    if (self = [super init])
    {
        [self setupUserAgent];
    }

    return self;
}

- (void) setupUserAgent
{
    webView = [[WKWebView alloc] initWithFrame:CGRectZero];

    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable navigatorUserAgent, NSError * _Nullable error) {
        if (!error && [navigatorUserAgent isKindOfClass:NSString.class]) {
            self->_userAgent = navigatorUserAgent;
        }

        self->webView = nil;
    }];
}

@end
