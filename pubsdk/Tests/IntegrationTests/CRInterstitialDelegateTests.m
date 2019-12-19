//
//  CRInterstitialDelegateTest.m
//  pubsdkTests
//
//  Created by Julien Stoeffler on 5/10/19.
//  Inspired by Sneha Pathrose
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CRInterstitial.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRInterstitial+Internal.h"
#import "CRInterstitialDelegate.h"
#import "CR_CdbBid.h"
#import "NSError+CRErrors.h"
#import "CR_DeviceInfo.h"
#import "CR_AdUnitHelper.h"
#import "CRBidToken+Internal.h"
#import "CR_TokenValue.h"
#import "CR_Config.h"
#import "CRBannerAdUnit.h"
#import "CR_InterstitialViewController.h"

@interface CRInterstitialDelegateTests : XCTestCase
{
    CR_CacheAdUnit *_cacheAdUnit;
    CRInterstitialAdUnit *_adUnit;
    CR_CdbBid *bid;
    WKNavigationResponse *validNavigationResponse;
    WKNavigationResponse *invalidNavigationResponse;
}
@end

@implementation CRInterstitialDelegateTests

- (void)setUp {
    _cacheAdUnit = nil;
    _adUnit = nil;
    bid = nil;
    validNavigationResponse = nil;
    invalidNavigationResponse = nil;
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

- (CR_CacheAdUnit *)expectedCacheAdUnit {
    if(!_cacheAdUnit) {
        _cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                           size:CGSizeMake(320.0, 480.0)
                                                     adUnitType:CRAdUnitTypeInterstitial];
    }
    return _cacheAdUnit;
}

- (CRInterstitialAdUnit *)adUnit {
    if (!_adUnit) {
        _adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"123"];
    }
    return _adUnit;
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

- (WKNavigationResponse *)invalidNavigationResponse {
    if(!invalidNavigationResponse) {
        invalidNavigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
        NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
        OCMStub(response.statusCode).andReturn(404);
        OCMStub(invalidNavigationResponse.response).andReturn(response);
    }
    return invalidNavigationResponse;
}

- (NSString *)htmlString {
    return [NSString stringWithFormat:@"<!doctype html>"
                  "<html>"
                  "<head>"
                  "<meta charset=\"utf-8\">"
                  "<style>body{margin:0;padding:0}</style>"
                  "<meta name=\"viewport\" content=\"width=%ld, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\" >"
                  "</head>"
                  "<body>"
                  "<script src=\"%@\"></script>"
                  "</body>"
                  "</html>", (long)[UIScreen mainScreen].bounds.size.width,@"test"];
}

- (void)testInterstitialDidReceiveAd {
    // create mock objects
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *mockWebView = OCMClassMock([WKWebView class]);
    UIView *mockView = OCMClassMock([UIView class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:mockView
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    // stub methods for loadAd
    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMStub([mockWebView loadHTMLString:[self htmlString] baseURL:[NSURL URLWithString:@"https://criteo.com"]]).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView decidePolicyForNavigationResponse:[self validNavigationResponse] decisionHandler:^(WKNavigationResponsePolicy policy) {

        }];
    }).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView didFinishNavigation:nil];
    });

    [interstitial loadAd];
    XCTAssertTrue(interstitial.isAdLoaded);
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialAdFetchFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                            viewController:nil
                                                               application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([CR_CdbBid emptyBid]);

    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToReceiveAdWithError:[OCMArg any]]);

    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    XCTestExpectation *interstitialAdFetchFailExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called"];
    [interstitial loadAd];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToReceiveAdWithError:expectedError]);
                                          [interstitialAdFetchFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialAdFetchFailExpectation]
                      timeout:5];
}

