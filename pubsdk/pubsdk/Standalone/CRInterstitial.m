//
//  CRInterstitial.m
//  pubsdk
//
//  Created by Julien Stoeffler on 4/15/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "Criteo+Internal.h"
#import "CRInterstitial.h"
#import "CRInterstitial+Internal.h"
#import "Criteo.h"
#import "CR_CdbBid.h"
#import "NSError+CRErrors.h"
#import "CR_CacheAdUnit.h"
#import "CR_AdUnitHelper.h"
#import "CR_TokenValue.h"

@import WebKit;

@implementation CRInterstitial

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController
                   application:(UIApplication *)application
                    isAdLoaded:(BOOL)isAdLoaded {
    if(self = [super init]) {
        _criteo = criteo;
        viewController.webView.navigationDelegate = self;
        _viewController = viewController;
        _application = application;
        _isAdLoaded = isAdLoaded;
    }
    return self;
}

- (instancetype)init {
    return [self initWithCriteo:[Criteo sharedCriteo]
                 viewController:[[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                  view:nil
                                                                          interstitial:self]
                    application:[UIApplication sharedApplication]
                     isAdLoaded:NO];
}

- (BOOL)checkSafeToLoad {
    if(self.isAdLoading) {
        // Already loading
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                                description:@"An Ad is already being loaded."]];
            }
        });
        return NO;
    }
    if(self.viewController.presentingViewController) {
        // Already presenting
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                                description:@"Ad cannot load as another is already being presented."]];
            }
        });
        return NO;
    }

    self.isAdLoading = YES;
    self.isAdLoaded = NO;
    self.isResponseValid = NO;
    return YES;
}

- (void)loadAd:(NSString *)adUnitId {
    if(![self checkSafeToLoad]) {
        return;
    }
    CR_CacheAdUnit *adUnit = [CR_AdUnitHelper interstitialCacheAdUnitForAdUnitId:adUnitId
                                                                     screenSize:[[CR_DeviceInfo new] screenSize]] ;
    CR_CdbBid *bid = [self.criteo getBid:adUnit];
    if([bid isEmpty]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeNoFill]];
            }
        });
        self.isAdLoading = NO;
        return;
    }
    [self.viewController initWebViewIfNeeded];
    [self.viewController loadWebViewWithDisplayURL:bid.displayUrl];
}

- (void)loadAdWithBidToken:(CRBidToken *)bidToken {
    if(![self checkSafeToLoad]) {
        return;
    }
    CR_TokenValue *tokenValue = [self.criteo tokenValueForBidToken:bidToken
                                                        adUnitType:CRAdUnitTypeInterstitial];
    if(tokenValue == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeNoFill]];
            }
        });
        self.isAdLoading = NO;
        return;
    }
    [self.viewController initWebViewIfNeeded];
    [self.viewController loadWebViewWithDisplayURL:tokenValue.displayUrl];
}

-     (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    self.isAdLoading = NO;
    if(self.isResponseValid) {
        self.isAdLoaded = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
                [self.delegate interstitialDidLoadAd:self];
            }
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeNetworkError]];
            }
        });
    }
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.viewController.presentingViewController) {
        // Already presenting
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                             description:@"An Ad is already being presented."]];
            }
        });
        return;
    }

    if (!rootViewController) {
        // No view controller to present from
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter
                                                       description:@"rootViewController parameter must not be null."]];
            }
        });
        return;
    }

    if(!self.isAdLoaded) {
        // Ad not loaded
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                                description:@"Interstitial Ad is not loaded."]];
            }
        });
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
            [self.delegate interstitialWillAppear:self];
        }
    });
    [rootViewController presentViewController:self.viewController
                                     animated:YES
                                   completion:^{
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
                                               [self.delegate interstitialDidAppear:self];
                                           }
                                       });
                                   }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // cancel webView navigation for clicks on Links from mainFrame and open in browser
    if(navigationAction.navigationType == WKNavigationTypeLinkActivated && [navigationAction.sourceFrame isMainFrame]) {
        if(navigationAction.request.URL != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(interstitialWillLeaveApplication:)]) {
                    [self.delegate interstitialWillLeaveApplication:self];
                }
                [self.application openURL:navigationAction.request.URL];
                [self.viewController dismissViewController];
            });
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // allow all other navigation Types for webView
    decisionHandler(WKNavigationActionPolicyAllow);
}

// Delegate errors that occur during web view navigation
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.isAdLoading = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
            [self.delegate interstitial:self
               didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInternalError]];
        }
    });
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.isAdLoading = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
            [self.delegate interstitial:self
               didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInternalError]];
        }
    });
}

// Delegate HTTP errors
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
        if(httpResponse.statusCode >= 400) {
            self.isResponseValid = NO;
            self.isAdLoading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                    [self.delegate interstitial:self
                       didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeNetworkError]];
                }
            });
        }
        else {
            self.isResponseValid = YES;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

@end
