//
//  CR_CreativeViewChecker.m
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
#import <WebKit/WebKit.h>
#import <OCMock.h>

#import "CR_CreativeViewChecker.h"
#import "CR_AdUnitHelper.h"
#import "CR_ApiHandler.h"
#import "CR_CacheManager.h"
#import "CR_DependencyProvider.h"
#import "CRInterstitial+Internal.h"
#import "CR_InterstitialViewController.h"
#import "CR_URLOpenerMock.h"
#import "CR_ViewCheckingHelper.h"
#import "Criteo+Internal.h"
#import "CRBannerView+Internal.h"
#import "WkWebView+Testing.h"
#import "UIView+Testing.h"
#import "CR_CdbBidBuilder.h"
#import "OCPartialMockObject.h"

static NSString *appStoreDisplay = @"https://localhost:9099/display/app-store";

@implementation CR_CreativeViewChecker

- (instancetype)initWithCriteo:(Criteo *)criteo {
  if (self = [super init]) {
    [self resetExpectations];
    _uiWindow = [self createUIWindow];
    _criteo = criteo;
    [self resetBannerView];
    _interstitial = [[CRInterstitial alloc] init];
    _interstitial.delegate = self;
    _expectedCreativeUrl = [CR_ViewCheckingHelper preprodCreativeImageUrl];
  }
  return self;
}

- (instancetype)initWithAdUnit:(CRAdUnit *)adUnit criteo:(Criteo *)criteo {
  if (self = [super init]) {
    [self resetExpectations];
    _uiWindow = [self createUIWindow];
    _adUnit = adUnit;
    _criteo = criteo;
    if (self.isBannerAdUnit) {
      [self resetBannerView];
    } else {
      _interstitial = [[CRInterstitial alloc] initWithAdUnit:(CRInterstitialAdUnit *)adUnit
                                                      criteo:criteo];
      _interstitial.delegate = self;
    }
    _expectedCreativeUrl = [CR_ViewCheckingHelper preprodCreativeImageUrl];
  }
  return self;
}

- (void)injectBidWithExpectedCreativeUrl:(NSString *)creativeUrl
               withSkAdNetworkParameters:(BOOL)withSkAdNetworkParameters
                               forAdUnit:(CRAdUnit *)adUnit {
  self.expectedCreativeUrl = creativeUrl;
  CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;

  // Inject bid in cache for cache bidding strategy
  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  CR_CdbBidBuilder *bidBuilder =
      CR_CdbBidBuilder.new.adUnit(cacheAdUnit).cpm(@"15.00").displayUrl(creativeUrl);
  if (withSkAdNetworkParameters) {
    bidBuilder = bidBuilder.skAdNetworkParameters([[CR_SKAdNetworkParameters alloc]
        initWithNetworkId:@"networkId"
                  version:@"2.0"
               campaignId:@1
             iTunesItemId:@2
              sourceAppId:@4
               fidelities:[NSArray new]]);
  }
  CR_CdbBid *bid = bidBuilder.build;
  dependencyProvider.cacheManager.bidCache[cacheAdUnit] = bid;

  // Inject bid in apiHandler response for live bidding strategy
  CR_ApiHandler *apiHandler = dependencyProvider.apiHandler;
  if (apiHandler.isProxy) {
    // Reset the mock if this is not the first time this is called
    OCPartialMockObject *mock = (id)apiHandler;
    apiHandler = (CR_ApiHandler *)mock.realObject;
    [mock stopMocking];
  }
  apiHandler = OCMPartialMock(apiHandler);
  CR_CdbResponse *response = OCMClassMock([CR_CdbResponse class]);
  OCMStub(response.cdbBids).andReturn(@[ bid ]);
  OCMStub([apiHandler cdbResponseWithData:[OCMArg any]]).andReturn(response);
  dependencyProvider.apiHandler = apiHandler;
}

- (void)injectBidWithExpectedCreativeUrl:(NSString *)creativeUrl forAdUnit:(CRAdUnit *)adUnit {
  [self injectBidWithExpectedCreativeUrl:creativeUrl withSkAdNetworkParameters:NO forAdUnit:adUnit];
}

- (void)injectBidWithAppStoreClickUrl:(CRAdUnit *)adUnit {
  [self injectBidWithExpectedCreativeUrl:appStoreDisplay
               withSkAdNetworkParameters:YES
                               forAdUnit:adUnit];
}

