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
#import "NSError+CRErrors.h"
#import "CRBidToken+Internal.h"


@interface CRBannerViewDelegateTests : XCTestCase
{
    CR_CacheAdUnit *adUnit;
    CR_CdbBid *bid;
    WKNavigationResponse *validNavigationResponse;
}
@end

@implementation CRBannerViewDelegateTests

- (void)setUp {
    bid = nil;
    adUnit = nil;
}

- (CR_CacheAdUnit *)expectedAdUnit {
    if(!adUnit) {
        adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                     size:CGSizeMake(47.0f, 57.0f)];
    }
    return adUnit;
}

- (WKNavigationResponse *)validNavigationResponse {
    if(!validNavigationResponse) {
        validNavigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
        NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
        OCMStub(response.statusCode).andReturn(200);
        OCMStub(validNavigationResponse.response).andReturn(response);
    }
    return validNavigationResponse;
}

- (CR_CdbBid *)bidWithDisplayURL:(NSString *)displayURL {
    if(!bid) {
        bid = [[CR_CdbBid alloc] initWithZoneId:@123
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
    return bid;
}

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

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    [bannerView loadAd:@"123"];
    [bannerView webView:realWebView decidePolicyForNavigationResponse:[self validNavigationResponse] decisionHandler:^(WKNavigationResponsePolicy policy) {

    }];
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
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate banner:bannerView
                  didFailToLoadAdWithError:[OCMArg any]]);
    CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                             size:CGSizeMake(47.0f, 57.0f)];
    OCMStub([mockCriteo getBid:expectedAdUnit]).andReturn([CR_CdbBid emptyBid]);
    XCTestExpectation *bannerAdFetchFailExpectation = [self expectationWithDescription:@"bannerDidFail with error delegate method called"];
    [bannerView loadAd:@"123"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate banner:bannerView
                                                          didFailToLoadAdWithError:expectedError]);
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
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInternalError];
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate banner:bannerView
                  didFailToLoadAdWithError:[OCMArg any]]);
    XCTestExpectation *bannerWebViewNavigationFailExpectation = [self expectationWithDescription:@"bannerDidFail delegate method called"];
    [bannerView webView:nil didFailNavigation:nil
              withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate banner:bannerView
                                                          didFailToLoadAdWithError:expectedError]);
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
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInternalError];
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate banner:bannerView
                  didFailToLoadAdWithError:[OCMArg any]]);
    XCTestExpectation *bannerWebViewLoadExpectation = [self expectationWithDescription:@"bannerDidFail delegate method called"];
    [bannerView webView:nil didFailProvisionalNavigation:nil
              withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate banner:bannerView
                                                          didFailToLoadAdWithError:expectedError]);
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
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNetworkError];
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate banner:bannerView
                  didFailToLoadAdWithError:[OCMArg any]]);
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
                                          OCMVerify([mockBannerViewDelegate banner:bannerView
                                                          didFailToLoadAdWithError:expectedError]);
                                          [bannerHTTPErrorExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerHTTPErrorExpectation]
                      timeout:5];
}

- (void)testBannerFailWhenNoHttpResponse {
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                       application:nil];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate banner:bannerView
                  didFailToLoadAdWithError:[OCMArg any]]);
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNetworkError];

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self bidWithDisplayURL:@""]);
    [bannerView loadAd:@"123"];
    XCTestExpectation *bannerNoHTTPResponseExpectation = [self expectationWithDescription:@"bannerDidFail delegate method called"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate banner:bannerView
                                                          didFailToLoadAdWithError:expectedError]);
                                          [bannerNoHTTPResponseExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerNoHTTPResponseExpectation]
                      timeout:5];
}

# pragma inhouseSpecificTests

- (void)testBannerFailWhenTokenNotFound {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *mockWebView = [WKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                       application:nil];
    CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner]).andReturn(nil);
    id<CRBannerViewDelegate>mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate banner:bannerView
                  didFailToLoadAdWithError:[OCMArg any]]);
    [bannerView loadAdWithBidToken:token];
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    XCTestExpectation *bannerAdFetchFailExpectation = [self expectationWithDescription:@"bannerDidFail due to nil tokenValue with error delegate method called"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate banner:bannerView
                                                          didFailToLoadAdWithError:expectedError]);
                                          [bannerAdFetchFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerAdFetchFailExpectation]
                      timeout:5];
}

@end
