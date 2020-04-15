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
#import "Logging.h"

@implementation CR_DeviceInfo
{
    NSString *_deviceId;
    BOOL _isLoadingUserAgent;
    NSMutableSet *_loadUserAgentCompletionBlocks;
    WKWebView *_wkWebView;
}

- (instancetype)init {
    self = [self initWithWKWebView: [[WKWebView alloc] initWithFrame:CGRectZero]];
    return self;
}

- (instancetype)initWithWKWebView:(WKWebView *)wkWebView {
    self = [super init];
    if (self) {
        _loadUserAgentCompletionBlocks = [NSMutableSet new];
        _isLoadingUserAgent = NO;
        _wkWebView = wkWebView;
    }
    return self;
}

- (void)waitForUserAgent:(void (^ _Nullable)(void))completion {
    if (self.userAgent) {
        completion();
        return;
    }

    @synchronized (self) {
        // double-checked locking pattern
        if (self.userAgent) {
            completion();
            return;
        }
        if (completion != nil) {
            [_loadUserAgentCompletionBlocks addObject:completion];
        }
        if (!self->_isLoadingUserAgent) {
            [self setupUserAgentWithWKWebView];
        }
    }
}

- (void)setupUserAgentWithWKWebView {
    if (_isLoadingUserAgent) {
        return;
    }
    _isLoadingUserAgent = YES;
    // Make sure we're on the main thread because we're calling WKWebView which isn't thread safe
    void (^completionHandler)(id, NSError *) = ^(id _Nullable navigatorUserAgent, NSError *_Nullable error) {
        @try {
            @synchronized (self) {
                CLog(@"-----> navigatorUserAgent = %@, error = %@", navigatorUserAgent, error);
                if (!error && [navigatorUserAgent isKindOfClass:NSString.class]) {
                    self.userAgent = navigatorUserAgent;
                }
                for (void (^completionBlock)(void) in self->_loadUserAgentCompletionBlocks) {
                    completionBlock();
                }
                [self->_loadUserAgentCompletionBlocks removeAllObjects];
                self->_isLoadingUserAgent = NO;
            }
        }
        @catch (NSException *exception) {
            CLogException(exception);
        }
    };
    [self->_wkWebView evaluateJavaScript:@"navigator.userAgent"
                       completionHandler:completionHandler];
}

- (NSString *)deviceId {
    if (!_deviceId) {
        _deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return _deviceId;
}

+ (CGSize)getScreenSize {
    return [UIScreen mainScreen].bounds.size;
}

+ (BOOL)validScreenSize:(CGSize)size {
    CGSize currentScreenSize = [CR_DeviceInfo getScreenSize];
    return CGSizeEqualToSize(size, currentScreenSize) || CGSizeEqualToSize(size, CGSizeMake(currentScreenSize.height, currentScreenSize.width));
}

@end
