//
//  CRBannerView+Internal.h
//  pubsdk
//
//  Created by Julien Stoeffler on 4/3/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRBannerView_Internal_h
#define CRBannerView_Internal_h
@import WebKit;

@interface CRBannerView (Internal)

- (instancetype)initWithFrame:(CGRect)rect
                       criteo:(Criteo *)criteo
                      webView:(WKWebView *)webView
                  application:(UIApplication *)application;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@end

#endif /* CRBannerView_Internal_h */
