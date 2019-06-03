//
//  CRInterstitial.m
//  pubsdk
//
//  Created by Julien Stoeffler on 4/15/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRInterstitial.h"
#import "Criteo.h"
#import "CR_CdbBid.h"
#import "Criteo+Internal.h"
#import "CR_InterstitialViewController.h"
#import "NSError+CRErrors.h"
#import "CRCacheAdUnit.h"
#import "CR_AdUnitHelper.h"

@import WebKit;

@interface CRInterstitial() <WKNavigationDelegate>

@property (nonatomic, readwrite) BOOL isLoaded;
@property (nonatomic, strong) Criteo *criteo;
@property (nonatomic, strong) CR_InterstitialViewController *viewController;
@property (nonatomic, weak) UIApplication *application;

@end

@implementation CRInterstitial

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController
                   application:(UIApplication *)application{
    if(self = [super init]) {
        _criteo = criteo;
        viewController.webView.navigationDelegate = self;
        _viewController = viewController;
        _application = application;
    }
    return self;
}

- (instancetype)init {
    return [self initWithCriteo:[Criteo sharedCriteo]
                 viewController:[[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                          interstitial:self]
                    application:[UIApplication sharedApplication]];
}

- (void)loadAd:(NSString *)adUnitId {
    self.isLoaded = NO;
    CRCacheAdUnit *adUnit = [CR_AdUnitHelper interstitialCacheAdUnitForAdUnitId:adUnitId
                                                                     screenSize:[[CR_DeviceInfo new] screenSize]] ;
    CR_CdbBid *bid = [self.criteo getBid:adUnit];
    if([bid isEmpty]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                [self.delegate interstitial:self
                   didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeNoFill]];
            }
        });
        return;
    }
    NSString *htmlString = [NSString stringWithFormat:@"<!doctype html>"
                            "<html>"
                            "<head>"
                            "<meta charset=\"utf-8\">"
                            "<style>body{margin:0;padding:0}</style>"
                            "<meta name=\"viewport\" content=\"width=%ld, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\" >"
                            "</head>"
                            "<body>"
                            "<script src=\"%@\"></script>"
                            "</body>"
                            "</html>", (long)adUnit.size.width, bid.displayUrl];
    [_viewController.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"about:blank"]];
}

-     (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    self.isLoaded = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
            [self.delegate interstitialDidLoadAd:self];
        }
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
            [self.delegate interstitial:self
               didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInternalError]];
        }
    });
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
                    [self.delegate interstitial:self
                       didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeNetworkError]];
                }
            });
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);}

@end
