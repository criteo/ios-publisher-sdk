//
//  CRBannerViewTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_BidManager.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_CacheAdUnit.h"
#import "CRBannerView.h"
#import "CRBannerView+Internal.h"
#import "MockWKWebView.h"
#import "CRBidToken+Internal.h"
#import "NSError+Criteo.h"
#import "CRBannerAdUnit.h"
#import "NSURL+Criteo.h"

@import WebKit;

@interface CRBannerViewTests : XCTestCase <WKNavigationDelegate>
@property (nonatomic, copy) void (^webViewDidLoadBlock)(void);
@property (nonatomic, strong) CR_CacheAdUnit *cacheAdUnit;
@property (nonatomic, strong) CRBannerAdUnit *adUnit;
@end

@implementation CRBannerViewTests

- (void)setUp {
    _cacheAdUnit = nil;
    _adUnit = nil;
}

- (CR_CacheAdUnit *)expectedCacheAdUnit {
    if(!_cacheAdUnit) {
        _cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                           size:CGSizeMake(47.0, 57.0)
                                                     adUnitType:CRAdUnitTypeBanner];
    }
    return _cacheAdUnit;
}

- (CRBannerAdUnit *)adUnit {
    if(!_adUnit) {
        _adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"123"
                                                      size:CGSizeMake(47.0, 57.0)];
    }
    return _adUnit;
}

- (void)testBannerSuccess {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    MockWKWebView *mockWebView = [MockWKWebView new];

    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                            adUnit:self.adUnit];

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
                                            insertTime:[NSDate date]
                                          nativeAssets:nil
                                          impressionId:nil];

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn(bid);

    [bannerView loadAd];
    OCMVerify([mockCriteo getBid:[self expectedCacheAdUnit]]);

    XCTAssertTrue([mockWebView.loadedHTMLString containsString:@"<script src=\"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U\"></script>"]);
    XCTAssertEqualObjects([NSURL URLWithString:@"https://criteo.com"],mockWebView.loadedBaseURL);
}

- (void)testWebViewAddedToViewHierarchy {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                            adUnit:self.adUnit];
    XCTAssertEqual(mockWebView, [bannerView.subviews objectAtIndex:0]);
}

- (void)testWithRendering {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *realWebView = [WKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                            adUnit:self.adUnit];
    realWebView.navigationDelegate = self;

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
                                            insertTime:[NSDate date]
                                          nativeAssets:nil
                                          impressionId:nil];


    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn(bid);

    [bannerView loadAd];
    XCTestExpectation __block *marginExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];
    XCTestExpectation __block *paddingExpectation = [self expectationWithDescription:@"WebView body has 0px padding"];
    XCTestExpectation __block *viewportExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];

    __weak typeof(self) weakSelf = self;
    _webViewDidLoadBlock = ^{
        [realWebView evaluateJavaScript:@"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin')"
                      completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            [weakSelf _assertMarginPaddingWithError:error
                                             result:result
                                        expectation:marginExpectation];
        }];
        [realWebView evaluateJavaScript:@"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('padding')"
                      completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            [weakSelf _assertMarginPaddingWithError:error
                                             result:result
                                        expectation:paddingExpectation];
        }];
        [realWebView evaluateJavaScript:@"document.querySelector('meta[name=viewport]').getAttribute('content')"
                      completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            [weakSelf _assertContentWithError:error
                                       result:result
                                  expectation:viewportExpectation];
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
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *realWebView = [WKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                            adUnit:self.adUnit];
    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn(nil);
    [bannerView loadAd];
    OCMVerify([mockCriteo getBid:[self expectedCacheAdUnit]]);
}

// TODO: UITests for "click" on a "real" webview with a real link
- (void)testAllowNavigationActionPolicyForWebView {

    /* Allow navigation Types other than Links from Mainframes in WebView.
     eg: Clicking images inside <a> tag generates WKNavigationTypeOther
     */
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                            adUnit:self.adUnit];
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
    NSURLRequest *request =  [[NSURLRequest alloc] init];
    OCMStub(mockNavigationAction.request).andReturn(request);
    [bannerView webView:nil decidePolicyForNavigationAction:mockNavigationAction
        decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
            XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
        }];
}

