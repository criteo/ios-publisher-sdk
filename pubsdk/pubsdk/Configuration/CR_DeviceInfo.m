//
//  CR_DeviceInfo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import "CR_DeviceInfo.h"
#import "CR_ThreadManager.h"
#import "Logging.h"

@interface CR_DeviceInfo ()

@property (strong, nonatomic, readonly) CR_ThreadManager *threadManager;
@property (strong, nonatomic, readonly) WKWebView *webView;

@end

@implementation CR_DeviceInfo
{
    NSString *_deviceId;
    BOOL _isLoadingUserAgent;
    NSMutableSet *_loadUserAgentCompletionBlocks;
}

- (instancetype)init {
    return [self initWithThreadManager:[[CR_ThreadManager alloc] init]
                               webView:[[WKWebView alloc] initWithFrame:CGRectZero]];
}

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager {
    self = [self initWithThreadManager:threadManager
                               webView:[[WKWebView alloc] initWithFrame:CGRectZero]];
    return self;
}

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager
                              webView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _loadUserAgentCompletionBlocks = [NSMutableSet new];
        _isLoadingUserAgent = NO;
        _threadManager = threadManager;
        _webView = webView;
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
            [self setupUserAgentWithWebView];
        }
    }
}

- (void)setupUserAgentWithWebView {
    if (_isLoadingUserAgent) {
        return;
    }
    _isLoadingUserAgent = YES;

    [self.threadManager runWithCompletionContext:^(CR_CompletionContext *context) {
        void (^completionHandler)(id, NSError *) = ^(id _Nullable navigatorUserAgent, NSError *_Nullable error) {
            [context executeBlock:^{
                [self.threadManager dispatchAsyncOnGlobalQueue:^{
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
                }];
            }];
        };

        // Make sure we're on the main thread because we're calling WebView which isn't thread safe
        [self.threadManager dispatchAsyncOnMainQueue:^{
            [self.webView evaluateJavaScript:@"navigator.userAgent"
                             completionHandler:completionHandler];
        }];
    }];
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
