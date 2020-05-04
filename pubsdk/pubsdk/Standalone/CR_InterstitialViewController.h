//
//  CR_InterstitialViewController.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

@import UIKit;
@import WebKit;

@class CRInterstitial;

NS_ASSUME_NONNULL_BEGIN

@interface CR_InterstitialViewController : UIViewController

@property (nonatomic, strong, nullable) WKWebView *webView;
@property (nonatomic, strong, nullable) UIButton *closeButton;
@property (nonatomic, weak) CRInterstitial *interstitial;

- (instancetype)initWithWebView:(WKWebView *)webView
                           view:(nullable UIView *)view
                   interstitial:(nullable CRInterstitial *)interstitial;
- (void)dismissViewController;
- (void)initWebViewIfNeeded;

@end

NS_ASSUME_NONNULL_END
