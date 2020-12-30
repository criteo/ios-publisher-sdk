//
//  CR_MopubCreativeViewChecker.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CR_MopubCreativeViewChecker.h"
#import "UIView+Testing.h"
#import "CR_ViewCheckingHelper.h"
#import "WKWebView+Testing.h"

@interface CR_MopubCreativeViewChecker ()

@property(strong, nonatomic, readonly) MPInterstitialAdController *interstitialAdController;
@property(strong, nonatomic, readonly) MPAdView *adView;

@end

@implementation CR_MopubCreativeViewChecker

#pragma mark - Lifecycle

- (instancetype)init_ {
  if (self = [super init]) {
    _adCreativeRenderedExpectation =
        [[XCTestExpectation alloc] initWithDescription:@"Expect that Criteo creative appears."];
    _uiWindow = [self createUIWindow];
  }
  return self;
}

- (instancetype)initWithBanner:(MPAdView *)adView {
  if ([self init_]) {
    _adView = adView;
    _adView.delegate = self;
    [self.uiWindow.rootViewController.view addSubview:adView];
  }
  return self;
}

- (instancetype)initWithInterstitial:(MPInterstitialAdController *)interstitialAdController {
  if ([self init_]) {
    _interstitialAdController = interstitialAdController;
    _interstitialAdController.delegate = self;
  }
  return self;
}

- (void)initMopubSdkAndRenderAd:(id)someMopubAd {
  if (![someMopubAd isKindOfClass:MPAdView.class] &&
      ![someMopubAd isKindOfClass:MPInterstitialAdController.class]) {
    NSAssert(
        NO,
        @"MopubCreativeViewChecker can render only Mopub ad, but was provided object with type:%@",
        NSStringFromClass([someMopubAd class]));
    return;
  }
  MPMoPubConfiguration *sdkConfig =
      [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:[someMopubAd adUnitId]];
  MoPub *moPub = [MoPub sharedInstance];
  if (moPub.isSdkInitialized) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [someMopubAd loadAd];
    });
    return;
  }
  [moPub initializeSdkWithConfiguration:sdkConfig
                             completion:^{
                               NSLog(@"Mopub SDK initialization complete");
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 [someMopubAd loadAd];
                               });
                             }];
}

- (void)dealloc {
  _adView.delegate = nil;
  _interstitialAdController.delegate = nil;
}

#pragma mark - Public

- (BOOL)waitAdCreativeRendered {
  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ self.adCreativeRenderedExpectation ]
                                               timeout:30.f];
  return (result == XCTWaiterResultCompleted);
}

#pragma mark - MPAdViewDelegate methods

- (UIViewController *)viewControllerForPresentingModalView {
  return _uiWindow.rootViewController;
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
  NSLog(@"MOPUB SUCCESS: adViewDidLoadAd delegate invoked");
  [self checkViewAndFulfillExpectation];
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
  NSLog(@"MOPUB ERROR: adView:didFailToLoadAdWithError: delegate invoked");
}

#pragma mark - MPInterstitialAdControllerDelegate methods

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
  NSLog(@"MOPUB SUCCESS: interstitialDidLoadAd delegate invoked");
  [interstitial showFromViewController:_uiWindow.rootViewController];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
  NSLog(@"MOPUB ERROR: interstitialDidFailToLoadAd: delegate invoked");
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
  [self checkViewAndFulfillExpectation];
}

#pragma mark - Private methods

- (void)checkViewAndFulfillExpectation {
  __weak typeof(self) weakSelf = self;
  WKWebView *webview = [self.uiWindow testing_findFirstWKWebView];
  [webview testing_evaluateJavaScript:
               @"(function() { return document.getElementsByTagName('html')[0].outerHTML; })();"
      validationHandler:^BOOL(NSString *htmlContent, NSError *error) {
        return [htmlContent containsString:[CR_ViewCheckingHelper preprodCreativeImageUrl]];
      }
      completionHandler:^(BOOL success) {
        if (success) {
          [self.adCreativeRenderedExpectation fulfill];
        }
        weakSelf.uiWindow.hidden = YES;
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
