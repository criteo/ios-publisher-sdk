//
//  CRBannerViewTests.m
//  pubsdkTests
//
//  Created by Julien Stoeffler on 4/2/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_BidManager.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRAdUnit.h"
#import "CRBannerView.h"
#import "CRBannerView+Internal.h"
#import "MockWKWebView.h"

@import WebKit;

@interface CRBannerViewTests : XCTestCase <WKNavigationDelegate>
@property (nonatomic, copy) void (^webViewDidLoadBlock)(void);

@end

@implementation CRBannerViewTests



- (void)testBannerSuccess {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                       application:nil];

    CRAdUnit *expectedAdUnit💡 = [[CRAdUnit alloc] initWithAdUnitId:@"123"
                                                               size:CGSizeMake(47.0f, 57.0f)];
    NSString *displayURL = @"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U";

    CR_CdbBid *bid = [[CR_CdbBid alloc] initWithZoneId:@123
                                           placementId:@"placementId"
                                                   cpm:@"4.2"
                                              currency:@"₹😀"
                                                 width:@47.0f
                                                height:[NSNumber numberWithFloat:57.0f]
                                                   ttl:26
                                              creative:@"THIS IS USELESS LEGACY"
                                            displayUrl:displayURL
                                            insertTime:[NSDate date]];

    OCMStub([mockCriteo getBid:expectedAdUnit💡]).andReturn(bid);

    [bannerView loadAd:@"123"];
    OCMVerify([mockCriteo getBid:expectedAdUnit💡]);

    XCTAssertTrue([mockWebView.loadedHTMLString containsString:@"<script src=\"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U\"></script>"]);
    XCTAssertEqualObjects([NSURL URLWithString:@"about:blank"],mockWebView.loadedBaseURL);
}

- (void)testWebViewAddedToViewHierarchy {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                       application:nil];
    XCTAssertEqual(mockWebView, [bannerView.subviews objectAtIndex:0]);
}

- (void)testWithRendering {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *realWebView = [WKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                       application:nil];
    realWebView.navigationDelegate = self;
    CRAdUnit *expectedAdUnit💡 = [[CRAdUnit alloc] initWithAdUnitId:@"123"
                                                               size:CGSizeMake(47.0f, 57.0f)];
    NSString *displayURL = @"";

    CR_CdbBid *bid = [[CR_CdbBid alloc] initWithZoneId:@123
                                           placementId:@"placementId"
                                                   cpm:@"4.2"
                                              currency:@"₹😀"
                                                 width:@47.0f
                                                height:[NSNumber numberWithFloat:57.0f]
                                                   ttl:26
                                              creative:@"THIS IS USELESS LEGACY"
                                            displayUrl:displayURL
                                            insertTime:[NSDate date]];

    OCMStub([mockCriteo getBid:expectedAdUnit💡]).andReturn(bid);

    [bannerView loadAd:@"123"];
    XCTestExpectation __block *marginExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];
    XCTestExpectation __block *paddingExpectation = [self expectationWithDescription:@"WebView body has 0px padding"];
    XCTestExpectation __block *viewportExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];
    _webViewDidLoadBlock = ^{
        [realWebView evaluateJavaScript:@"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin')"
                      completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                          XCTAssertNil(error);
                          XCTAssertEqualObjects(@"0px", (NSString *)result);
                          [marginExpectation fulfill];
                      }];
        [realWebView evaluateJavaScript:@"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('padding')"
                      completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                          XCTAssertNil(error);
                          XCTAssertEqualObjects(@"0px", (NSString *)result);
                          [paddingExpectation fulfill];
                      }];
        [realWebView evaluateJavaScript:@"document.querySelector('meta[name=viewport]').getAttribute('content')"
                      completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                          XCTAssertNil(error);
                          XCTAssertTrue([(NSString *)result containsString:@"width=47"]);
                          [viewportExpectation fulfill];
                      }];
    };
    [self waitForExpectations:@[marginExpectation, paddingExpectation, viewportExpectation]
                      timeout:5];
}

-     (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    _webViewDidLoadBlock();
}

- (void) testBannerFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *realWebView = [WKWebView new];
    CRAdUnit *expectedAdUnit💡 = [[CRAdUnit alloc] initWithAdUnitId:@"123"
                                                               size:CGSizeMake(47.0f, 57.0f)];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                       application:nil];
    OCMStub([mockCriteo getBid:expectedAdUnit💡]).andReturn(nil);
    [bannerView loadAd:@"123"];
    OCMVerify([mockCriteo getBid:expectedAdUnit💡]);
}

// TODO: UITests for "click" on a "real" webview with a real link
- (void)testAllowNavigationActionPolicyForWebView {

    /* Allow navigation Types other than Links from Mainframes in WebView.
     eg: Clicking images inside <a> tag generates WKNavigationTypeOther
     */
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:mockApplication];
    WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
    OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeOther);
    [bannerView webView:nil decidePolicyForNavigationAction:mockNavigationAction
        decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
            XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
        }];

    mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
    OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
    WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
    OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
    OCMStub([mockFrame isMainFrame]).andReturn(YES);
    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:nil];
    OCMStub(mockNavigationAction.request).andReturn(request);
    [bannerView webView:nil decidePolicyForNavigationAction:mockNavigationAction
        decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
            XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
        }];
}

- (void)testCancelNavigationActionPolicyForWebView {
    // cancel webView navigation for clicks on Links from mainFrame and open in browser
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:mockApplication];

    WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
    OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
    WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
    OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
    OCMStub([mockFrame isMainFrame]).andReturn(YES);
    NSURL *url = [[NSURL alloc] initWithString:@"123"];
    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
    OCMStub(mockNavigationAction.request).andReturn(request);
    OCMStub([mockApplication canOpenURL:url]).andReturn(YES);
    OCMStub([mockApplication openURL:url]);

    XCTestExpectation *openInBrowserExpectation = [self expectationWithDescription:@"URL opened in browser expectation"];
    [bannerView webView:nil decidePolicyForNavigationAction:mockNavigationAction
          decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
              XCTAssertEqual(actionPolicy, WKNavigationActionPolicyCancel);
          }];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockApplication openURL:url]);
                                          [openInBrowserExpectation fulfill];
                                      }];
    [self waitForExpectations:@[openInBrowserExpectation]
                      timeout:5];
}

@end
