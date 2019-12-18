//
// Created by Aleksandr Pakhmutov on 10/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_DfpCreativeViewChecker.h"
#import "UIView+Testing.h"
#import "UIWebView+Testing.h"
#import "Logging.h"

static NSString *stubCreativeImage = @"https://publisherdirect.criteo.com/publishertag/preprodtest/creative.png";

@implementation CR_DfpCreativeViewChecker

-(instancetype)init_ {
    if (self = [super init]) {
        _adCreativeRenderedExpectation = [[XCTestExpectation alloc] initWithDescription:@"Expect that Criteo creative appears."];
        _uiWindow = [self createUIWindow];
    }
    return self;
}

-(instancetype)initWithBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId {
    if ([self init_]) {
        _dfpBannerView = [self createDfpBannerWithSize:size withAdUnitId:adUnitId];
        _dfpBannerView.delegate = self;
        _dfpBannerView.rootViewController = _uiWindow.rootViewController;
        [self.uiWindow.rootViewController.view addSubview:_dfpBannerView];
    }
    return self;
}

-(instancetype)initWithInterstitial:(DFPInterstitial *)dfpInterstitial {
    if ([self init_]) {
        dfpInterstitial.delegate = self;
    }
    return self;
}

-(BOOL)waitAdCreativeRendered {
    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    XCTWaiterResult result = [waiter waitForExpectations:@[self.adCreativeRenderedExpectation] timeout:10.f];
    return (result == XCTWaiterResultCompleted);
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [self checkViewAndFulfillExpectation];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    CLog(@"[ERROR] CR_DfpBannerViewChecker.GADBannerViewDelegate (didFailToReceiveAdWithError) %@", error.description);
}

#pragma mark - GADInterstitialDelegate methods

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [ad presentFromRootViewController:self.uiWindow.rootViewController];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [NSTimer scheduledTimerWithTimeInterval:1
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [self checkViewAndFulfillExpectation];
                                      }];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    CLog(@"[ERROR] CR_DfpBannerViewChecker.GADInterstitialDelegate (didFailToReceiveAdWithError) %@", error.description);
}

#pragma mark - Private methods

- (void)checkViewAndFulfillExpectation {
    UIWebView *firstWebView = [self.uiWindow testing_findFirstWebView];
    NSString *htmlContent = [firstWebView testing_getHtmlContent];
    if ([htmlContent containsString:stubCreativeImage]) {
        [self.adCreativeRenderedExpectation fulfill];
    }
}

- (UIWindow *)createUIWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 50, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *viewController = [UIViewController new];
    window.rootViewController = viewController;
    return window;
}

-(DFPBannerView *)createDfpBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId {
    DFPBannerView *dfpBannerView = [[DFPBannerView alloc] initWithAdSize:size];
    dfpBannerView.adUnitID = adUnitId;
    dfpBannerView.backgroundColor = [UIColor orangeColor];
    return dfpBannerView;
}

@end