//
//  CRInterstitialTests.m
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
#import <OCMock.h>
#import "CR_BidManager.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRInterstitialAdUnit.h"
#import "CR_CacheAdUnit.h"
#import "CRInterstitial.h"
#import "CRInterstitial+Internal.h"
#import "MockWKWebView.h"
#import "CR_InterstitialViewController.h"
#import "CR_AdUnitHelper.h"
#import "CR_DependencyProvider.h"
#import "CR_NetworkCaptor.h"
#import "CR_URLOpenerMock.h"
#import "Criteo+Testing.h"
#import "XCTestCase+Criteo.h"
#import "CR_Timer.h"
#import "NSURL+Criteo.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_DisplaySizeInjector.h"
#import "CR_IntegrationRegistry.h"
#import "CR_CdbBidBuilder.h"

@interface CRInterstitialTests : XCTestCase

@property(nonatomic, strong) CR_CacheAdUnit *expectedCacheAdUnit;
@property(nonatomic, strong) CRInterstitialAdUnit *adUnit;
@property(nonatomic, strong) Criteo *criteo;
@property(nonatomic, strong) CR_URLOpenerMock *urlOpener;
@property(nonatomic, strong) CR_DisplaySizeInjector *displaySizeInjector;
@property(nonatomic, strong) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CRInterstitialTests

- (void)setUp {
  self.expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                 size:CGSizeMake(320.0, 480.0)
                                                           adUnitType:CRAdUnitTypeInterstitial];
  self.adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"123"];

  self.urlOpener = CR_URLOpenerMock.new;

  self.displaySizeInjector = OCMClassMock([CR_DisplaySizeInjector class]);

  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
  dependencyProvider.displaySizeInjector = self.displaySizeInjector;
  self.integrationRegistry = dependencyProvider.integrationRegistry;

  self.criteo = OCMPartialMock([Criteo.alloc initWithDependencyProvider:dependencyProvider]);
}

- (void)testInterstitialLoadWithDataSuccess {
  WKWebView *mockWebView = OCMPartialMock([WKWebView new]);
  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
                           return [html containsString:@"<script src=\"test?safearea\"></script>"];
                         }]
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  [self prepareMockedDeviceInfo];

  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:@"test"])
      .andReturn(@"test?safearea");

  CRInterstitial *interstitial = [self interstitialWithWebView:mockWebView];
  [interstitial loadAdWithDisplayData:@"test"];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
}

- (void)testInterstitialLoadBidSuccess {
  WKWebView *mockWebView = OCMPartialMock([WKWebView new]);
  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
                           return [html containsString:@"<script src=\"test?safearea\"></script>"];
                         }]
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  [self prepareMockedDeviceInfo];

  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:[OCMArg any]])
      .andReturn(@"test?safearea");

  CR_InterstitialViewController *controller =
      [[CR_InterstitialViewController alloc] initWithWebView:mockWebView view:nil interstitial:nil];
  CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:self.criteo
                                                         viewController:controller
                                                             isAdLoaded:NO
                                                                 adUnit:nil
                                                              urlOpener:self.urlOpener];

  CR_CdbBid *cdbBid = CR_CdbBidBuilder.new.build;
  CRBid *bid = [[CRBid alloc] initWithCdbBid:cdbBid adUnit:self.adUnit];
  [interstitial loadAdWithBid:bid];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
}

- (void)testInterstitialLoadSuccess {
  WKWebView *mockWebView = OCMPartialMock([WKWebView new]);
  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
                           return [html containsString:@"<script src=\"test?safearea\"></script>"];
                         }]
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  [self prepareMockedDeviceInfo];

  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:@"test"])
      .andReturn(@"test?safearea");

  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:[self bidWithDisplayURL:@"test"]];

  CRInterstitial *interstitial = [self interstitialWithWebView:mockWebView];
  [interstitial loadAd];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

- (void)testTemplatingFromConfig {
  CR_Config *config = [CR_Config new];
  config.adTagUrlMode = @"Good Morning, my width is #WEEDTH# and my URL is ˆURLˆ";
  config.viewportWidthMacro = @"#WEEDTH#";
  config.displayURLMacro = @"ˆURLˆ";
  self.criteo.dependencyProvider.config = config;

  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:@"whatDoYouMean"])
      .andReturn(@"myUrl");

  WKWebView *mockWebView = OCMPartialMock([WKWebView new]);
  NSString *expectedHtml =
      [NSString stringWithFormat:@"Good Morning, my width is %ld and my URL is myUrl",
                                 (long)[UIScreen mainScreen].bounds.size.width];

  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:expectedHtml
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit
                  respondBid:[self bidWithDisplayURL:@"whatDoYouMean"]];

  CRInterstitial *interstitial = [self interstitialWithWebView:mockWebView];
  [interstitial loadAd];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
}

