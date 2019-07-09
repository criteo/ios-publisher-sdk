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

@interface CRInterstitialDelegateTests : XCTestCase
{
    CR_CacheAdUnit *_cacheAdUnit;
    CRInterstitialAdUnit *_adUnit;
    CR_CdbBid *bid;
    WKNavigationResponse *validNavigationResponse;
}
@end

@implementation CRInterstitialDelegateTests

- (void)setUp {
    _cacheAdUnit = nil;
    _adUnit = nil;
    bid = nil;
    validNavigationResponse = nil;
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

- (CR_CacheAdUnit *)expectedCacheAdUnit {
    if(!_cacheAdUnit) {
        _cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                           size:CGSizeMake(320.0, 480.0)];
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

- (void)testInterstitialDidLoad {
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
    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[CR_DeviceInfo getScreenSize]]).andReturn([self expectedCacheAdUnit]);
    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitialDidLoadAd:interstitial]);
    OCMStub([mockWebView loadHTMLString:[self htmlString] baseURL:[NSURL URLWithString:@"about:blank"]]).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView decidePolicyForNavigationResponse:[self validNavigationResponse] decisionHandler:^(WKNavigationResponsePolicy policy) {

        }];
    }).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView didFinishNavigation:nil];
    });

    XCTestExpectation *interstitialDidLoadExpectation = [self expectationWithDescription:@"InterstitialDidLoad delegate method called"];
    [interstitial loadAd];
    if(interstitial.isAdLoaded) {
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                        repeats:NO
                                          block:^(NSTimer * _Nonnull timer) {
                                              OCMVerify([mockInterstitialDelegate interstitialDidLoadAd:interstitial]);
                                              [interstitialDidLoadExpectation fulfill];
                                          }];

    }
    [self waitForExpectations:@[interstitialDidLoadExpectation] timeout:5];
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
                          didFailToLoadAdWithError:[OCMArg any]]);

    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[CR_DeviceInfo getScreenSize]]).andReturn([self expectedCacheAdUnit]);

    XCTestExpectation *interstitialAdFetchFailExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called"];
    [interstitial loadAd];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
                                          [interstitialAdFetchFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialAdFetchFailExpectation]
                      timeout:5];
}

- (void)testInterstitialWillLeaveApplication {
    UIApplication *mockApplication = OCMStrictClassMock([UIApplication class]);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:nil
                                                              application:mockApplication
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitialWillLeaveApplication:interstitial]);

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

    XCTestExpectation *interstitialWillLeaveApplication = [self expectationWithDescription:@"interstitialWillLeaveApplication delegate method called"];
    [interstitial webView:nil decidePolicyForNavigationAction:mockNavigationAction
          decisionHandler:^(WKNavigationActionPolicy decisionHandler) {
    }];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitialWillLeaveApplication:interstitial]);
                                          [interstitialWillLeaveApplication fulfill];
                                      }];
    [self waitForExpectations:@[interstitialWillLeaveApplication]
                      timeout:5];
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

    OCMExpect([mockInterstitialDelegate interstitialDidLoadAd:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialDidAppear:interstitial]);

    OCMStub([mockInterstitialDelegate interstitialDidLoadAd:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialDidAppear:interstitial]);

    interstitialVC.interstitial = interstitial;
    UIViewController *rootViewController = OCMStrictClassMock([UIViewController class]);
    OCMStub([rootViewController presentViewController:interstitialVC animated:YES completion:[OCMArg invokeBlock]]);

    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[CR_DeviceInfo getScreenSize]]).andReturn([self expectedCacheAdUnit]);
    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    OCMStub([mockWebView loadHTMLString:[self htmlString] baseURL:[NSURL URLWithString:@"about:blank"]]).andDo(^(NSInvocation* args) {
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

// test interstitial fail delegate method called when webView navigation fails
- (void)testInterstitialFailWhenWebViewFailsToNavigate {
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInternalError];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToLoadAdWithError:[OCMArg any]]);

    XCTestExpectation *interstitialWebViewNavigationFailExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called"];
    [interstitial webView:nil
        didFailNavigation:nil
                withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
                                          [interstitialWebViewNavigationFailExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialWebViewNavigationFailExpectation]
                      timeout:5];
}

// test interstitial fail delegate method called when webView load fails
- (void)testInterstitialFailWhenWebViewFailsToLoad {
    CRInterstitial *interstitial = [CRInterstitial new];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInternalError];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToLoadAdWithError:[OCMArg any]]);

    XCTestExpectation *interstitialWebViewLoadExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called"];
    [interstitial webView:nil didFailProvisionalNavigation:nil
                withError:nil];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
                                          [interstitialWebViewLoadExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialWebViewLoadExpectation]
                      timeout:5];
}