- (void)testInterstitialWillLeaveApplicationAndWasClicked {
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:nil
                                                              application:mockApplication
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialWillLeaveApplication:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialWasClicked:interstitial]);

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

    [interstitial webView:nil decidePolicyForNavigationAction:mockNavigationAction
          decisionHandler:^(WKNavigationActionPolicy decisionHandler) {
    }];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialWillAndDidAppear {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *mockWebView = OCMClassMock([WKWebView class]);
    UIView *mockView = OCMClassMock([UIView class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:mockView
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    [mockInterstitialDelegate setExpectationOrderMatters:YES];
    interstitial.delegate = mockInterstitialDelegate;

    OCMExpect([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialDidAppear:interstitial]);

    OCMStub([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialDidAppear:interstitial]);

    interstitialVC.interstitial = interstitial;
    UIViewController *rootViewController = OCMStrictClassMock([UIViewController class]);
    OCMStub([rootViewController presentViewController:interstitialVC animated:YES completion:[OCMArg invokeBlock]]);

    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    OCMStub([mockWebView loadHTMLString:[self htmlString] baseURL:[NSURL URLWithString:@"https://criteo.com"]]).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView decidePolicyForNavigationResponse:[self validNavigationResponse] decisionHandler:^(WKNavigationResponsePolicy policy) {

        }];
    }).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView didFinishNavigation:nil];
    });

     XCTestExpectation *interstitialPresentationExpectation = [self expectationWithDescription:@"InterstitialWillAppear and InterstitialDidAppear delegate methods called in order"];
    [interstitial loadAd];
    if(interstitial.isAdLoaded) {
        [interstitial presentFromRootViewController:rootViewController];
        [NSTimer scheduledTimerWithTimeInterval:2
                                        repeats:NO
                                          block:^(NSTimer * _Nonnull timer) {
                                              OCMVerify([mockInterstitialDelegate interstitialWillAppear:interstitial]);
                                              OCMVerify([mockInterstitialDelegate interstitialDidAppear:interstitial]);
                                              [interstitialPresentationExpectation fulfill];
                                          }];
    }
    [self waitForExpectations:@[interstitialPresentationExpectation]
                      timeout:5];

}

- (void)testInterstitialWillandDidDisappear {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:YES
                                                                   adUnit:self.adUnit];

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    [mockInterstitialDelegate setExpectationOrderMatters:YES];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialDidAppear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialWillDisappear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialDidDisappear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialDidAppear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialWillDisappear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialDidDisappear:interstitial]);

    XCTestExpectation *interstitialDismissExpectation = [self expectationWithDescription:@"InterstitialWillDisappear and InterstitialDidDisappear delegate method called"];

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *vc = [UIViewController new];
    window.rootViewController = vc;
    interstitialVC.interstitial = interstitial;

    [interstitial presentFromRootViewController:vc];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          if(vc && vc.presentedViewController) {
                                              [timer invalidate];
                                              [interstitialVC.closeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                                              [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                              repeats:YES
                                                                                block:^(NSTimer * _Nonnull timer) {
                                                                                    if(vc && !vc.presentedViewController) {
                                                                                        [timer invalidate];
                                                                                        OCMVerify([mockInterstitialDelegate interstitialWillDisappear:interstitial]);
                                                                                        OCMVerify([mockInterstitialDelegate interstitialDidDisappear:interstitial]);
                                                                                        [interstitialDismissExpectation fulfill];
                                                                                    }
                                                                                }];
                                          }
                                      }];

    [self waitForExpectations:@[interstitialDismissExpectation]
                      timeout:5];
}

- (void)testDidFailToReceiveAdContentWithErrorWhenWebViewFailsToNavigate {
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMReject([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);

    XCTestExpectation *interstitialWebViewNavigationFailExpectation = [self expectationWithDescription:@"didFailToReceiveAdContentWithError delegate method called"];
    [interstitial webView:nil
        didFailNavigation:nil
                withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [interstitialWebViewNavigationFailExpectation fulfill];
                                          OCMVerify(mockInterstitialDelegate);
                                      }];
    [self waitForExpectations:@[interstitialWebViewNavigationFailExpectation]
                      timeout:3];
}

- (void)testDidFailToReceiveAdContentWithErrorWebViewFailsToLoad {
    CRInterstitial *interstitial = [CRInterstitial new];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMReject([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);

    OCMStub([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);

    XCTestExpectation *interstitialWebViewLoadExpectation = [self expectationWithDescription:@"didFailToReceiveAdContentWithError delegate method called"];
    [interstitial webView:nil didFailProvisionalNavigation:nil
                withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [interstitialWebViewLoadExpectation fulfill];
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);
                                      }];
    [self waitForExpectations:@[interstitialWebViewLoadExpectation]
                      timeout:3];
}

