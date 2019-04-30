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

@import WebKit;

@interface CRInterstitial() <WKNavigationDelegate>

@property (nonatomic, readwrite, getter=isLoaded) BOOL loaded;
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
                 viewController:[[CR_InterstitialViewController alloc]
                                 initWithWebView:[WKWebView new]]
                    application:[UIApplication sharedApplication]];
}

- (void)loadAd:(NSString *)adUnitId {
    self.loaded = NO;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:adUnitId
                                                     size:screenSize];
    CR_CdbBid *bid = [self.criteo getBid:adUnit];
    if([bid isEmpty]) {
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
                            "</html>", (long)screenSize.width, bid.displayUrl];
    [_viewController.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"about:blank"]];
}

-     (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    self.loaded = YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (self.viewController.presentingViewController) {
        // Already presenting
        // TODO: Error handling
        return;
    }

    if (!rootViewController) {
        // No view controller to present from
        // TODO: Error handling
        return;
    }
    [rootViewController presentViewController:self.viewController
                                     animated:YES
                                   completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // cancel webView navigation for clicks on Links from mainFrame and open in browser
    if(navigationAction.navigationType == WKNavigationTypeLinkActivated && [navigationAction.sourceFrame isMainFrame]) {
        if(navigationAction.request.URL != nil) {
            if([self.application canOpenURL:navigationAction.request.URL]) {
                [self.application openURL:navigationAction.request.URL];
                [self.viewController dismissViewController];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    // allow all other navigation Types for webView
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
