//
//  CR_InterstitialViewController.m
//  pubsdk
//
//  Created by Julien Stoeffler on 4/24/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_InterstitialViewController.h"

@interface CR_InterstitialViewController ()

@end

@implementation CR_InterstitialViewController

- (instancetype)initWithWebView:(WKWebView *)webView {
    if(self = [super init]) {
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.scrollView.scrollEnabled = false;
        webView.frame = [UIScreen mainScreen].bounds;

        _webView = webView;
    }
    return self;
}

- (void)viewDidLoad {
    [self.view addSubview:_webView];
    _webView.frame = self.view.bounds;
}

@end