// test no delegate method called when HTTP error
// Test no delegate methods are called from WKNavigationDelegate's decidePolicyForNavigationResponse
// when there's an HTTP error
// This only tests what happens inside decidePolicyForNavigationResponse
// The AdNetwork response delegates are fired in loadAd* and
// WKNavigationDelegate's didFinishNavigation and didFail*Navigation.
// That's why we reject(interstitialDidReceiveAd) eventhough decidePolicyForNavigationResponse will only
// be called if we have an ad in the cache (this fires the interstitialDidReceiveAd callback) that needs to be rendered by the view.
// Similarly all the other calls are also rejected eventhough they maybe fired via the loadAd* route
- (void)testNoDelegateWhenHTTPError {
    CRInterstitial *interstitial = [CRInterstitial new];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMReject([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);


    XCTestExpectation *interstitialHTTPErrorExpectation = [self expectationWithDescription:@"no delegate method called"];
    WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(404);
    OCMStub(navigationResponse.response).andReturn(response);
    [interstitial webView:nil decidePolicyForNavigationResponse:navigationResponse
          decisionHandler:^(WKNavigationResponsePolicy decisionHandler) {
        }];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [interstitialHTTPErrorExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialHTTPErrorExpectation]
                      timeout:3];
}

// Test no delegate methods are called from WKNavigationDelegate's decidePolicyForNavigationResponse
// when 3xx HTTP status code
// This only tests what happens inside decidePolicyForNavigationResponse
// The AdNetwork response delegates are fired in loadAd* and
// WKNavigationDelegate's didFinishNavigation and didFail*Navigation.
// That's why we reject(interstitialDidReceiveAd) eventhough decidePolicyForNavigationResponse will only
// be called if we have an ad in the cache (this fires the interstitialDidReceiveAd callback) that needs to be rendered by the view.
// Similarly all the other calls are also rejected eventhough they maybe fired via the loadAd* route
- (void)testNoDelegateMethodCalledInDecidePolicyForNavigationResponse {
    CRInterstitial *interstitial = [CRInterstitial new];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMReject([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);

    XCTestExpectation *interstitialHTTPErrorExpectation = [self expectationWithDescription:@"interstitial delegate methods not called"];
    WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(301);
    OCMStub(navigationResponse.response).andReturn(response);
    [interstitial webView:nil decidePolicyForNavigationResponse:navigationResponse
          decisionHandler:^(WKNavigationResponsePolicy decisionHandler) {
          }];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [interstitialHTTPErrorExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialHTTPErrorExpectation]
                      timeout:3];
}

- (void)testInterstitialFailWhenRootViewControllerIsNil {
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:nil
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter
                                        description:@"rootViewController parameter must not be nil."];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);
    [interstitial presentFromRootViewController:nil];
    XCTestExpectation *rootVCNilExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called with invalid parameter error"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToReceiveAdWithError:expectedError]);
                                          [rootVCNilExpectation fulfill];
                                      }];
    [self waitForExpectations:@[rootVCNilExpectation]
                      timeout:5];
}

- (void)testInterstitialFailWhenAdIsBeingPresented {
    CR_InterstitialViewController *mockInterstitialVC = OCMStrictClassMock([CR_InterstitialViewController class]);
    OCMStub(mockInterstitialVC.webView).andReturn(nil);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                               viewController:mockInterstitialVC
                                                                  application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                        description:@"An Ad is already being presented."];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToReceiveAdWithError:[OCMArg any]]);

    OCMStub([mockInterstitialVC presentingViewController]).andReturn([UIViewController new]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);

    [interstitial presentFromRootViewController:nil];
    XCTestExpectation *adBeingPresentedExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called with invalid request error"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToReceiveAdWithError:expectedError]);
                                          [adBeingPresentedExpectation fulfill];
                                      }];
    [self waitForExpectations:@[adBeingPresentedExpectation]
                      timeout:5];

}

- (void)testInterstitialPresentationFailWhenAdNotLoaded {
    CR_InterstitialViewController *mockInterstitialVC = OCMStrictClassMock([CR_InterstitialViewController class]);
    OCMStub(mockInterstitialVC.webView).andReturn(nil);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:mockInterstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                 description:@"Interstitial Ad is not loaded."];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:expectedError]);

    OCMStub(mockInterstitialVC.presentingViewController).andReturn(nil);
    UIViewController *rootViewController = [UIViewController new];
    [interstitial presentFromRootViewController:rootViewController];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

