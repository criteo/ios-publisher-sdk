//
// Created by Aleksandr Pakhmutov on 17/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "CR_MopubCreativeViewChecker.h"
#import "UIView+Testing.h"
#import "Logging.h"

static NSString *stubCreativeImage = @"https://publisherdirect.criteo.com/publishertag/preprodtest/creative.png";

@implementation CR_MopubCreativeViewChecker

- (instancetype)init_ {
    if (self = [super init]) {
        _adCreativeRenderedExpectation = [[XCTestExpectation alloc] initWithDescription:@"Expect that Criteo creative appears."];
        _uiWindow = [self createUIWindow];
    }
    return self;
}

- (instancetype)initWithBanner:(MPAdView *)adView {
    if ([self init_]) {
        adView.delegate = self;
        adView.frame = CGRectMake(
            self.uiWindow.frame.origin.x, self.uiWindow.frame.origin.y,
            MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height
        );
        [self.uiWindow.rootViewController.view addSubview:adView];
    }
    return self;
}

- (instancetype)initWithInterstitial:(MPInterstitialAdController *)interstitialAdController {
    if ([self init_]) {
        interstitialAdController.delegate = self;
    }
    return self;
}

- (void)initMopubSdkAndRenderAd:(id)someMopubAd {
    if(![someMopubAd isKindOfClass:MPAdView.class] && ![someMopubAd isKindOfClass:MPInterstitialAdController.class]) {
        NSAssert(NO, @"MopubCreativeViewChecker can render only Mopub ad, but was provided object with type:%@", NSStringFromClass([someMopubAd class]));
        return;
    }
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:[someMopubAd adUnitId]];
    MoPub *moPub = [MoPub sharedInstance];
    if(moPub.isSdkInitialized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [someMopubAd loadAd];
        });
        return;
    }
    [moPub initializeSdkWithConfiguration:sdkConfig completion:^{
        CLog(@"Mopub SDK initialization complete");
        dispatch_async(dispatch_get_main_queue(), ^{
            [someMopubAd loadAd];
        });
    }];
}

- (BOOL)waitAdCreativeRendered {
    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    XCTWaiterResult result = [waiter waitForExpectations:@[self.adCreativeRenderedExpectation] timeout:10.f];
    return (result == XCTWaiterResultCompleted);
}

#pragma mark - MPAdViewDelegate methods

- (UIViewController *)viewControllerForPresentingModalView {
    return _uiWindow.rootViewController;
}

- (void)adViewDidLoadAd:(MPAdView *)view {
    NSLog(@"MOPUB SUCCESS: adViewDidLoadAd delegate invoked");
    [self checkViewAndFulfillExpectation];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    CLog(@"MOPUB ERROR: adViewDidFailToLoadAd: delegate invoked");
}

#pragma mark - MPInterstitialAdControllerDelegate methods

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    NSLog(@"MOPUB SUCCESS: interstitialDidLoadAd delegate invoked");
    [interstitial showFromViewController:_uiWindow.rootViewController];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    CLog(@"MOPUB ERROR: interstitialDidFailToLoadAd: delegate invoked");
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    [self checkViewAndFulfillExpectation];
}

#pragma mark - Private methods

- (void)checkViewAndFulfillExpectation {
    WKWebView *firstWebView = [self.uiWindow testing_findFirstWKWebView];
    [firstWebView evaluateJavaScript:@"(function() { return document.getElementsByTagName('html')[0].outerHTML; })();"
                   completionHandler:^(NSString *htmlContent, NSError *err) {
                       if ([htmlContent containsString:stubCreativeImage]) {
                           [self.adCreativeRenderedExpectation fulfill];
                       }
                       self.uiWindow.hidden = YES;
                   }];
}

- (UIWindow *)createUIWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 50, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *viewController = [UIViewController new];
    window.rootViewController = viewController;
    return window;
}

@end
