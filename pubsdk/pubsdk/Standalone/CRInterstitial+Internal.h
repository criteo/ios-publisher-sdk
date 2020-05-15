//
//  CRInterstitial+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef CRInterstitial_Internal_h
#define CRInterstitial_Internal_h
@import WebKit;

#import "CRInterstitial.h"

@class Criteo;
@class CR_InterstitialViewController;
@class CRInterstitialAdUnit;

@interface CRInterstitial () <WKNavigationDelegate>

@property (nonatomic) BOOL isAdLoading;
@property (nonatomic, readwrite) BOOL isAdLoaded;
@property (nonatomic) BOOL isResponseValid;
@property (nonatomic, strong) Criteo *criteo;
@property (nonatomic, strong) CR_InterstitialViewController *viewController;
@property (nonatomic, readonly) CRInterstitialAdUnit *adUnit;

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController
                    isAdLoaded:(BOOL)isAdLoaded
                        adUnit:(CRInterstitialAdUnit *)adUnit;

- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit
                        criteo:(Criteo *)criteo;

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

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures;

@end


#endif /* CRInterstitial_Internal_h */
