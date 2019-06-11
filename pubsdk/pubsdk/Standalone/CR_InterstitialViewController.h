//
//  CR_InterstitialViewController.h
//  pubsdk
//
//  Created by Julien Stoeffler on 4/24/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRInterstitial.h"
@import WebKit;

NS_ASSUME_NONNULL_BEGIN

@interface CR_InterstitialViewController : UIViewController

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, weak) CRInterstitial *interstitial;

- (instancetype)initWithWebView:(WKWebView *)webView
                           view:(UIView *)view
                   interstitial:(CRInterstitial *)interstitial;
- (void)dismissViewController;

@end

NS_ASSUME_NONNULL_END
