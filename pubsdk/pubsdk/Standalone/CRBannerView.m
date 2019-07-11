//
//  CRBannerView.m
//  pubsdk
//
//  Created by Julien Stoeffler on 4/3/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRBannerView.h"
#import "Criteo.h"
#import "CR_CdbBid.h"
#import "Criteo+Internal.h"
#import "CR_BidManager.h"
#import "NSError+CRErrors.h"
#import "CR_TokenValue.h"

//TODO check import strategy
@import WebKit;


@interface CRBannerView() <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic) BOOL isResponseValid;
@property (nonatomic, strong) Criteo *criteo;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) UIApplication *application;
@property (nonatomic, readonly) CRBannerAdUnit *adUnit;
@end

@implementation CRBannerView

- (instancetype)initWithAdUnit:(CRBannerAdUnit *)adUnit {
    return [self initWithFrame:CGRectMake(.0, .0, adUnit.size.width, adUnit.size.height)
                        criteo:[Criteo sharedCriteo]
                       webView:[[WKWebView alloc] initWithFrame:CGRectMake(.0, .0,adUnit.size.width, adUnit.size.height)]
                   application:[UIApplication sharedApplication]
                        adUnit:adUnit];
}

- (instancetype)initWithFrame:(CGRect)rect
                       criteo:(Criteo *)criteo
                      webView:(WKWebView *)webView
                  application:(UIApplication *)application
                       adUnit:(CRBannerAdUnit *)adUnit {
    if(self = [super initWithFrame:rect]) {
        _criteo = criteo;
        _webView = webView;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scrollView.scrollEnabled = false;
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [self addSubview:webView];
        _application = application;
        _adUnit = adUnit;
    }
    return self;
}

- (void)loadWebViewWithDisplayUrl:(NSString *)displayUrl {
    // Will crash the app if nil is passed to stringByReplacingOccurrencesOfString
    if(!displayUrl) return [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:@"No display URL in bid response"];

    CR_Config *config = _criteo.config;

    NSString *viewportWidth = [NSString stringWithFormat:@"%ld", (long)self.frame.size.width];

    NSString *htmlString = [[config.adTagUrlMode stringByReplacingOccurrencesOfString:config.viewportWidthMacro withString:viewportWidth] stringByReplacingOccurrencesOfString:config.displayURLMacro withString:displayUrl];

    [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"about:blank"]];
}

- (void)loadAd {
    self.isResponseValid = NO;
    CR_CacheAdUnit *cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:_adUnit.adUnitId
                                                                      size:self.frame.size];
    CR_CdbBid *bid = [self.criteo getBid:cacheAdUnit];

    if([bid isEmpty]) return [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];

    [self loadWebViewWithDisplayUrl:bid.displayUrl];
}

- (void)loadAdWithBidToken:(CRBidToken *)bidToken {
    self.isResponseValid = NO;
    CR_TokenValue *tokenValue = [self.criteo tokenValueForBidToken:bidToken
                                                        adUnitType:CRAdUnitTypeBanner];

    if (!tokenValue) return [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];

    [self loadWebViewWithDisplayUrl:tokenValue.displayUrl];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if(!self.isResponseValid) return [self safelyNotifyAdLoadFail:CRErrorCodeNetworkError];

    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(bannerDidLoad:)]) {
            [self.delegate bannerDidLoad:self];
        }
    });
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
                     if([self.delegate respondsToSelector:@selector(bannerWillLeaveApplication:)]) {
                         [self.delegate bannerWillLeaveApplication:self];
                     }
                     [self.application openURL:navigationAction.request.URL];
                 });
                 if(decisionHandler){
                     decisionHandler(WKNavigationActionPolicyCancel);
                 }
                 return;
             }
    if(decisionHandler){
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// Delegate errors that occur during web view navigation
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self safelyNotifyAdLoadFail:CRErrorCodeInternalError];
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self safelyNotifyAdLoadFail:CRErrorCodeInternalError];
}

// Delegate HTTP errors
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
        if(httpResponse.statusCode >= 400) {
            self.isResponseValid = NO;
            [self safelyNotifyAdLoadFail:CRErrorCodeNetworkError];
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
        if([self.delegate respondsToSelector:@selector(banner:didFailToLoadAdWithError:)]) {
            NSError *error = description
            ? [NSError CRErrors_errorWithCode:errorCode description:description]
            : [NSError CRErrors_errorWithCode:errorCode];

            [self.delegate banner:self didFailToLoadAdWithError:error];
        }
    });
}

@end
