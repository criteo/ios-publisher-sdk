//
//  CR_DeviceInfo.m
//  pubsdk
//
//  Created by Paul Davis on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import "CR_DeviceInfo.h"

static WKWebView *webView = nil;
static NSString *userAgent = nil;
static NSString *deviceId = nil;

@implementation CR_DeviceInfo

+ (void) initialize
{
    if ([self class] == [CR_DeviceInfo class])
    {
        [self setupUserAgent];
    }
}

+ (void) setupUserAgent
{
    webView = [[WKWebView alloc] initWithFrame:CGRectZero];

    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable navigatorUserAgent, NSError * _Nullable error) {
        if (!error && [navigatorUserAgent isKindOfClass:NSString.class]) {
            userAgent = navigatorUserAgent;
        }

        webView = nil;
    }];
}

- (NSString*) userAgent
{
    return userAgent;
}

- (NSString *) deviceId
{
    if (!deviceId) {
        deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return deviceId;
}

@end