- (void)testCancelNavigationActionPolicyForWebView {
    // cancel webView navigation for clicks on Links from mainFrame and open in browser
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                            adUnit:self.adUnit];

    WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
    OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
    WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
    OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
    OCMStub([mockFrame isMainFrame]).andReturn(YES);
    NSURL *url = [[NSURL alloc] initWithString:@"123"];
    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
    OCMStub(mockNavigationAction.request).andReturn(request);
    id mockUrl = OCMPartialMock(url);
    OCMStub([mockUrl cr_openExternal]);

    XCTestExpectation *openInBrowserExpectation = [self expectationWithDescription:@"URL opened in browser expectation"];
    [bannerView webView:nil decidePolicyForNavigationAction:mockNavigationAction
          decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
              XCTAssertEqual(actionPolicy, WKNavigationActionPolicyCancel);
          }];

    dispatch_async(dispatch_get_main_queue(), ^{
        OCMVerify([mockUrl cr_openExternal]);
        [openInBrowserExpectation fulfill];
    });


    [self waitForExpectations:@[openInBrowserExpectation]
                      timeout:1];
}


// Test window.open navigation delegate
// TODO: (U)ITests for "window.open" in a "real" webview
- (void)testCreateWebViewWithConfiguration {
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                            adUnit:nil];

    WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);

    OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeOther);
    WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
    OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
    OCMStub([mockFrame isMainFrame]).andReturn(YES);
    NSURL *url = [[NSURL alloc] initWithString:@"123"];
    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
    OCMStub(mockNavigationAction.request).andReturn(request);
    id mockUrl = OCMPartialMock(url);
    OCMStub([mockUrl cr_openExternal]);

    XCTestExpectation *openInBrowserExpectation = [self expectationWithDescription:@"URL opened in browser expectation"];
    [bannerView webView:realWebView createWebViewWithConfiguration:nil forNavigationAction:mockNavigationAction windowFeatures:nil];


    dispatch_async(dispatch_get_main_queue(), ^{
        OCMVerify([mockUrl cr_openExternal]);
        [openInBrowserExpectation fulfill];
    });

    [self waitForExpectations:@[openInBrowserExpectation]
                      timeout:1];
}


#pragma inhouseSpecificTests

- (void)testLoadingSuccess {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    MockWKWebView *mockWebView = [MockWKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                            adUnit:self.adUnit];
    CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    NSString *displayURL = @"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U";
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"123" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:displayURL
                                                                       insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-100]
                                                                              ttl:200
                                                                           adUnit:adUnit];
    OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner]).andReturn(expectedTokenValue);

    [bannerView loadAdWithBidToken:token];
    XCTAssertTrue([mockWebView.loadedHTMLString containsString:@"<script src=\"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U\"></script>"]);
    XCTAssertEqualObjects([NSURL URLWithString:@"https://criteo.com"],mockWebView.loadedBaseURL);
}

- (void)testTemplatingFromConfig {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_Config *config = [CR_Config new];
    config.adTagUrlMode = @"Good Morning, my width is #WEEDTH# and my URL is ˆURLˆ";
    config.viewportWidthMacro = @"#WEEDTH#";
    config.displayURLMacro = @"ˆURLˆ";
    OCMExpect(mockCriteo.config).andReturn(config);

    CRBannerAdUnit *adUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Adrian" size:CGSizeMake(300, 300)];
    CRBannerAdUnit *adUnit2 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Adrian" size:CGSizeMake(300, 300)];

    MockWKWebView *mockWebView = [MockWKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                            adUnit:adUnit1];


    CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    NSString *displayURL = @"whatDoYouMean";
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:displayURL
                                                                       insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-100]
                                                                              ttl:200
                                                                           adUnit:adUnit2];
    OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner]).andReturn(expectedTokenValue);

    [bannerView loadAdWithBidToken:token];
    XCTAssertEqualObjects(mockWebView.loadedHTMLString, @"Good Morning, my width is 47 and my URL is whatDoYouMean");
}

#pragma mark - Private

// To avoid warning for avoiding retain cycle in blocks
- (void)_assertMarginPaddingWithError:(NSError *)error
                               result:(NSString *)result
                          expectation:(XCTestExpectation *)expectation
{
    XCTAssertNil(error);
    XCTAssertEqualObjects(@"0px", (NSString *)result);
    [expectation fulfill];
}

// To avoid warning for avoiding retain cycle in blocks
- (void)_assertContentWithError:(NSError *)error
                         result:(NSString *)result
                    expectation:(XCTestExpectation *)expectation
{
    XCTAssertNil(error);
    XCTAssertTrue([(NSString *)result containsString:@"width=47"]);
    [expectation fulfill];
}

@end