- (void)testWebViewAddedToViewHierarchy {
  MockWKWebView *mockWebView = [MockWKWebView new];

  UIViewController *vc = OCMStrictClassMock([UIViewController class]);
  OCMStub([vc presentViewController:OCMArg.any animated:YES completion:[OCMArg isNotNil]]);

  CR_InterstitialViewController *interstitialVC =
      [[CR_InterstitialViewController alloc] initWithWebView:mockWebView view:nil interstitial:nil];
  CRInterstitial *interstitial = [self interstitialWithController:interstitialVC];
  interstitial.isAdLoaded = YES;
  [interstitial presentFromRootViewController:vc];

  OCMVerify([vc presentViewController:[OCMArg checkWithBlock:^(id value) {
                  [(UIViewController *)value viewDidAppear:YES];
                  XCTAssertEqual(mockWebView.superview, interstitialVC.view);
                  return YES;
                }]
                             animated:YES
                           completion:[OCMArg isNotNil]]);
}

- (void)testWithRendering {
  WKWebView *realWebView = [WKWebView new];

  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:@"test"])
      .andReturn(@"test?safearea");
  CR_CdbBid *bid = [self bidWithDisplayURL:@"test"];

  [self prepareMockedDeviceInfo];

  XCTestExpectation __block *marginExpectation =
      [self expectationWithDescription:@"WebView body has 0px margin"];
  XCTestExpectation __block *paddingExpectation =
      [self expectationWithDescription:@"WebView body has 0px padding"];
  XCTestExpectation __block *viewportExpectation =
      [self expectationWithDescription:@"WebView body has 0px margin"];

  void (^javascriptChecks)(NSTimer *) = ^(NSTimer *_Nonnull timer) {
    [realWebView
        evaluateJavaScript:
            @"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin')"
         completionHandler:^(id _Nullable result, NSError *_Nullable error) {
           XCTAssertNil(error);
           XCTAssertEqualObjects(@"0px", (NSString *)result);
           [marginExpectation fulfill];
         }];
    [realWebView
        evaluateJavaScript:
            @"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('padding')"
         completionHandler:^(id _Nullable result, NSError *_Nullable error) {
           XCTAssertNil(error);
           XCTAssertEqualObjects(@"0px", (NSString *)result);
           [paddingExpectation fulfill];
         }];
    [realWebView
        evaluateJavaScript:@"document.querySelector('meta[name=viewport]').getAttribute('content')"
         completionHandler:^(id _Nullable result, NSError *_Nullable error) {
           XCTAssertNil(error);
           CGFloat width = [UIScreen mainScreen].bounds.size.width;
           NSString *searchString = [NSString stringWithFormat:@"width=%tu", (NSUInteger)width];
           XCTAssertTrue([(NSString *)result containsString:searchString]);
           [viewportExpectation fulfill];
         }];
  };
  [CR_Timer scheduledTimerWithTimeInterval:2 repeats:NO block:javascriptChecks];

  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:bid];

  CRInterstitial *interstitial = [self interstitialWithWebView:realWebView];
  [interstitial loadAd];

  OCMVerify([self.criteo loadCdbBidForAdUnit:[self expectedCacheAdUnit]
                             responseHandler:OCMArg.any]);

  [self cr_waitForExpectations:@[ marginExpectation, paddingExpectation, viewportExpectation ]];
}

- (void)testInterstitialFail {
  WKWebView *realWebView = [WKWebView new];
  CR_InterstitialViewController *interstitialVC =
      OCMStrictClassMock([CR_InterstitialViewController class]);
  OCMStub([interstitialVC webView]).andReturn(realWebView);

  [self prepareMockedDeviceInfo];

  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:nil];
  OCMStub([interstitialVC presentingViewController]).andReturn(nil);

  CRInterstitial *interstitial = [self interstitialWithController:interstitialVC];
  [interstitial loadAd];

  OCMVerify([self.criteo loadCdbBidForAdUnit:[self expectedCacheAdUnit]
                             responseHandler:[OCMArg any]]);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

// TODO: UITests for "click" on a "real" webview with a real link
- (void)testAllowNavigationActionPolicyForWebView {
  /* Allow navigation Types other than Links from Mainframes in WebView.
   eg: Clicking images inside <a> tag generates WKNavigationTypeOther
  */
  WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeOther);

  WKWebView *realWebView = [WKWebView new];
  CRInterstitial *interstitial = [self interstitialWithWebView:realWebView];

  [interstitial webView:realWebView
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
                        XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
                      }];

  mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
  WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
  OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
  OCMStub([mockFrame isMainFrame]).andReturn(NO);
  NSURLRequest *request = [[NSURLRequest alloc] init];
  OCMStub(mockNavigationAction.request).andReturn(request);
  [interstitial webView:realWebView
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
                        XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
                      }];
}

