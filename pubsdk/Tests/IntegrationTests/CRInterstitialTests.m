//
//  CRInterstitialTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
#import "CR_BidManagerBuilder.h"
#import "CR_NetworkCaptor.h"
#import "Criteo+Testing.h"
#import "XCTestCase+Criteo.h"
#import "CR_Timer.h"
#import "NSURL+Criteo.h"

@interface CRInterstitialTests : XCTestCase
{
    CR_CdbBid *_bid;
    CR_CacheAdUnit *_cacheAdUnit;
    CRInterstitialAdUnit *_adUnit;
}
@end

@implementation CRInterstitialTests

- (void)setUp {
    _bid = nil;
    _cacheAdUnit = nil;
    _adUnit = nil;
}

- (CR_CdbBid *)bidWithDisplayURL:(NSString *)displayURL {
    if(!_bid) {
        _bid = [[CR_CdbBid alloc] initWithZoneId:@123
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
    }
    return _bid;
}

- (CR_CacheAdUnit *)expectedCacheAdUnit {
    if(!_cacheAdUnit) {
        _cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                           size:CGSizeMake(320.0, 480.0)
                                                     adUnitType:CRAdUnitTypeInterstitial];
    }
    return _cacheAdUnit;
}

- (CRInterstitialAdUnit *)adUnit {
    if(!_adUnit) {
        _adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"123"];
    }
    return _adUnit;
}

- (void)testInterstitialSuccess {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    MockWKWebView *mockWebView = [MockWKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    OCMExpect([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);

    [interstitial loadAd];

    XCTAssertTrue([mockWebView.loadedHTMLString containsString:@"<script src=\"test\"></script>"]);
    XCTAssertEqualObjects([NSURL URLWithString:@"https://criteo.com"],mockWebView.loadedBaseURL);
}

- (void)testTemplatingFromConfig {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_Config *config = [CR_Config new];
    config.adTagUrlMode = @"Good Morning, my width is #WEEDTH# and my URL is ˆURLˆ";
    config.viewportWidthMacro = @"#WEEDTH#";
    config.displayURLMacro = @"ˆURLˆ";
    OCMExpect(mockCriteo.config).andReturn(config);

    MockWKWebView *mockWebView = [MockWKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
                                                                   adUnit:nil];
    OCMExpect([mockCriteo getBid:OCMArg.any]).andReturn([self bidWithDisplayURL:@"whatDoYouMean"]);

    [interstitial loadAd];

    NSString *expectedHtml = [NSString stringWithFormat:@"Good Morning, my width is %ld and my URL is whatDoYouMean", (long)[UIScreen mainScreen].bounds.size.width];

    XCTAssertEqualObjects(mockWebView.loadedHTMLString, expectedHtml);
}


- (void)testWebViewAddedToViewHierarchy {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];

    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:YES
                                                                   adUnit:self.adUnit];
    UIViewController *vc = OCMStrictClassMock([UIViewController class]);
    OCMStub([vc presentViewController:OCMArg.any animated:YES completion:[OCMArg isNotNil]]);
    [interstitial presentFromRootViewController:vc];
    OCMVerify([vc presentViewController:[OCMArg checkWithBlock:^(id value){
        [(UIViewController *)value viewDidAppear:YES];
        XCTAssertEqual(mockWebView.superview, interstitialVC.view);
        return YES;
    }] animated:YES completion:[OCMArg isNotNil]]);
}

- (void)testWithRendering {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *realWebView = [WKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    CR_CdbBid *bid = [self bidWithDisplayURL:@"test"];

    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    XCTestExpectation __block *marginExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];
    XCTestExpectation __block *paddingExpectation = [self expectationWithDescription:@"WebView body has 0px padding"];
    XCTestExpectation __block *viewportExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];

    [CR_Timer scheduledTimerWithTimeInterval:2
                                     repeats:NO
                                       block:^(NSTimer * _Nonnull timer) {
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
                                                                CGFloat width = [UIScreen mainScreen].bounds.size.width;
                                                                NSString *searchString = [NSString stringWithFormat:@"width=%tu",(NSUInteger)width];
                                                                XCTAssertTrue([(NSString *)result containsString:searchString]);
                                                                [viewportExpectation fulfill];
                                                            }];
                                          }];

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn(bid);
    [interstitial loadAd];
    OCMVerify([mockCriteo getBid:[self expectedCacheAdUnit]]);

    [self waitForExpectations:@[marginExpectation, paddingExpectation, viewportExpectation] timeout:5];
}

