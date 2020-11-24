//
//  CRInterstitial+Internal.h
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

#ifndef CRInterstitial_Internal_h
#define CRInterstitial_Internal_h

#import <WebKit/WebKit.h>
#import "CRInterstitial.h"

@class Criteo;
@class CR_InterstitialViewController;
@class CRInterstitialAdUnit;
@protocol CR_URLOpening;

@interface CRInterstitial () <WKNavigationDelegate>

@property(nonatomic) BOOL isAdLoading;
@property(nonatomic, readwrite) BOOL isAdLoaded;
@property(nonatomic) BOOL isResponseValid;
@property(nonatomic, strong) Criteo *criteo;
@property(nonatomic, strong) CR_InterstitialViewController *viewController;
@property(nonatomic, readonly) CRInterstitialAdUnit *adUnit;
@property(nonatomic, strong) UIViewController *rootViewController;

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController
                    isAdLoaded:(BOOL)isAdLoaded
                        adUnit:(CRInterstitialAdUnit *)adUnit
                     urlOpener:(id<CR_URLOpening>)urlOpener;

- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit criteo:(Criteo *)criteo;

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

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures;

@end

#endif /* CRInterstitial_Internal_h */