// test the only delegate called is didReceiveAd: when no HTTP response
- (void)testDidReceiveAdWhenNoHttpResponse {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *realWebView = [WKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);

    [interstitial loadAd];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialFailWhenAnotherAdIsBeingLoaded {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *realWebView = [WKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                 description:@"An Ad is already being loaded."];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);

    [interstitial loadAd];
    XCTAssertTrue([interstitial isAdLoading]);
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
    OCMExpect([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:expectedError]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);
    [interstitial loadAd];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialLoadFailWhenAnotherAdIsBeingPresented {
    CR_InterstitialViewController *mockInterstitialVC = OCMStrictClassMock([CR_InterstitialViewController class]);
    OCMStub(mockInterstitialVC.webView).andReturn(nil);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:mockInterstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                 description:@"Ad cannot load as another is already being presented."];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToReceiveAdWithError:expectedError]);

    OCMStub([mockInterstitialVC presentingViewController]).andReturn([UIViewController new]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);
    [interstitial loadAd];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialLoadFailWhenTokenValueIsNil {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRInterstitialAdUnit *adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yup"];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:nil
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:adUnit];
    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    OCMStub([mockCriteo tokenValueForBidToken:bidToken
                                   adUnitType:CRAdUnitTypeInterstitial]).andReturn(nil);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:expectedError]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);
    [interstitial loadAdWithBidToken:bidToken];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialLoadFailWhenTokenValueDoesntMatchAdUnitId {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRInterstitialAdUnit *adUnit1 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yup"];
    CRInterstitialAdUnit *adUnit2 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yo"];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:nil
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:adUnit1];
    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"test"
                                                                       insertTime:[NSDate date]
                                                                              ttl:200
                                                                           adUnit:adUnit2];
    OCMStub([mockCriteo tokenValueForBidToken:bidToken
                                   adUnitType:CRAdUnitTypeInterstitial]).andReturn(expectedTokenValue);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter description:
                              @"Token passed to loadAdWithBidToken doesn't have the same ad unit as the CRInterstitial was initialized with"];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:expectedError]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);
    [interstitial loadAdWithBidToken:bidToken];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialLoadFailWhenTokenValueDoesntMatchAdUnitType {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRInterstitialAdUnit *adUnit1 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yo"];
    CRBannerAdUnit       *adUnit2 = [[CRBannerAdUnit alloc]       initWithAdUnitId:@"Yo" size:CGSizeMake(200, 200)];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:nil
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:adUnit1];
    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"test"
                                                                       insertTime:[NSDate date]
                                                                              ttl:200
                                                                           adUnit:adUnit2];
    OCMStub([mockCriteo tokenValueForBidToken:bidToken
                                   adUnitType:CRAdUnitTypeInterstitial]).andReturn(expectedTokenValue);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter description:
                              @"Token passed to loadAdWithBidToken doesn't have the same ad unit as the CRInterstitial was initialized with"];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitial:interstitial
                         didFailToReceiveAdWithError:expectedError]);
    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);
    [interstitial loadAdWithBidToken:bidToken];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialDidLoadForValidTokenValue {
    // create mock objects
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *mockWebView = OCMClassMock([WKWebView class]);
    UIView *mockView = OCMClassMock([UIView class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:mockView
                                                                                              interstitial:nil];
    CRInterstitialAdUnit *adUnit1 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yo"];
    CRInterstitialAdUnit *adUnit2 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yo"];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:adUnit1];

    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"test"
                                                                       insertTime:[NSDate date]
                                                                              ttl:200
                                                                           adUnit:adUnit2];
    OCMStub([mockCriteo tokenValueForBidToken:bidToken
                                   adUnitType:CRAdUnitTypeInterstitial]).andReturn(expectedTokenValue);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);

    OCMStub([mockWebView loadHTMLString:[self htmlString] baseURL:[NSURL URLWithString:@"https://criteo.com"]]).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView decidePolicyForNavigationResponse:[self validNavigationResponse]
              decisionHandler:^(WKNavigationResponsePolicy policy) {}];
    }).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView didFinishNavigation:nil];
    });

    [interstitial loadAdWithBidToken:bidToken];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testCacheHasAdButAdContentFetchFailed {
    // create mock objects
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    WKWebView *mockWebView = OCMClassMock([WKWebView class]);
    UIView *mockView = OCMClassMock([UIView class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:mockView
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    // stub methods for loadAd
    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 480));

    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialDidReceiveAd:interstitial]);
    OCMReject([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdWithError:[OCMArg any]]);

    OCMReject([mockInterstitialDelegate interstitialIsReadyToPresent:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitial:interstitial didFailToReceiveAdContentWithError:[OCMArg any]]);
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNetworkError description:@"Ad request failed due to network error"];
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                       didFailToReceiveAdWithError:expectedError]);
    OCMStub([mockWebView loadHTMLString:[self htmlString] baseURL:[NSURL URLWithString:@"https://criteo.com"]]).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView decidePolicyForNavigationResponse:[self invalidNavigationResponse] decisionHandler:^(WKNavigationResponsePolicy policy) {

        }];
    }).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView didFinishNavigation:nil];
    });

    [interstitial loadAd];
    XCTAssertFalse(interstitial.isAdLoaded);
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

@end
