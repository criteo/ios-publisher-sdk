//
//  CR_DfpCreativeViewChecker.m
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

#import <XCTest/XCTest.h>
#import "CR_DfpCreativeViewChecker.h"
#import "UIView+Testing.h"
#import "WKWebView+Testing.h"
#import "CR_Timer.h"
#import "CR_ViewCheckingHelper.h"
#import "Criteo+Testing.h"
#import "CR_TestAdUnits.h"

@interface CR_DfpCreativeViewChecker ()

@property(strong, nonatomic) NSString *expectedCreative;

@end

@implementation CR_DfpCreativeViewChecker

#pragma mark - Lifecycle

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
  if (self = [super init]) {
    _adCreativeRenderedExpectation =
        [[XCTestExpectation alloc] initWithDescription:@"Expect that Criteo creative appears."];
    _uiWindow = [self createUIWindow];
    _expectedCreative = adUnitId == [CR_TestAdUnits dfpNativeId]
                            ? [CR_ViewCheckingHelper preprodCreativeImageUrlForNative]
                            : [CR_ViewCheckingHelper preprodCreativeImageUrl];
  }
  return self;
}

- (instancetype)initWithBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId {
  if ([self initWithAdUnitId:adUnitId]) {
    _dfpBannerView = [self createDfpBannerWithSize:size withAdUnitId:adUnitId];
    _dfpBannerView.delegate = self;
    _dfpBannerView.rootViewController = _uiWindow.rootViewController;
    [self.uiWindow.rootViewController.view addSubview:_dfpBannerView];
  }
  return self;
}

- (instancetype)initWithInterstitial:(DFPInterstitial *)dfpInterstitial {
  if ([self initWithAdUnitId:dfpInterstitial.adUnitID]) {
    _dfpInterstitial = dfpInterstitial;
    _dfpInterstitial.delegate = self;
  }
  return self;
}

- (void)dealloc {
  _dfpBannerView.delegate = nil;
  _dfpInterstitial.delegate = nil;
}

#pragma mark - Public

- (BOOL)waitAdCreativeRendered {
  return [self waitAdCreativeRenderedWithTimeout:10.];
}

- (BOOL)waitAdCreativeRenderedWithTimeout:(NSTimeInterval)timeout {
  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ self.adCreativeRenderedExpectation ]
                                               timeout:timeout];
  return (result == XCTWaiterResultCompleted);
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  [self checkViewAndFulfillExpectation];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"[ERROR] CR_DfpBannerViewChecker.GADBannerViewDelegate (didFailToReceiveAdWithError) %@",
        error.description);
}

#pragma mark - GADInterstitialDelegate methods

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  [ad presentFromRootViewController:self.uiWindow.rootViewController];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
  [CR_Timer scheduledTimerWithTimeInterval:1
                                   repeats:NO
                                     block:^(NSTimer *_Nonnull timer) {
                                       [self checkViewAndFulfillExpectation];
                                     }];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"[ERROR] CR_DfpBannerViewChecker.GADInterstitialDelegate (didFailToReceiveAdWithError) %@",
        error.description);
}

#pragma mark - Private methods

- (void)checkViewAndFulfillExpectation {
  NSLog(@"EXP CR : %@", self.expectedCreative);
  self.uiWindow.hidden = YES;
  WKWebView *webview = [self.uiWindow testing_findFirstWKWebView];
  [webview testing_evaluateJavaScript:
               @"(function() { return document.getElementsByTagName('html')[0].outerHTML; })();"
      validationHandler:^BOOL(NSString *htmlContent, NSError *error) {
        NSLog(@"Checking if contains [%@]", self.expectedCreative);
        return [htmlContent containsString:self.expectedCreative];
      }
      completionHandler:^(BOOL success) {
        if (success) {
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

- (DFPBannerView *)createDfpBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId {
  DFPBannerView *dfpBannerView = [[DFPBannerView alloc] initWithAdSize:size];
  dfpBannerView.adUnitID = adUnitId;
  dfpBannerView.backgroundColor = [UIColor orangeColor];
  return dfpBannerView;
}

@end
