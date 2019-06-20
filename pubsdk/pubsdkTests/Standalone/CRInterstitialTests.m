//
//  CRInterstitialTests.m
//  pubsdkTests
//
//  Created by Julien Stoeffler on 4/15/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_BidManager.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_CacheAdUnit.h"
#import "CRInterstitial.h"
#import "CRInterstitial+Internal.h"
#import "MockWKWebView.h"
#import "CR_InterstitialViewController.h"
#import "CR_AdUnitHelper.h"

@interface CRInterstitialTests : XCTestCase
{
    CR_CdbBid *_bid;
    CR_CacheAdUnit *_adUnit;
}
@end

@implementation CRInterstitialTests

- (void)setUp {
    _bid = nil;
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
                                      insertTime:[NSDate date]];
    }
    return _bid;
}

- (CR_CacheAdUnit *)expectedAdUnit {
    if(!_adUnit) {
        _adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                     size:CGSizeMake(320.0, 480.0)];
    }
    return _adUnit;
}

- (void)testInterstitialSuccess {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO];
    
    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[[CR_DeviceInfo new] screenSize]]).andReturn([self expectedAdUnit]);

    OCMExpect([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);

    [interstitial loadAd:@"123"];

    XCTAssertTrue([mockWebView.loadedHTMLString containsString:@"<script src=\"test\"></script>"]);
    XCTAssertEqualObjects([NSURL URLWithString:@"about:blank"],mockWebView.loadedBaseURL);
}

- (void)testWebViewAddedToViewHierarchy {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];

    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:YES];
    UIViewController *vc = OCMStrictClassMock([UIViewController class]);
    OCMStub([vc presentViewController:OCMArg.any animated:YES completion:[OCMArg isNotNil]]);
    [interstitial presentFromRootViewController:vc];
    OCMVerify([vc presentViewController:[OCMArg checkWithBlock:^(id value){
        [(UIViewController *)value viewDidLoad];
        XCTAssertEqual(mockWebView.superview, interstitialVC.view);
        return YES;
    }] animated:YES completion:[OCMArg isNotNil]]);
}

- (void)testWithRendering {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *realWebView = [WKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO];

    CR_CdbBid *bid = [self bidWithDisplayURL:@"test"];
    
    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[[CR_DeviceInfo new] screenSize]]).andReturn([self expectedAdUnit]);

    XCTestExpectation __block *marginExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];
    XCTestExpectation __block *paddingExpectation = [self expectationWithDescription:@"WebView body has 0px padding"];
    XCTestExpectation __block *viewportExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];

    [NSTimer scheduledTimerWithTimeInterval:2
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
                                                                CGFloat width = [self expectedAdUnit].size.width;
                                                                NSString *searchString = [NSString stringWithFormat:@"width=%tu",(NSUInteger)width];
                                                                XCTAssertTrue([(NSString *)result containsString:searchString]);
                                                                [viewportExpectation fulfill];
                                                            }];
                                          }];

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn(bid);
    [interstitial loadAd:@"123"];
    OCMVerify([mockCriteo getBid:[self expectedAdUnit]]);

    [self waitForExpectations:@[marginExpectation, paddingExpectation, viewportExpectation] timeout:5];
}

- (void)testInterstitialFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_InterstitialViewController *interstitialVC = OCMStrictClassMock([CR_InterstitialViewController class]);
    WKWebView *realWebView = [WKWebView new];
    OCMStub([interstitialVC webView]).andReturn(realWebView);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                            application:nil
                                                               isAdLoaded:NO];
    
    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[[CR_DeviceInfo new] screenSize]]).andReturn([self expectedAdUnit]);

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn(nil);
    OCMStub([interstitialVC presentingViewController]).andReturn(nil);
    [interstitial loadAd:@"123"];
    OCMVerify([mockCriteo getBid:[self expectedAdUnit]]);
}

// TODO: UITests for "click" on a "real" webview with a real link
- (void)testAllowNavigationActionPolicyForWebView {

    /* Allow navigation Types other than Links from Mainframes in WebView.
     eg: Clicking images inside <a> tag generates WKNavigationTypeOther
    */
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:mockApplication
                                                               isAdLoaded:NO];
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
    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:nil];
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
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:mockApplication
                                                               isAdLoaded:NO];

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
    [interstitial webView:realWebView decidePolicyForNavigationAction:mockNavigationAction
          decisionHandler:^(WKNavigationActionPolicy actionPolicy) {
              XCTAssertEqual(actionPolicy, WKNavigationActionPolicyCancel);
          }];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockApplication openURL:url]);
                                          OCMVerify([interstitialVC dismissViewController]);
                                          [openInBrowserExpectation fulfill];
                                      }];
    [self waitForExpectations:@[openInBrowserExpectation]
                      timeout:5];
}

@end
