//
//  CRBannerViewDelegateTests.m
//  pubsdkTests
//
//  Created by Sneha Pathrose on 5/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CRBannerView.h"
#import "Criteo.h"
#import "CRBannerView+Internal.h"
#import "CRBannerViewDelegate.h"
#import "Criteo+Internal.h"
#import "CR_CdbBid.h"


@interface CRBannerViewDelegateTests : XCTestCase
@end

@implementation CRBannerViewDelegateTests

- (void)testBannerDidLoad {
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                       application:nil];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate bannerDidLoad:bannerView]);
    CRAdUnit *expectedAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"123"
                                                             size:CGSizeMake(47.0f, 57.0f)];
    CR_CdbBid *expectedBid = [[CR_CdbBid alloc] initWithZoneId:@123
                                                   placementId:@"placementId"
                                                           cpm:@"4.2"
                                                      currency:@"₹😀"
                                                         width:@47.0f
                                                        height:[NSNumber numberWithFloat:57.0f]
                                                           ttl:26
                                                      creative:@"THIS IS USELESS LEGACY"
                                                    displayUrl:@""
                                                    insertTime:[NSDate date]];

    OCMStub([mockCriteo getBid:expectedAdUnit]).andReturn(expectedBid);
    [bannerView loadAd:@"123"];
    XCTestExpectation *bannerLoadDelegateExpectation = [self expectationWithDescription:@"bannerDidLoad delegate method called"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate bannerDidLoad:bannerView]);
                                          [bannerLoadDelegateExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerLoadDelegateExpectation]
                      timeout:5];
}

// test banner fail when an empty bid is returned
- (void)testBannerAdFetchFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:nil
                                                       application:nil];

    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate bannerDidFail:bannerView
                                        withError:[OCMArg any]]);
    CRAdUnit *expectedAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"123"
                                                             size:CGSizeMake(47.0f, 57.0f)];
    OCMStub([mockCriteo getBid:expectedAdUnit]).andReturn([CR_CdbBid emptyBid]);
    XCTestExpectation *bannerAdFetchFailExpectation = [self expectationWithDescription:@"bannerDidFail with error delegate method called"];
    [bannerView loadAd:@"123"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate bannerDidFail:bannerView
                                                                                withError:[OCMArg any]]);
                                          [bannerAdFetchFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerAdFetchFailExpectation]
                      timeout:5];
}

- (void)testBannerWillLeaveApplication {
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:mockApplication];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate bannerWillLeaveApplication:bannerView]);
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
    XCTestExpectation *bannerWillLeaveApplication = [self expectationWithDescription:@"bannerWillLeaveApplication delegate method called"];
    [bannerView webView:nil decidePolicyForNavigationAction:mockNavigationAction
        decisionHandler:^(WKNavigationActionPolicy decisionHandler) {
        }];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate bannerWillLeaveApplication:bannerView]);
                                          [bannerWillLeaveApplication fulfill];
                                      }];
    [self waitForExpectations:@[bannerWillLeaveApplication]
                      timeout:5];
}

// test banner fail delegate method called when webView navigation fails
- (void)testBannerFailWhenWebViewFailsToNavigate {
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:nil];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate bannerDidFail:bannerView
                                        withError:[OCMArg any]]);
    XCTestExpectation *bannerWebViewNavigationFailExpectation = [self expectationWithDescription:@"bannerDidFail delegate method called"];
    [bannerView webView:nil didFailNavigation:nil
              withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate bannerDidFail:bannerView
                                                                                withError:[OCMArg any]]);
                                          [bannerWebViewNavigationFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerWebViewNavigationFailExpectation]
                      timeout:5];
}

// test banner fail delegate method called when webView load fails
- (void)testBannerFailWhenWebViewFailsToLoad {
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:nil];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate bannerDidFail:bannerView
                                        withError:[OCMArg any]]);
    XCTestExpectation *bannerWebViewLoadExpectation = [self expectationWithDescription:@"bannerDidFail delegate method called"];
    [bannerView webView:nil didFailProvisionalNavigation:nil
              withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate bannerDidFail:bannerView
                                                                                withError:[OCMArg any]]);
                                          [bannerWebViewLoadExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerWebViewLoadExpectation]
                      timeout:5];
}

// test banner fail delegate method called when HTTP error
- (void)testBannerFailWhenHTTPError {
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:nil];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate bannerDidFail:bannerView
                                        withError:[OCMArg any]]);
    XCTestExpectation *bannerHTTPErrorExpectation = [self expectationWithDescription:@"bannerDidFail delegate method called"];
    WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(404);
    OCMStub(navigationResponse.response).andReturn(response);
    [bannerView webView:nil decidePolicyForNavigationResponse:navigationResponse
        decisionHandler:^(WKNavigationResponsePolicy decisionHandler) {
        }];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate bannerDidFail:bannerView
                                                                                withError:[OCMArg any]]);
                                          [bannerHTTPErrorExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerHTTPErrorExpectation]
                      timeout:5];
}

@end
