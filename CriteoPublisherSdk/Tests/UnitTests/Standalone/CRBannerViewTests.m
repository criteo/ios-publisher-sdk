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
#import "CR_BidManager.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRBannerView.h"
#import "CRBannerView+Internal.h"
#import "MockWKWebView.h"
#import "CRBidToken+Internal.h"
#import "NSError+Criteo.h"
#import "CRBannerAdUnit.h"
#import "CR_URLOpenerMock.h"
#import "NSURL+Criteo.h"
#import "CR_TokenValue+Testing.h"
#import "XCTestCase+Criteo.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_IntegrationRegistry.h"

@import WebKit;

@interface CRBannerViewTests : XCTestCase <WKNavigationDelegate>

@property(nonatomic, copy) void (^webViewDidLoadBlock)(void);
@property(nonatomic, strong) CR_CacheAdUnit *expectedCacheAdUnit;
@property(nonatomic, strong) CRBannerAdUnit *adUnit;
@property(strong, nonatomic) CR_URLOpenerMock *urlOpener;
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CRBannerViewTests

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

- (void)testBannerSuccess {
  MockWKWebView *mockWebView = [MockWKWebView new];

  NSString *displayURL =
      @"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U";
  CR_CdbBid *bid = [self cdbBidWithDisplayUrl:displayURL];
  OCMStub([self.criteo getBid:[self expectedCacheAdUnit]]).andReturn(bid);

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  [bannerView loadAd];

  OCMVerify([self.criteo getBid:[self expectedCacheAdUnit]]);

  XCTAssertTrue([mockWebView.loadedHTMLString
      containsString:
          @"<script src=\"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U\"></script>"]);
  XCTAssertEqualObjects([NSURL URLWithString:@"https://criteo.com"], mockWebView.loadedBaseURL);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

- (void)testWebViewAddedToViewHierarchy {
  MockWKWebView *mockWebView = [MockWKWebView new];

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];

  XCTAssertEqual(mockWebView, bannerView.subviews[0]);
}

- (void)testWithRendering {
  WKWebView *realWebView = [WKWebView new];

  CR_CdbBid *bid = [self cdbBidWithDisplayUrl:@"-"];
  OCMStub([self.criteo getBid:[self expectedCacheAdUnit]]).andReturn(bid);

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
  OCMStub([self.criteo getBid:[self expectedCacheAdUnit]]).andReturn(nil);

  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  [bannerView loadAd];

  OCMVerify([self.criteo getBid:[self expectedCacheAdUnit]]);
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
  MockWKWebView *mockWebView = [MockWKWebView new];
  NSString *displayURL =
      @"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U";

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  [bannerView loadAdWithDisplayData:displayURL];

  XCTAssertTrue([mockWebView.loadedHTMLString
      containsString:
          @"<script src=\"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U\"></script>"]);
  XCTAssertEqualObjects([NSURL URLWithString:@"https://criteo.com"], mockWebView.loadedBaseURL);
}

#pragma - In House

- (void)testLoadingWithTokenSuccess {
  MockWKWebView *mockWebView = [MockWKWebView new];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  NSString *displayURL =
      @"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U";
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:displayURL
                                                                       adUnit:self.adUnit];
  OCMStub([self.criteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  [bannerView loadAdWithBidToken:token];

  XCTAssertTrue([mockWebView.loadedHTMLString
      containsString:
          @"<script src=\"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U\"></script>"]);
  XCTAssertEqualObjects([NSURL URLWithString:@"https://criteo.com"], mockWebView.loadedBaseURL);
}

- (void)testTemplatingFromConfig {
  CR_Config *config = [CR_Config new];
  config.adTagUrlMode = @"Good Morning, my width is #WEEDTH# and my URL is ˆURLˆ";
  config.viewportWidthMacro = @"#WEEDTH#";
  config.displayURLMacro = @"ˆURLˆ";
  self.criteo.dependencyProvider.config = config;

  MockWKWebView *mockWebView = [MockWKWebView new];

  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  NSString *displayURL = @"whatDoYouMean";
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:displayURL
                                                                       adUnit:self.adUnit];
  OCMStub([self.criteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  [bannerView loadAdWithBidToken:token];

  XCTAssertEqualObjects(mockWebView.loadedHTMLString,
                        @"Good Morning, my width is 47 and my URL is whatDoYouMean");
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
  return [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                      criteo:self.criteo
                                     webView:webView
                                      adUnit:self.adUnit
                                   urlOpener:self.urlOpener];
}

- (CR_CdbBid *)cdbBidWithDisplayUrl:(NSString *)displayURL {
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

@end
