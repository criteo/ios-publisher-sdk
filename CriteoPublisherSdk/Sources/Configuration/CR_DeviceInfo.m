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

@property(strong, nonatomic, readonly) CR_ThreadManager *threadManager;
@property(strong, nonatomic, nullable) WKWebView *webView;

@end

@implementation CR_DeviceInfo {
  NSString *_deviceId;
  BOOL _isLoadingUserAgent;
  NSMutableSet *_loadUserAgentCompletionBlocks;
}

- (instancetype)init {
  return [self initWithThreadManager:[[CR_ThreadManager alloc] init]];
}

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager {
  self = [super init];
  if (self) {
    _loadUserAgentCompletionBlocks = [NSMutableSet new];
    _isLoadingUserAgent = NO;
    _threadManager = threadManager;
  }
  return self;
}

// For testing purposes only, webView will be lazily and properly instantiated on main queue if nil
- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager
                          testWebView:(WKWebView *)testWebView {
  self = [self initWithThreadManager:threadManager];
  if (self) {
    _webView = testWebView;
  }
  return self;
}

- (void)waitForUserAgent:(void (^_Nullable)(void))completion {
  if (self.userAgent) {
    completion();
    return;
  }

  @synchronized(self) {
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
    void (^completionHandler)(id, NSError *) =
        ^(id _Nullable navigatorUserAgent, NSError *_Nullable error) {
          [context executeBlock:^{
            [self.threadManager dispatchAsyncOnGlobalQueue:^{
              @synchronized(self) {
                self.webView = nil;
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

    // Make sure we're on the main queue because we're calling WebView which isn't thread safe
    [self.threadManager dispatchAsyncOnMainQueue:^{
      if (!self.webView) {
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
      }
      [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:completionHandler];
    }];
  }];
}

- (NSString *)deviceId {
  if (!_deviceId) {
#if TARGET_OS_SIMULATOR
    _deviceId = CR_SIMULATOR_IDFA;
#else
    _deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
#endif
  }
  return _deviceId;
}

+ (CGSize)getScreenSize {
  return [UIScreen mainScreen].bounds.size;
}

+ (BOOL)validScreenSize:(CGSize)size {
  CGSize currentScreenSize = [CR_DeviceInfo getScreenSize];
  return CGSizeEqualToSize(size, currentScreenSize) ||
         CGSizeEqualToSize(size, CGSizeMake(currentScreenSize.height, currentScreenSize.width));
}

@end
