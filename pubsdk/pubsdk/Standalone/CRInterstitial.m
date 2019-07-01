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
                                                                           screenSize:[[CR_DeviceInfo new] screenSize]] ;
    CR_CdbBid *bid = [self.criteo getBid:cacheAdUnit];
    if([bid isEmpty]) {
        self.isAdLoading = NO;
        return [self safelyNotifyAdLoadFail:CRErrorCodeNoFill description:nil];
    }
    [self.viewController initWebViewIfNeeded];
    [self loadWebViewWithDisplayURL:bid.displayUrl];
}

- (void)loadWebViewWithDisplayURL:(NSString *)displayURL {
    // Will crash the app if nil is passed to stringByReplacingOccurrencesOfString
    if(!displayURL) return [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:@"No display URL in bid response"];

    CR_Config *config = [_criteo getConfig];

    NSString *viewportWidth = [NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.width];

    NSString *htmlString = [[config.adTagUrlMode stringByReplacingOccurrencesOfString:config.viewportWidthMacro withString:viewportWidth] stringByReplacingOccurrencesOfString:config.displayURLMacro withString:displayURL];

    [self.viewController.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"about:blank"]];
}


- (void)loadAdWithBidToken:(CRBidToken *)bidToken {
    if(![self checkSafeToLoad]) {
        return;
    }
    CR_TokenValue *tokenValue = [self.criteo tokenValueForBidToken:bidToken
                                                        adUnitType:CRAdUnitTypeInterstitial];
    if(tokenValue == nil) {
        [self safelyNotifyAdLoadFail:CRErrorCodeNoFill description:nil];
        self.isAdLoading = NO;
        return;
    }
    [self.viewController initWebViewIfNeeded];
    [self loadWebViewWithDisplayURL:tokenValue.displayUrl];
}

-     (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    self.isAdLoading = NO;
    if(!self.isResponseValid) return [self safelyNotifyAdLoadFail:CRErrorCodeNetworkError description:nil];

    self.isAdLoaded = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
            [self.delegate interstitialDidLoadAd:self];
        }
    });
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
       && navigationAction.sourceFrame.isMainFrame
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
    [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:nil];
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.isAdLoading = NO;
    [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:nil];
}

// Delegate HTTP errors
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
        if(httpResponse.statusCode >= 400) {
            self.isResponseValid = NO;
            self.isAdLoading = NO;
            [self safelyNotifyAdLoadFail:CRErrorCodeNetworkError description:nil];
        }
        else {
            self.isResponseValid = YES;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)safelyNotifyAdLoadFail:(CRErrorCode)errorCode description:(NSString *)optionalDescription {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(interstitial:didFailToLoadAdWithError:)]) {
            NSError *error = optionalDescription
            ? [NSError CRErrors_errorWithCode:errorCode description:optionalDescription]
            : [NSError CRErrors_errorWithCode:errorCode];

            [self.delegate interstitial:self didFailToLoadAdWithError:error];
        }
    });
}

@end
