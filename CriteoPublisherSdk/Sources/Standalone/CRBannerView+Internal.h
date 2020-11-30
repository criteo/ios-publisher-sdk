//
//  CRBannerView+Internal.h
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

#ifndef CRBannerView_Internal_h
#define CRBannerView_Internal_h

#import <WebKit/WebKit.h>
#import "CRBannerView.h"

@class Criteo;
@protocol CR_URLOpening;

@interface CRBannerView (Internal)

- (instancetype)initWithFrame:(CGRect)rect
                       criteo:(Criteo *)criteo
                      webView:(WKWebView *)webView
                       adUnit:(CRBannerAdUnit *)adUnit
                    urlOpener:(id<CR_URLOpening>)opener;

/// For tests only, where we need to mock the webview, which crashes on addSubview
- (instancetype)initWithFrame:(CGRect)rect
                       criteo:(Criteo *)criteo
                      webView:(WKWebView *)webView
                   addWebView:(BOOL)addWebView
                       adUnit:(CRBannerAdUnit *)adUnit
                    urlOpener:(id<CR_URLOpening>)opener;

- (instancetype)initWithAdUnit:(CRBannerAdUnit *)adUnit criteo:(Criteo *)criteo;

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error;

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error;

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures;

@end

#endif /* CRBannerView_Internal_h */
