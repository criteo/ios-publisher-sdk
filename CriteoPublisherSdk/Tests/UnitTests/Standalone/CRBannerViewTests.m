//
//  CRBannerViewTests.m
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

#import "CriteoPublisherSdk.h"
#import "Criteo+Internal.h"
#import "CRBannerView+Internal.h"
#import "CR_BidManager.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_IntegrationRegistry.h"
#import "CR_URLOpenerMock.h"
#import "MockWKWebView.h"
#import "XCTestCase+Criteo.h"
#import "CR_NativeAssets+Testing.h"

@import WebKit;

#define TEST_DISPLAY_URL \
  @"https://rdi.eu.criteo.com/delivery/rtb/demo/ajs?zoneid=1417086&width=300&height=250&ibva=0"

@interface CRBannerViewTests : XCTestCase <WKNavigationDelegate>

@property(nonatomic, copy) void (^webViewDidLoadBlock)(void);
@property(nonatomic, strong) CR_CacheAdUnit *expectedCacheAdUnit;
@property(nonatomic, strong) CRBannerAdUnit *adUnit;
@property(strong, nonatomic) CR_URLOpenerMock *urlOpener;
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CRBannerViewTests

#pragma mark - Lifecycle

- (void)setUp {
  self.expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                 size:CGSizeMake(47.0, 57.0)
                                                           adUnitType:CRAdUnitTypeBanner];
  self.adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"123" size:CGSizeMake(47.0, 57.0)];
  self.urlOpener = [[CR_URLOpenerMock alloc] init];

  self.integrationRegistry = OCMClassMock([CR_IntegrationRegistry class]);

  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
  dependencyProvider.integrationRegistry = self.integrationRegistry;

  self.criteo = OCMPartialMock([Criteo.alloc initWithDependencyProvider:dependencyProvider]);
}

- (void)tearDown {
  // Not sure why this is needed but without this testWithRendering is failing.
  // Maybe this come from OCMock not handling properly partial mock ???
  self.criteo = nil;
}

#pragma mark - Tests

- (void)testBannerSuccess {
  WKWebView *mockWebView = OCMPartialMock([[WKWebView alloc] init]);
  CR_CdbBid *bid = [self cdbBidWithDisplayUrl:TEST_DISPLAY_URL];
  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:bid];

  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
                           return [html
                               containsString:@"<script src=\"" TEST_DISPLAY_URL "\"></script>"];
                         }]
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  [bannerView loadAd];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
  OCMVerify([self.criteo loadCdbBidForAdUnit:[self expectedCacheAdUnit]
                             responseHandler:[OCMArg any]]);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

- (void)testWebViewAddedToViewHierarchy {
  MockWKWebView *mockWebView = [MockWKWebView new];

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView addWebView:YES];

  XCTAssertEqual(mockWebView, bannerView.subviews[0]);
}

- (void)testWithRendering {
  WKWebView *realWebView = [WKWebView new];

  CR_CdbBid *bid = [self cdbBidWithDisplayUrl:@"-"];
  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:bid];

  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  realWebView.navigationDelegate = self;
  [bannerView loadAd];

  XCTestExpectation __block *marginExpectation =
      [self expectationWithDescription:@"WebView body has 0px margin"];
  XCTestExpectation __block *paddingExpectation =
      [self expectationWithDescription:@"WebView body has 0px padding"];
  XCTestExpectation __block *viewportExpectation =
      [self expectationWithDescription:@"WebView body has 0px margin"];

  __weak typeof(self) weakSelf = self;
  _webViewDidLoadBlock = ^{
    [realWebView
        evaluateJavaScript:
            @"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin')"
         completionHandler:^(id _Nullable result, NSError *_Nullable error) {
           [weakSelf _assertMarginPaddingWithError:error
                                            result:result
                                       expectation:marginExpectation];
         }];
    [realWebView
        evaluateJavaScript:
            @"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('padding')"
         completionHandler:^(id _Nullable result, NSError *_Nullable error) {
           [weakSelf _assertMarginPaddingWithError:error
                                            result:result
                                       expectation:paddingExpectation];
         }];
    [realWebView
        evaluateJavaScript:@"document.querySelector('meta[name=viewport]').getAttribute('content')"
         completionHandler:^(id _Nullable result, NSError *_Nullable error) {
           [weakSelf _assertContentWithError:error result:result expectation:viewportExpectation];
         }];
  };
  [self cr_waitForExpectations:@[ marginExpectation, paddingExpectation, viewportExpectation ]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  _webViewDidLoadBlock();
}

- (void)testBannerFail {
  WKWebView *realWebView = [WKWebView new];
  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:nil];

  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  [bannerView loadAd];

  OCMVerify([self.criteo loadCdbBidForAdUnit:[self expectedCacheAdUnit]
                             responseHandler:[OCMArg any]]);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

