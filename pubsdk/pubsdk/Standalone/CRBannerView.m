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

//TODO check import strategy
@import WebKit;


@interface CRBannerView() <WKNavigationDelegate>
@property (nonatomic, strong) Criteo *criteo;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) UIApplication *application;
@end

@implementation CRBannerView


- (instancetype)initWithFrame:(CGRect)rect {
    return [self initWithFrame:rect
                        criteo:[Criteo sharedCriteo]
                       webView:[[WKWebView alloc] initWithFrame:CGRectMake(.0, .0,rect.size.width, rect.size.height)]
                   application:[UIApplication sharedApplication]];
}

- (instancetype)initWithFrame:(CGRect)rect
                       criteo:(Criteo *)criteo
                      webView:(WKWebView *)webView
                  application:(UIApplication *)application {
    if(self = [super initWithFrame:rect]) {
        _criteo = criteo;
        _webView = webView;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scrollView.scrollEnabled = false;
        _webView.navigationDelegate = self;
        [self addSubview:webView];
        _application = application;
    }
    return self;
}

- (void)loadAd:(NSString *)adUnitId {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:adUnitId
                                                     size:self.frame.size];
    CR_CdbBid *bid = [self.criteo getBid:adUnit];
    if([bid isEmpty]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(banner:didFailToLoadAdWithError:)]) {
                 [self.delegate banner:self
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
                            "</html>", (long)self.frame.size.width , bid.displayUrl];
    [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"about:blank"]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(bannerDidLoad:)]) {
            [self.delegate bannerDidLoad:self];
        }
    });
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(navigationAction.navigationType == WKNavigationTypeLinkActivated && [navigationAction.sourceFrame isMainFrame]) {
        if(navigationAction.request.URL != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(bannerWillLeaveApplication:)]) {
                    [self.delegate bannerWillLeaveApplication:self];
                }
                [self.application openURL:navigationAction.request.URL];
            });
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// Delegate errors that occur during web view navigation
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(banner:didFailToLoadAdWithError:)]) {
            [self.delegate banner:self
                               didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInternalError]];
        }
    });
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(banner:didFailToLoadAdWithError:)]) {
            [self.delegate banner:self
                               didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeInternalError]];
        };
    });
}

// Delegate HTTP errors
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
        if(httpResponse.statusCode >= 400) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(banner:didFailToLoadAdWithError:)]) {
                    [self.delegate banner:self
                                       didFailToLoadAdWithError:[NSError CRErrors_errorWithCode:CRErrorCodeNetworkError]];
                }
            });
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

@end
