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
#import "CR_Config.h"
#import "Criteo.h"
#import "CR_CdbBid.h"
#import "NSError+CRErrors.h"
#import "CR_CacheAdUnit.h"
#import "CR_AdUnitHelper.h"
#import "CR_TokenValue.h"

@import WebKit;

@interface CRInterstitial() <WKNavigationDelegate, WKUIDelegate>

@end

@implementation CRInterstitial

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController
                   application:(UIApplication *)application
                    isAdLoaded:(BOOL)isAdLoaded
                        adUnit:(CRInterstitialAdUnit *)adUnit{
    if(self = [super init]) {
        _criteo = criteo;
        viewController.webView.navigationDelegate = self;
        viewController.webView.UIDelegate = self;
        _viewController = viewController;
        _application = application;
        _isAdLoaded = isAdLoaded;
        _adUnit = adUnit;
    }
    return self;
}

- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit {
    return [self initWithCriteo:[Criteo sharedCriteo]
                 viewController:[[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                  view:nil
                                                                          interstitial:self]
                    application:[UIApplication sharedApplication]
                     isAdLoaded:NO
                         adUnit:adUnit];
}

- (BOOL)checkSafeToLoad {
    if(self.isAdLoading) {
        // Already loading
        [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest description:@"An Ad is already being loaded."];
        return NO;
    }
    if(self.viewController.presentingViewController) {
        // Already presenting
        [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest description:@"Ad cannot load as another is already being presented."];
        return NO;
    }

    self.isAdLoading = YES;
    self.isAdLoaded = NO;
    self.isResponseValid = NO;
    return YES;
}

- (void)loadAd {
    if(![self checkSafeToLoad]) {
        return;
    }
    CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper interstitialCacheAdUnitForAdUnitId:self.adUnit.adUnitId
                                                                           screenSize:[CR_DeviceInfo getScreenSize]] ;
    CR_CdbBid *bid = [self.criteo getBid:cacheAdUnit];
    if([bid isEmpty]) {
        self.isAdLoading = NO;
        return [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
    }

    if(!bid.displayUrl) return [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:@"No display URL in bid response"];

    [self.viewController initWebViewIfNeeded];
    [self dispatchDidReceiveAdDelegate];
    [self loadWebViewWithDisplayURL:bid.displayUrl];
}

- (void)loadWebViewWithDisplayURL:(NSString *)displayURL {
    CR_Config *config = _criteo.config;

    NSString *viewportWidth = [NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.width];

    NSString *htmlString = [[config.adTagUrlMode stringByReplacingOccurrencesOfString:config.viewportWidthMacro withString:viewportWidth] stringByReplacingOccurrencesOfString:config.displayURLMacro withString:displayURL];

    [self.viewController.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://criteo.com"]];
}

- (void)dispatchDidReceiveAdDelegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitialDidReceiveAd:)]) {
            [self.delegate interstitialDidReceiveAd:self];
        }
    });
}

- (void)loadAdWithBidToken:(CRBidToken *)bidToken {
    if(![self checkSafeToLoad]) {
        return;
    }
    CR_TokenValue *tokenValue = [self.criteo tokenValueForBidToken:bidToken
                                                        adUnitType:CRAdUnitTypeInterstitial];
    if(tokenValue == nil) {
        [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
        self.isAdLoading = NO;
        return;
    }

    if(!tokenValue.displayUrl) return [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:@"No display URL in bid response"];

    [self.viewController initWebViewIfNeeded];
    [self dispatchDidReceiveAdDelegate];
    [self loadWebViewWithDisplayURL:tokenValue.displayUrl];
}

-     (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    self.isAdLoading = NO;
    if(self.isResponseValid) {
        self.isAdLoaded = YES;
        [self safelyNotifyInterstitialCanPresent];
    } else {
        [self safelyNotifyInterstitialCannotPresent:CRErrorCodeNetworkError];
    }
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.viewController.presentingViewController) return [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest description:@"An Ad is already being presented."];

    if (!rootViewController) return [self safelyNotifyAdLoadFail:CRErrorCodeInvalidParameter description:@"rootViewController parameter must not be nil."];

    if(!self.isAdLoaded) return [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest description:@"Interstitial Ad is not loaded."];

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

// When the creative uses window.open(url) to open the URL, this method will be called
- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    [self handlePotentialClickForNavigationAction:navigationAction decisionHandler:nil allowedNavigationType:WKNavigationTypeOther];
    return nil;
}
// When the creative uses <a href="url"> to open the URL, this method will be called
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [self handlePotentialClickForNavigationAction:navigationAction decisionHandler:decisionHandler allowedNavigationType:WKNavigationTypeLinkActivated];
}

- (void)handlePotentialClickForNavigationAction:(WKNavigationAction *)navigationAction
                                decisionHandler:(nullable void (^)(WKNavigationActionPolicy))decisionHandler
                          allowedNavigationType:(WKNavigationType)allowedNavigationType {
    if(navigationAction.navigationType == allowedNavigationType
       && navigationAction.request.URL != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(interstitialWillLeaveApplication:)]) {
                [self.delegate interstitialWillLeaveApplication:self];
            }
            [self.application openURL:navigationAction.request.URL];
            [self.viewController dismissViewController];
        });
        if(decisionHandler) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        return;
    }
    if(decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// Delegate errors that occur during web view navigation
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.isAdLoading = NO;
    [self safelyNotifyInterstitialCannotPresent:CRErrorCodeNetworkError];
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.isAdLoading = NO;
    [self safelyNotifyInterstitialCannotPresent:CRErrorCodeNetworkError];
}

// Delegate HTTP errors
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
        if(httpResponse.statusCode >= 400) {
            self.isResponseValid = NO;
            self.isAdLoading = NO;
        }
        else {
            self.isResponseValid = YES;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)safelyNotifyAdLoadFail:(CRErrorCode)errorCode {
    return [self safelyNotifyAdLoadFail:errorCode description:nil];
}

- (void)safelyNotifyAdLoadFail:(CRErrorCode)errorCode description:(NSString *)description {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitial:didFailToReceiveAdWithError:)]) {
            NSError *error = description
            ? [NSError CRErrors_errorWithCode:errorCode description:description]
            : [NSError CRErrors_errorWithCode:errorCode];

            [self.delegate interstitial:self didFailToReceiveAdWithError:error];
        }
    });
}

- (void)safelyNotifyInterstitialCanPresent {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitialIsReadyToPresent:)]) {
            [self.delegate interstitialIsReadyToPresent:self];
        }
    });
}

- (void)safelyNotifyInterstitialCannotPresent:(CRErrorCode) errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitial:didFailToReceiveAdContentWithError:)]) {
            [self.delegate interstitial:self didFailToReceiveAdContentWithError:[NSError CRErrors_errorWithCode:errorCode]];
        }
    });
}

@end