// test interstitial fail delegate method called when HTTP error
- (void)testInterstitialFailWhenHTTPError {
    CRInterstitial *interstitial = [CRInterstitial new];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNetworkError];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToLoadAdWithError:[OCMArg any]]);

    XCTestExpectation *interstitialHTTPErrorExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called"];
    WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(404);
    OCMStub(navigationResponse.response).andReturn(response);
    [interstitial webView:nil decidePolicyForNavigationResponse:navigationResponse
          decisionHandler:^(WKNavigationResponsePolicy decisionHandler) {
        }];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
                                          [interstitialHTTPErrorExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialHTTPErrorExpectation]
                      timeout:5];
}

// test no delegate method called when 3xx HTTP status code
- (void)testNoDelegateMethodCalled {
    CRInterstitial *interstitial = [CRInterstitial new];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;

    XCTestExpectation *interstitialHTTPErrorExpectation = [self expectationWithDescription:@"interstitial delegate methods not called"];
    WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(301);
    OCMStub(navigationResponse.response).andReturn(response);
    [interstitial webView:nil decidePolicyForNavigationResponse:navigationResponse
          decisionHandler:^(WKNavigationResponsePolicy decisionHandler) {
          }];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          [interstitialHTTPErrorExpectation fulfill];
                                      }];
    [self waitForExpectations:@[interstitialHTTPErrorExpectation]
                      timeout:5];
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
                          didFailToLoadAdWithError:[OCMArg any]]);
    [interstitial presentFromRootViewController:nil];
    XCTestExpectation *rootVCNilExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called with invalid parameter error"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
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
                          didFailToLoadAdWithError:[OCMArg any]]);

    OCMStub([mockInterstitialVC presentingViewController]).andReturn([UIViewController new]);
    [interstitial presentFromRootViewController:nil];
    XCTestExpectation *adBeingPresentedExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called with invalid request error"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
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
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                 description:@"Interstitial Ad is not loaded."];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToLoadAdWithError:[OCMArg any]]);

    OCMStub(mockInterstitialVC.presentingViewController).andReturn(nil);
    UIViewController *rootViewController = [UIViewController new];
    [interstitial presentFromRootViewController:rootViewController];

    XCTestExpectation *adNotLoadedExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called with invalid request error"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
                                          [adNotLoadedExpectation fulfill];
                                      }];
    [self waitForExpectations:@[adNotLoadedExpectation]
                      timeout:5];
}

- (void)testInterstitialFailWhenNoHttpResponse {
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
    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[CR_DeviceInfo getScreenSize]]).andReturn([self expectedCacheAdUnit]);
    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@""]);

    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial didFailToLoadAdWithError:[OCMArg any]]);
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNetworkError];

    XCTestExpectation *interstitialNoHttpResponseExpectation = [self expectationWithDescription:@"InterstitialDidFail delegate method called"];
    [NSTimer scheduledTimerWithTimeInterval:3
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
                                          XCTAssertFalse(interstitial.isAdLoaded);
                                          OCMVerify([mockInterstitialDelegate interstitial:interstitial
                                                                  didFailToLoadAdWithError:expectedError]);
                                          [interstitialNoHttpResponseExpectation fulfill];
                                      }];
    [interstitial loadAd];
    [self waitForExpectations:@[interstitialNoHttpResponseExpectation] timeout:5];
}

- (void)testInterstitialFailWhenAdIsBeingLoaded {
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
    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[CR_DeviceInfo getScreenSize]]).andReturn([self expectedCacheAdUnit]);
    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest
                                                 description:@"An Ad is already being loaded."];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitial:interstitial
                          didFailToLoadAdWithError:expectedError]);

    [interstitial loadAd];
    XCTAssertTrue([interstitial isAdLoading]);
    [interstitial loadAd];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialLoadFailWhenAdIsBeingPresented {
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
                          didFailToLoadAdWithError:expectedError]);

    OCMStub([mockInterstitialVC presentingViewController]).andReturn([UIViewController new]);
    [interstitial loadAd];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

- (void)testInterstitialLoadFailWhenTokenValueIsNil {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:nil
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];
    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    OCMStub([mockCriteo tokenValueForBidToken:bidToken
                                   adUnitType:CRAdUnitTypeInterstitial]).andReturn(nil);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitial:interstitial
                          didFailToLoadAdWithError:expectedError]);
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
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:NO
                                                                   adUnit:self.adUnit];

    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"test"
                                                                       insertTime:[NSDate date]
                                                                              ttl:200
                                                                       adUnitType:CRAdUnitTypeInterstitial];
    OCMStub([mockCriteo tokenValueForBidToken:bidToken
                                   adUnitType:CRAdUnitTypeInterstitial]).andReturn(expectedTokenValue);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialDidLoadAd:interstitial]);
    OCMStub([mockWebView loadHTMLString:[self htmlString] baseURL:[NSURL URLWithString:@"about:blank"]]).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView decidePolicyForNavigationResponse:[self validNavigationResponse] decisionHandler:^(WKNavigationResponsePolicy policy) {

        }];
    }).andDo(^(NSInvocation* args) {
        [interstitial webView:mockWebView didFinishNavigation:nil];
    });
    [interstitial loadAdWithBidToken:bidToken];
    OCMVerifyAllWithDelay(mockInterstitialDelegate, 1);
}

@end