// TODO: UITests for "click" on a "real" webview with a real link
- (void)testAllowNavigationActionPolicyForWebView {
  /* Allow navigation Types other than Links from Mainframes in WebView.
   eg: Clicking images inside <a> tag generates WKNavigationTypeOther
   */
  CRBannerView *bannerView = [self bannerViewWithWebView:nil];

  WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeOther);
  [bannerView webView:nil
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
                        XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
                      }];

  mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
  WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
  OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
  OCMStub([mockFrame isMainFrame]).andReturn(YES);
  NSURLRequest *request = [[NSURLRequest alloc] init];
  OCMStub(mockNavigationAction.request).andReturn(request);
  [bannerView webView:nil
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
                        XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
                      }];
}

- (void)testCancelNavigationActionPolicyForWebView {
  // cancel webView navigation for clicks on Links from mainFrame and open in browser
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

  CRBannerView *bannerView = [self bannerViewWithWebView:nil];
  [bannerView webView:nil
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
// TODO: (U)ITests for "window.open" in a "real" webview
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

  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  [bannerView webView:realWebView
      createWebViewWithConfiguration:nil
                 forNavigationAction:mockNavigationAction
                      windowFeatures:nil];

  dispatch_async(dispatch_get_main_queue(), ^{
    XCTAssertEqual(self.urlOpener.openExternalURLCount, 1);
    [openInBrowserExpectation fulfill];
  });

  [self cr_waitShortlyForExpectations:@[ openInBrowserExpectation ]];
}

- (void)testDisplayAdWithDataSuccess {
  WKWebView *mockWebView = OCMPartialMock([WKWebView new]);
  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
                           return [html
                               containsString:@"<script src=\"" TEST_DISPLAY_URL "\"></script>"];
                         }]
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  [bannerView loadAdWithDisplayData:TEST_DISPLAY_URL];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
}

#pragma mark In House

- (void)testLoadingWithBidSuccess {
  WKWebView *mockWebView = OCMPartialMock([WKWebView new]);
  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:[OCMArg checkWithBlock:^BOOL(NSString *html) {
                           return [html
                               containsString:@"<script src=\"" TEST_DISPLAY_URL "\"></script>"];
                         }]
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  CR_CdbBid *cdbBid = [self cdbBidWithDisplayUrl:TEST_DISPLAY_URL];
  CRBid *bid = [[CRBid alloc] initWithCdbBid:cdbBid adUnit:self.adUnit];

  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:self.criteo
                                  webView:mockWebView
                               addWebView:NO
                                   adUnit:nil
                                urlOpener:self.urlOpener];
  [bannerView loadAdWithBid:bid];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
}

- (void)testTemplatingFromConfig {
  CR_Config *config = [CR_Config new];
  config.adTagUrlMode = @"Good Morning, my width is #WEEDTH# and my URL is ˆURLˆ";
  config.viewportWidthMacro = @"#WEEDTH#";
  config.displayURLMacro = @"ˆURLˆ";
  self.criteo.dependencyProvider.config = config;

  WKWebView *mockWebView = OCMPartialMock([WKWebView new]);
  XCTestExpectation *webViewLoadedExpectation =
      [[XCTestExpectation alloc] initWithDescription:@"webViewLoadedExpectation"];
  OCMExpect([mockWebView loadHTMLString:@"Good Morning, my width is 47 and my URL is whatDoYouMean"
                                baseURL:[NSURL URLWithString:@"https://criteo.com"]])
      .andDo(^(NSInvocation *args) {
        [webViewLoadedExpectation fulfill];
      });

  NSString *displayURL = @"whatDoYouMean";
  CR_CdbBid *cdbBid = [self cdbBidWithDisplayUrl:displayURL];
  CRBid *bid = [[CRBid alloc] initWithCdbBid:cdbBid adUnit:self.adUnit];

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  [bannerView loadAdWithBid:bid];

  [self cr_waitForExpectations:@[ webViewLoadedExpectation ]];
  OCMVerifyAll(mockWebView);
}

#pragma mark - Private

// To avoid warning for avoiding retain cycle in blocks
- (void)_assertMarginPaddingWithError:(NSError *)error
                               result:(NSString *)result
                          expectation:(XCTestExpectation *)expectation {
  XCTAssertNil(error);
  XCTAssertEqualObjects(@"0px", (NSString *)result);
  [expectation fulfill];
}

// To avoid warning for avoiding retain cycle in blocks
- (void)_assertContentWithError:(NSError *)error
                         result:(NSString *)result
                    expectation:(XCTestExpectation *)expectation {
  XCTAssertNil(error);
  XCTAssertTrue([(NSString *)result containsString:@"width=47"]);
  [expectation fulfill];
}

- (CRBannerView *)bannerViewWithWebView:(WKWebView *)webView {
  return [self bannerViewWithWebView:webView addWebView:NO];
}

- (CRBannerView *)bannerViewWithWebView:(WKWebView *)webView addWebView:(BOOL)addWebView {
  return [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                      criteo:self.criteo
                                     webView:webView
                                  addWebView:addWebView
                                      adUnit:self.adUnit
                                   urlOpener:self.urlOpener];
}

- (CR_CdbBid *)cdbBidWithDisplayUrl:(NSString *)displayURL {
  CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
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
                              nativeAssets:assets
                              impressionId:nil];
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
