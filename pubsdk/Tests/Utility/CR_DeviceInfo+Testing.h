//
//  CR_TestNativeAssets.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_DeviceInfo.h"

@interface CR_DeviceInfo (Testing)

@property (strong, nonatomic, readonly) WKWebView *webView;

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager
                          testWebView:(WKWebView *)testWebView;

@end
