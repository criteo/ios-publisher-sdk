//
//  CRInterstitial+Internal.h
//  pubsdk
//
//  Created by Julien Stoeffler on 4/15/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRInterstitial_Internal_h
#define CRInterstitial_Internal_h

#import "Criteo.h"
@import WebKit;
#import "CR_InterstitialViewController.h"

@interface CRInterstitial (Internal)

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController
                   application:(UIApplication *)application
                    isAdLoaded:(BOOL)isAdLoaded;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error;

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

-     (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation;

@end


#endif /* CRInterstitial_Internal_h */
