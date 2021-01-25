//
//  CR_DeviceInfo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <WebKit/WebKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import <UIKit/UIKit.h>
#import "CR_DeviceInfo.h"
#import "CR_ThreadManager.h"
#import "CR_Logging.h"

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
                CRLogDebug(@"UserAgent", @"Got navigatorUserAgent = %@, error = %@",
                           navigatorUserAgent, error);
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
      [self.webView
          evaluateJavaScript:@"navigator.userAgent"
           completionHandler:^(id _Nullable navigatorUserAgent, NSError *_Nullable error) {
             self.webView = nil;
             completionHandler(navigatorUserAgent, error);
           }];
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

- (CGSize)screenSize {
  return [UIScreen mainScreen].bounds.size;
}

- (CGSize)safeScreenSize {
  if (@available(iOS 11.0, *)) {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    return keyWindow.safeAreaLayoutGuide.layoutFrame.size;
  }
  return self.screenSize;
}

- (BOOL)validScreenSize:(CGSize)size {
  CGSize currentScreenSize = self.screenSize;
  return CGSizeEqualToSize(size, currentScreenSize) ||
         CGSizeEqualToSize(size, CGSizeMake(currentScreenSize.height, currentScreenSize.width));
}

@end
