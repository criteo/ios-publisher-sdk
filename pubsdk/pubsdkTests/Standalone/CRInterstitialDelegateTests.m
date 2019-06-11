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
#import "CR_AdUnitHelper.h"

@interface CRInterstitialDelegateTests : XCTestCase
{
    CR_CacheAdUnit *adUnit;
    CR_CdbBid *bid;
}
@end

@implementation CRInterstitialDelegateTests

- (void)setUp {
    bid = nil;
    adUnit = nil;
}

- (CR_CdbBid *)expectedBid {
    if(!bid) {
        bid = [[CR_CdbBid alloc] initWithZoneId:@123
                                     placementId:@"placementId"
                                             cpm:@"4.2"
                                        currency:@"₹😀"
                                           width:@47.0f
                                          height:[NSNumber numberWithFloat:57.0f]
                                             ttl:26
                                        creative:@"THIS IS USELESS LEGACY"
                                      displayUrl:@""
                                      insertTime:[NSDate date]];
    }
    return bid;
}

- (CR_CacheAdUnit *)expectedAdUnit {
    if(!adUnit) {
        adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                    size:CGSizeMake(320.0, 480.0)];
    }
    return adUnit;
}

- (void)testInterstitialDidLoad {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *realWebView = [WKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil];
    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self expectedBid]);

    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[[CR_DeviceInfo new] screenSize]]).andReturn([self expectedAdUnit]);

    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitialDidLoadAd:interstitial]);

    XCTestExpectation *interstitialDidLoadExpectation = [self expectationWithDescription:@"InterstitialDidLoad delegate method called"];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          if(interstitial.isLoaded) {
                                              [timer invalidate];
                                              OCMVerify([mockInterstitialDelegate interstitialDidLoadAd:interstitial]);
                                              [interstitialDidLoadExpectation fulfill];
                                          }
                                      }];
    [interstitial loadAd:@"123"];
    [self waitForExpectations:@[interstitialDidLoadExpectation] timeout:5];
}

- (void)testInterstitialAdFetchFail {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                            viewController:nil
                                                               application:nil];
    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([CR_CdbBid emptyBid]);

    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeNoFill];
    interstitial.delegate = mockInterstitialDelegate;
    OCMStub([mockInterstitialDelegate interstitial:interstitial
                          didFailToLoadAdWithError:[OCMArg any]]);

    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[[CR_DeviceInfo new] screenSize]]).andReturn([self expectedAdUnit]);

    XCTestExpectation *interstitialAdFetchFailExpectation = [self expectationWithDescription:@"interstitialDidFail delegate method called"];
    [interstitial loadAd:@"123"];
    [NSTimer scheduledTimerWithTimeInterval:3
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
                                                              application:mockApplication];

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

// iTest
- (void)testInterstitialWillAppearAndDidAppear {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    WKWebView *realWebView = [WKWebView new];
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:realWebView
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil];
    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self expectedBid]);

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    [mockInterstitialDelegate setExpectationOrderMatters:YES];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialDidAppear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialDidAppear:interstitial]);

    UIViewController *rootViewController = [UIViewController new];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    window.rootViewController = rootViewController;
    [interstitial presentFromRootViewController:rootViewController];

    XCTestExpectation *interstitialPresentationExpectation = [self expectationWithDescription:@"InterstitialWillAppear and InterstitialDidAppear delegate methods called in order"];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          if(rootViewController && rootViewController.presentedViewController) {
                                              [timer invalidate];
                                              OCMVerify([mockInterstitialDelegate interstitialWillAppear:interstitial]);
                                              OCMVerify([mockInterstitialDelegate interstitialDidAppear:interstitial]);
                                              [interstitialPresentationExpectation fulfill];
                                          }
                                      }
     ];
    [self waitForExpectations:@[interstitialPresentationExpectation]
                      timeout:5];
}

// iTest
- (void)testInterstitialWillDisappearAndDidDisappear {
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:interstitialVC
                                                              application:nil];

    interstitialVC.interstitial = interstitial;
    UIViewController *rootViewController = [UIViewController new];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    window.rootViewController = rootViewController;

    id mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    [mockInterstitialDelegate setExpectationOrderMatters:YES];
    interstitial.delegate = mockInterstitialDelegate;
    OCMExpect([mockInterstitialDelegate interstitialWillAppear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialDidAppear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialWillDisappear:interstitial]);
    OCMExpect([mockInterstitialDelegate interstitialDidDisappear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialWillDisappear:interstitial]);
    OCMStub([mockInterstitialDelegate interstitialDidDisappear:interstitial]);

    [interstitial presentFromRootViewController:rootViewController];

    XCTestExpectation *interstitialDismissExpectation = [self expectationWithDescription:@"InterstitialWillDisappear and InterstitialDidDisappear delegate method called"];
    [NSTimer scheduledTimerWithTimeInterval:2
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          if(rootViewController && rootViewController.presentedViewController) {
                                              [timer invalidate];
                                              [interstitialVC.closeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                                              [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                              repeats:YES
                                                                                block:^(NSTimer * _Nonnull timer) {
                                                                                    if(rootViewController && !rootViewController.presentedViewController) {
                                                                                        [timer invalidate];
                                                                                        OCMVerify([mockInterstitialDelegate interstitialWillDisappear:interstitial]);
                                                                                        OCMVerify([mockInterstitialDelegate interstitialDidDisappear:interstitial]);
                                                                                        [interstitialDismissExpectation fulfill];
                                                                                    }
                                                                                }
                                               ];
                                          }
                                      }
     ];
    [self waitForExpectations:@[interstitialDismissExpectation]
                      timeout:5];
}

// test interstitial fail delegate method called when webView navigation fails
- (void)testInterstitialFailWhenWebViewFailsToNavigate {
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:interstitialVC
                                                              application:nil];

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
                                                              application:nil];
    id<CRInterstitialDelegate> mockInterstitialDelegate = OCMStrictProtocolMock(@protocol(CRInterstitialDelegate));
    NSError *expectedError = [NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter
                                        description:@"rootViewController parameter must not be null."];
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
    OCMStub(mockInterstitialVC.webView.navigationDelegate).andReturn(nil);
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                               viewController:mockInterstitialVC
                                                                  application:nil];
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

@end
