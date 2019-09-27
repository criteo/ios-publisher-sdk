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
#import "CRBannerAdUnit.h"
#import "CR_Config.h"

@interface CRBannerViewDelegateTests : XCTestCase
{
    CR_CacheAdUnit *cacheAdUnit;
    CRBannerAdUnit *adUnit;
    CR_CdbBid *bid;
    WKNavigationResponse *validNavigationResponse;
}
@end

@implementation CRBannerViewDelegateTests

- (void)setUp {
    bid = nil;
    cacheAdUnit = nil;
    adUnit = nil;
}

- (CR_CacheAdUnit *)expectedAdUnit {
    if(!cacheAdUnit) {
        cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                          size:CGSizeMake(47.0f, 57.0f)
                                                    adUnitType:CRAdUnitTypeBanner];
    }
    return cacheAdUnit;
}

- (CRBannerAdUnit *)adUnit {
    if(!adUnit) {
        adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"123"
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
                                     insertTime:[NSDate date]
                                    nativeAssets:nil];
    }
    return bid;
}

- (void)testBannerDidReceiveAd {
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                       application:nil
                                                            adUnit:self.adUnit];
    id mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMExpect([mockBannerViewDelegate bannerDidReceiveAd:bannerView]);

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    [bannerView loadAd];
    OCMVerifyAllWithDelay(mockBannerViewDelegate, 1);
}

// test banner fail when an empty bid is returned
- (void)testBannerAdFetchFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:nil
                                                       application:nil
                                                            adUnit:self.adUnit];

    id mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    bannerView.delegate = mockBannerViewDelegate;
    OCMExpect([mockBannerViewDelegate banner:bannerView
                 didFailToReceiveAdWithError:expectedError]);
    CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                         size:CGSizeMake(47.0f, 57.0f)
                                                                   adUnitType:CRAdUnitTypeBanner];
    OCMStub([mockCriteo getBid:expectedAdUnit]).andReturn([CR_CdbBid emptyBid]);
    [bannerView loadAd];
    OCMVerifyAllWithDelay(mockBannerViewDelegate, 1);
}

- (void)testBannerWillLeaveApplication {
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:mockApplication
                                                            adUnit:self.adUnit];
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

// test no delegate method called when webView navigation fails
- (void)testNoDelegateWhenWebViewFailsToNavigate {
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:nil
                                                            adUnit:self.adUnit];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMReject([mockBannerViewDelegate banner:bannerView
                 didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockBannerViewDelegate bannerDidReceiveAd:bannerView]);
    XCTestExpectation *bannerWebViewNavigationFailExpectation = [self expectationWithDescription:@"No delegate methods are called"];
    [bannerView webView:nil didFailNavigation:nil
              withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [bannerWebViewNavigationFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerWebViewNavigationFailExpectation]
                      timeout:3];
}

// test no delegate method called when webView load fails
- (void)testNoDelegateWhenWebViewFailsToLoad {
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:nil
                                                            adUnit:self.adUnit];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMReject([mockBannerViewDelegate banner:bannerView
                 didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockBannerViewDelegate bannerDidReceiveAd:bannerView]);
    XCTestExpectation *bannerWebViewLoadExpectation = [self expectationWithDescription:@"No delegate methods are called"];
    [bannerView webView:nil didFailProvisionalNavigation:nil
              withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [bannerWebViewLoadExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerWebViewLoadExpectation]
                      timeout:3];
}

// test no delegate method called when HTTP error
- (void)testNoDelegateWhenHTTPError {
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:nil
                                                           webView:nil
                                                       application:nil
                                                            adUnit:self.adUnit];
    id<CRBannerViewDelegate> mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMReject([mockBannerViewDelegate banner:bannerView
                 didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockBannerViewDelegate bannerDidReceiveAd:bannerView]);
    XCTestExpectation *bannerHTTPErrorExpectation = [self expectationWithDescription:@"No delegate methods are called"];
    WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(404);
    OCMStub(navigationResponse.response).andReturn(response);
    [bannerView webView:nil decidePolicyForNavigationResponse:navigationResponse
        decisionHandler:^(WKNavigationResponsePolicy decisionHandler) {
        }];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [bannerHTTPErrorExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerHTTPErrorExpectation]
                      timeout:3];
}

- (void)testNoDelegateWhenNoHttpResponse {
    WKWebView *realWebView = [WKWebView new];
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:realWebView
                                                       application:nil
                                                            adUnit:self.adUnit];
    id mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMExpect([mockBannerViewDelegate bannerDidReceiveAd:bannerView]);

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self bidWithDisplayURL:@""]);
    [bannerView loadAd];
    OCMVerifyAllWithDelay(mockBannerViewDelegate, 1);
}

# pragma mark inhouseSpecificTests

- (void)testBannerFailWhenTokenNotFound {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *mockWebView = [WKWebView new];
    CRBannerView *bannerView = [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                                            criteo:mockCriteo
                                                           webView:mockWebView
                                                       application:nil
                                                            adUnit:self.adUnit];
    CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner]).andReturn(nil);
    id<CRBannerViewDelegate>mockBannerViewDelegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
    bannerView.delegate = mockBannerViewDelegate;
    OCMStub([mockBannerViewDelegate banner:bannerView
                  didFailToReceiveAdWithError:[OCMArg any]]);
    [bannerView loadAdWithBidToken:token];
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    XCTestExpectation *bannerAdFetchFailExpectation = [self expectationWithDescription:@"bannerDidFail due to nil tokenValue with error delegate method called"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockBannerViewDelegate banner:bannerView
                                                          didFailToReceiveAdWithError:expectedError]);
                                          [bannerAdFetchFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[bannerAdFetchFailExpectation]
                      timeout:5];
}

@end