- (void)testInterstitialFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_InterstitialViewController *interstitialVC = OCMStrictClassMock([CR_InterstitialViewController class]);
    WKWebView *realWebView = [WKWebView new];
    OCMStub([interstitialVC webView]).andReturn(realWebView);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([CR_CdbBid emptyBid]);
    OCMStub([interstitialVC presentingViewController]).andReturn(nil);
    [interstitial loadAd];
    OCMVerify([mockCriteo getBid:[self expectedCacheAdUnit]]);
}

// TODO: UITests for "click" on a "real" webview with a real link
- (void)testAllowNavigationActionPolicyForWebView {

    /* Allow navigation Types other than Links from Mainframes in WebView.
     eg: Clicking images inside <a> tag generates WKNavigationTypeOther
    */
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
    OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeOther);
    [interstitial webView:realWebView decidePolicyForNavigationAction:mockNavigationAction
          decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
              XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
          }];

    mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
    OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
    WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
    OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
    OCMStub([mockFrame isMainFrame]).andReturn(NO);
    NSURLRequest *request =  [[NSURLRequest alloc] init];
    OCMStub(mockNavigationAction.request).andReturn(request);
    [interstitial webView:realWebView decidePolicyForNavigationAction:mockNavigationAction
          decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
              XCTAssertEqual(actionPolicy, WKNavigationActionPolicyAllow);
          }];
}

- (void)testCancelNavigationActionPolicyForWebView {
    // cancel webView navigation for clicks on Links from mainFrame and open in browser
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
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
    [interstitial webView:realWebView decidePolicyForNavigationAction:mockNavigationAction
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
// TODO: UITests for "window.open" in a "real" webview
- (void)testCreateWebViewWithConfiguration {
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
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
    [interstitial webView:realWebView createWebViewWithConfiguration:nil forNavigationAction:mockNavigationAction windowFeatures:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        OCMVerify([mockUrl cr_openExternal]);
        [openInBrowserExpectation fulfill];
    });

    [self waitForExpectations:@[openInBrowserExpectation]
                      timeout:1];
}

// Android:  whenLoadingAnInterstitial_GivenInitializedSdk_ShouldSetInterstitialFlagInTheRequest
- (void)testLoadingInterstitialShouldSetInterstitialFlagInTheRequest {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [criteo testing_registerInterstitialAndWaitForHTTPResponses];
    XCTestExpectation *interstitialHttpCallExpectation = [self expectationWithDescription:@"configApiCallExpectation"];
    criteo.testing_networkCaptor.requestListener = ^(NSURL * _Nonnull url, CR_HTTPVerb verb, NSDictionary *body) {
        const BOOL isBidURL = [url.absoluteString containsString:criteo.config.cdbUrl];
        const BOOL isInterstitialPresent = [body[@"slots"][0][@"interstitial"] boolValue];
        if (isBidURL && isInterstitialPresent) {
            [interstitialHttpCallExpectation fulfill];
        }
    };

    [self _loadInterstitialAdWithCriteo:criteo];

    [self cr_waitForExpectations:@[interstitialHttpCallExpectation]];
}

- (void)_loadInterstitialAdWithCriteo:(Criteo *)criteo {
    MockWKWebView *mockWebView = [[MockWKWebView alloc] init];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:criteo
                                                           viewController:interstitialVC
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    [interstitial loadAd];
}

/*
- (CR_InterstitialViewController *)_interstitialViewController
{
    MockWKWebView *mockWebView = [[MockWKWebView alloc] init];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];

}
 */

@end