- (void)testCancelNavigationActionPolicyForWebView {
  // cancel webView navigation for clicks on Links from mainFrame and open in browser
  WKWebView *realWebView = [WKWebView new];

  WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
  WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
  OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
  OCMStub([mockFrame isMainFrame]).andReturn(YES);
  NSURL *url = [[NSURL alloc] initWithString:@"123"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  OCMStub(mockNavigationAction.request).andReturn(request);

  XCTestExpectation *openInBrowserExpectation =
      [self expectationWithDescription:@"URL opened in browser expectation"];

  CRInterstitial *interstitial = [self interstitialWithWebView:realWebView];
  [interstitial webView:realWebView
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
                        XCTAssertEqual(actionPolicy, WKNavigationActionPolicyCancel);
                      }];

  dispatch_async(dispatch_get_main_queue(), ^{
    XCTAssertEqual(self.urlOpener.openExternalURLCount, 1);
    [openInBrowserExpectation fulfill];
  });

  [self cr_waitShortlyForExpectations:@[ openInBrowserExpectation ]];
}

// Test window.open navigation delegate
// TODO: UITests for "window.open" in a "real" webview
- (void)testCreateWebViewWithConfiguration {
  WKWebView *realWebView = [WKWebView new];

  WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeOther);
  WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
  OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
  OCMStub([mockFrame isMainFrame]).andReturn(YES);
  NSURL *url = [[NSURL alloc] initWithString:@"123"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  OCMStub(mockNavigationAction.request).andReturn(request);

  XCTestExpectation *openInBrowserExpectation =
      [self expectationWithDescription:@"URL opened in browser expectation"];

  CRInterstitial *interstitial = [self interstitialWithWebView:realWebView];
  [interstitial webView:realWebView
      createWebViewWithConfiguration:nil
                 forNavigationAction:mockNavigationAction
                      windowFeatures:nil];

  dispatch_async(dispatch_get_main_queue(), ^{
    XCTAssertEqual(self.urlOpener.openExternalURLCount, 1);
    [openInBrowserExpectation fulfill];
  });

  [self cr_waitShortlyForExpectations:@[ openInBrowserExpectation ]];
}

// Android:  whenLoadingAnInterstitial_GivenInitializedSdk_ShouldSetInterstitialFlagInTheRequest
- (void)testLoadingInterstitialShouldSetInterstitialFlagInTheRequest {
  [self.criteo testing_registerInterstitialAndWaitForHTTPResponses];
  XCTestExpectation *interstitialHttpCallExpectation =
      [self expectationWithDescription:@"interstitialHttpCallExpectation"];
  self.criteo.testing_networkCaptor.requestListener =
      ^(NSURL *_Nonnull url, CR_HTTPVerb verb, NSDictionary *body) {
        const BOOL isBidURL = [url.absoluteString containsString:self.criteo.config.cdbUrl];
        const BOOL isInterstitialPresent = [body[@"slots"][0][@"interstitial"] boolValue];
        if (isBidURL && isInterstitialPresent) {
          [interstitialHttpCallExpectation fulfill];
        }
      };

  MockWKWebView *mockWebView = [[MockWKWebView alloc] init];

  CRInterstitial *interstitial = [self interstitialWithWebView:mockWebView];
  [interstitial loadAd];

  [self cr_waitForExpectations:@[ interstitialHttpCallExpectation ]];
}

- (void)prepareMockedDeviceInfo {
  id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
  OCMStub([deviceInfoClassMock screenSize]).andReturn(CGSizeMake(320, 480));
  self.criteo.dependencyProvider.deviceInfo = deviceInfoClassMock;
}

- (CR_CdbBid *)bidWithDisplayURL:(NSString *)displayURL {
  return [[CR_CdbBid alloc] initWithZoneId:@123
                               placementId:@"placementId"
                                       cpm:@"4.2"
                                  currency:@"₹😀"
                                     width:@47.0f
                                    height:@57.0f
                                       ttl:26
                                  creative:@"THIS IS USELESS LEGACY"
                                displayUrl:displayURL
                                insertTime:[NSDate date]
                              nativeAssets:nil
                              impressionId:nil];
}

- (CRInterstitial *)interstitialWithController:(CR_InterstitialViewController *)controller {
  return [[CRInterstitial alloc] initWithCriteo:self.criteo
                                 viewController:controller
                                     isAdLoaded:NO
                                         adUnit:self.adUnit
                                      urlOpener:self.urlOpener];
}

- (CRInterstitial *)interstitialWithWebView:(WKWebView *)webView {
  CR_InterstitialViewController *interstitialVC =
      [[CR_InterstitialViewController alloc] initWithWebView:webView view:nil interstitial:nil];
  return [self interstitialWithController:interstitialVC];
}

- (void)mockCriteoWithAdUnit:(CR_CacheAdUnit *)adUnit respondBid:(CR_CdbBid *)bid {
  OCMStub([self.criteo loadCdbBidForAdUnit:adUnit responseHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        CR_CdbBidResponseHandler handler;
        [invocation getArgument:&handler atIndex:3];
        handler(bid);
      });
}

@end