- (void)dealloc {
  _bannerView.delegate = nil;
}

#pragma mark - CRBannerViewDelegate methods

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"%@", error.localizedDescription);
  [self.failToReceiveAdExpectation fulfill];
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
  NSLog(@"[CR_CreativeViewChecker] bannerWillLeaveApplication");
}

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
  [self.didReceiveAdExpectation fulfill];
  [self checkViewAndFulfillExpectation];
}

#pragma mark - CRInterstitialDelegate

- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial {
  [self.didReceiveAdExpectation fulfill];
  [self checkViewAndFulfillExpectation:self.interstitial.viewController.webView];
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"%@", error.localizedDescription);
  [self.failToReceiveAdExpectation fulfill];
  [self checkViewAndFulfillExpectation:self.interstitial.viewController.webView];
}

#pragma mark - Private

- (BOOL)isBannerAdUnit {
  return [_adUnit isKindOfClass:CRBannerAdUnit.class];
}

- (void)resetExpectations {
  _didReceiveAdExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"Expect that CRBannerView will get a bid"];
  _failToReceiveAdExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"Expect that CRBannerView will fail to get a bid"];
  _adCreativeRenderedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"Expect that Criteo creative appears."];
}

- (void)resetBannerView {
  [_bannerView removeFromSuperview];
  // NOTE: bannerView was created with frame (0; 50; w; h) because with (0; 0; ...) banner is
  // displayed wrong.
  // TODO: Find a way to render banner with (0;0; ...).
  if (self.adUnit == nil) {
    _bannerView = [[CRBannerView alloc] init];
  } else {
    NSAssert(self.isBannerAdUnit, @"This can be called only when testing banners");
    CRBannerAdUnit *adUnit = (CRBannerAdUnit *)self.adUnit;
    CGSize size = adUnit.size;
    _bannerView = [[CRBannerView alloc]
        initWithFrame:CGRectMake(.0, 50.0, size.width, size.height)
               criteo:self.criteo
              webView:[[WKWebView alloc] initWithFrame:CGRectMake(.0, .0, size.width, size.height)]
               adUnit:adUnit
            urlOpener:[[CR_URLOpener alloc] init]];
  }
  _bannerView.delegate = self;
  _bannerView.backgroundColor = UIColor.orangeColor;
  [_uiWindow.rootViewController.view addSubview:_bannerView];
}

- (UIWindow *)createUIWindow {
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 50, 320, 480)];
  [window makeKeyAndVisible];
  UIViewController *viewController = [UIViewController new];
  window.rootViewController = viewController;
  return window;
}

- (void)checkViewAndFulfillExpectation:(WKWebView *)webview {
  __weak typeof(self) weakSelf = self;
  [webview testing_evaluateJavaScript:
               @"(function() { return document.getElementsByTagName('html')[0].outerHTML; })();"
      validationHandler:^BOOL(NSString *htmlContent, NSError *error) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
          return NO;
        }
        return [htmlContent containsString:strongSelf.expectedCreativeUrl];
      }
      completionHandler:^(BOOL success) {
        if (success) {
          [weakSelf.adCreativeRenderedExpectation fulfill];
        }
        weakSelf.uiWindow.hidden = YES;
      }];
}

- (void)checkViewAndFulfillExpectation {
  WKWebView *webview = [self.uiWindow testing_findFirstWKWebView];
  [self checkViewAndFulfillExpectation:webview];
}

- (void)clickUrl:(WKWebView *)webview {
  [self.uiWindow makeKeyAndVisible];

  [webview testing_evaluateJavaScript:@"(function() {\n"
                                       "  var elements = document.getElementsByTagName('a');\n"
                                       "  if (elements.length != 1) {\n"
                                       "    return false;\n"
                                       "  }\n"
                                       "  elements[0].click();\n"
                                       "  return true;\n"
                                       "})();"
                    validationHandler:^BOOL(NSString *htmlContent, NSError *error) {
                      return YES;
                    }
                    completionHandler:^(BOOL success){
                    }];
}

- (void)clickUrl {
  WKWebView *webview = [self.uiWindow testing_findFirstWKWebView];
  [self clickUrl:webview];
}

@end
