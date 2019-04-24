//
//  CRInterstitialTest.m
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
#import "CRAdUnit.h"
#import "CRInterstitial.h"
#import "CRInterstitial+Internal.h"
#import "MockWKWebView.h"

@interface CRInterstitialTest : XCTestCase
{
    CR_CdbBid *_bid;
    CRAdUnit *_adUnit;
}
@end

@implementation CRInterstitialTest

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

- (CRAdUnit *)expectedAdUnit {
    if(!_adUnit) {
        _adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"123" size:[UIScreen mainScreen].bounds.size];
    }
    return _adUnit;
}

- (void)testInterstitialSuccess {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];

    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo webView:mockWebView];

    NSString *displayURL = @"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U";

    CR_CdbBid *bid = [self bidWithDisplayURL:displayURL];

    OCMExpect([mockCriteo getBid:[self expectedAdUnit]]).andReturn(bid);

    [interstitial loadAd:@"123"];

    XCTAssertTrue([mockWebView.loadedHTMLString containsString:@"<script src=\"https://rdi.eu.criteo.com/delivery/r/ajs.php?did=5c98e9d9c574a3589f8e9465fce67b00&u=%7Cx8O2jgV2RMISbZvm2b09FrpmynuoN27jeqtp1aMfZdU%3D%7C&c1=oP5_e7JVVt0EkjVehxP6aIOIWS-fm2fzhyMXUboeuR1zkGydE3HlloxT1QAbHNNgeH7t9e1IR6mv0biMxm46ZSFdAXZXreJVeP6QwU8IPLUsA32HNafhqgpnKTwmx9RrrJm4CS5Wqj07vNY7UTgDei8AWqc5CGPT2wm7W02JRvgN2kA-oWbWifmmm6EPpqVZijDHDzXwaNgzrfsaEodEmYAjFepGF0mdElHoFUCPKuOtc7mUQijLG0BSS9RhwrCTcAv42KkEQ359Et_eDnQcSt9OAF3bL64QIvLQxt2ekYFNuv3zng03qL0DIHS2bDJwRb3ieUlvZCWHI49OqM5PqoGDpSzdhdwfTE18L6cOOVKqPQ0dPofN4dkSs9IbVGiYlPnjfibL88PwTspYvki2svidSDIa2agQMHVgEof8YY4x4VgPjA8XY-s93ttw_i-RN3lcQn2mGEp6FYmRsyjFEDxHgGfJ0j6U\"></script>"]);
    XCTAssertEqualObjects([NSURL URLWithString:@"about:blank"],mockWebView.loadedBaseURL);
}

- (void)testWebViewAddedToViewHierarchy {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    MockWKWebView *mockWebView = [MockWKWebView new];

    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo webView:mockWebView];
    XCTestExpectation __block *webViewAddedToSuperviewExpectation = [self expectationWithDescription:@"WebView added to superview"];

    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(interstitial.isLoaded) {
            [timer invalidate];
            UIViewController *vc = OCMStrictClassMock([UIViewController class]);
            OCMStub([vc presentViewController:OCMArg.any animated:YES completion:nil]);
            [interstitial presentFromRootViewController:vc];
            OCMVerify([vc presentViewController:[OCMArg checkWithBlock:^(id value){
                [(UIViewController *)value viewDidLoad];

                XCTAssertNotNil(mockWebView.superview);
                [webViewAddedToSuperviewExpectation fulfill];
                return YES;
            }] animated:YES completion:nil]);

        }
    }];

    CR_CdbBid *bid = [self bidWithDisplayURL:@""];

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn(bid);
    [interstitial loadAd:@"123"];
    OCMVerify([mockCriteo getBid:[self expectedAdUnit]]);

    [self waitForExpectations:@[webViewAddedToSuperviewExpectation] timeout:5];
}

- (void)testWithRendering {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *realWebView = [WKWebView new];

    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo webView:realWebView];

    CR_CdbBid *bid = [self bidWithDisplayURL:@""];

    XCTestExpectation __block *marginExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];
    XCTestExpectation __block *paddingExpectation = [self expectationWithDescription:@"WebView body has 0px padding"];
    XCTestExpectation __block *viewportExpectation = [self expectationWithDescription:@"WebView body has 0px margin"];

   [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(interstitial.isLoaded) {
            [timer invalidate];
            [realWebView evaluateJavaScript:@"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('margin')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                XCTAssertNil(error);
                XCTAssertEqualObjects(@"0px", (NSString *)result);
                [marginExpectation fulfill];
            }];
            [realWebView evaluateJavaScript:@"window.getComputedStyle(document.getElementsByTagName('body')[0]).getPropertyValue('padding')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                XCTAssertNil(error);
                XCTAssertEqualObjects(@"0px", (NSString *)result);
                [paddingExpectation fulfill];
            }];
            [realWebView evaluateJavaScript:@"document.querySelector('meta[name=viewport]').getAttribute('content')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                XCTAssertNil(error);
                CGFloat width = [UIScreen mainScreen].bounds.size.width;
                NSString *searchString = [NSString stringWithFormat:@"width=%ld",(long)width];
                XCTAssertTrue([(NSString *)result containsString:searchString]);
                [viewportExpectation fulfill];
            }];
        }
    }];

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn(bid);
    [interstitial loadAd:@"123"];
    OCMVerify([mockCriteo getBid:[self expectedAdUnit]]);

    [self waitForExpectations:@[marginExpectation, paddingExpectation, viewportExpectation] timeout:5];
}

- (void)testInterstitialFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *realWebView = [WKWebView new];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo webView:realWebView];
    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn(nil);
    [interstitial loadAd:@"123"];
    OCMVerify([mockCriteo getBid:[self expectedAdUnit]]);
}

@end
