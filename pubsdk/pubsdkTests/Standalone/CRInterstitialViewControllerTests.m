//
//  CRInterstitialViewControllerTests.m
//  pubsdkTests
//
//  Created by Sneha Pathrose on 4/24/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "MockWKWebView.h"
#import "CR_InterstitialViewController.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbBid.h"
#import "CRInterstitial.h"
#import "CRInterstitial+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CRInterstitialAdUnit.h"

@interface CRInterstitialViewControllerTests : XCTestCase
{
    CRInterstitialAdUnit *_adUnit;
}
@end

@implementation CRInterstitialViewControllerTests

- (void)setUp {
    _adUnit = nil;
}

- (CRInterstitialAdUnit *)adUnit {
    if(!_adUnit) {
        _adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"123"];
    }
    return _adUnit;
}

- (void)testCloseButtonInitialization {
    MockWKWebView *mockWebView = [MockWKWebView new];
    CR_InterstitialViewController *interstitial = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                    view:nil
                                                                                            interstitial:nil];
    XCTAssertNotNil(interstitial.view);
    XCTAssertNotNil(interstitial.closeButton);
    XCTAssertEqual(interstitial.closeButton.superview, interstitial.view);
    XCTAssert([[interstitial.closeButton actionsForTarget:interstitial
                                          forControlEvent:UIControlEventTouchUpInside] containsObject:@"dismissViewController"]);
    XCTAssertNotNil([interstitial.closeButton.layer.sublayers objectAtIndex:0]);
    CAShapeLayer *circleLayer = [interstitial.closeButton.layer.sublayers objectAtIndex:0];
    XCTAssertEqual([circleLayer fillColor] , [UIColor blackColor].CGColor);
    XCTAssertEqual([circleLayer strokeColor], [UIColor whiteColor].CGColor);
    XCTAssertEqual(circleLayer.lineWidth, 1.0);
    XCTAssertNotNil([interstitial.closeButton.layer.sublayers objectAtIndex:1]);
    CAShapeLayer *xLayer = [interstitial.closeButton.layer.sublayers objectAtIndex:1];
    XCTAssertEqual([xLayer strokeColor] , [UIColor whiteColor].CGColor);
    XCTAssertEqual([xLayer lineWidth] , 3.0);
}

- (void)testCloseButtonClick {
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                                      view:nil
                                                                                              interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:YES
                                                                   adUnit:self.adUnit];
    XCTestExpectation *vcDismissedExpectation = [self expectationWithDescription:@"View Controller dismissed on close button click"];

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *vc = [UIViewController new];
    window.rootViewController = vc;
    interstitialVC.interstitial = interstitial;

    [interstitial presentFromRootViewController:vc];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          if(vc && vc.presentedViewController) {
                                              [interstitialVC.closeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                                              [timer invalidate];
                                              [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                              repeats:YES
                                                                                block:^(NSTimer * _Nonnull timer) {
                                                                                    if(vc && !vc.presentedViewController) {
                                                                                        [timer invalidate];
                                                                                        XCTAssertNil(interstitialVC.webView);
                                                                                        XCTAssertNil(interstitialVC.closeButton);
                                                                                        XCTAssertEqual([interstitialVC.view subviews].count, 0);
                                                                                        XCTAssertFalse([interstitial isAdLoaded]);
                                                                                        [vcDismissedExpectation fulfill];
                                                                                    }
                                                                                }];
                                          }
                                      }];

    [self waitForExpectations:@[vcDismissedExpectation]
                      timeout:5];
}

- (void)testDismissAfterSevenSeconds {
    UIWindow __block *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    MockWKWebView *mockWebView = [MockWKWebView new];

    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView
                                                                                                      view:nil
                                                                                              interstitial:nil];

    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:YES
                                                                   adUnit:self.adUnit];
    XCTestExpectation __block *vcDismissedExpectation = [self expectationWithDescription:@"View Controller dismissed after seven seconds"];
    UIViewController *vc = [UIViewController new];
    window.rootViewController = vc;
    [interstitial presentFromRootViewController:vc];

    //8.5 seconds alloted for the view to display and automatically close itself.
    NSDate *start = [NSDate date];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                    repeats:YES
                                      block:^(NSTimer * _Nonnull timer) {
                                          if(vc && !vc.presentedViewController) {
                                              [timer invalidate];
                                              [vcDismissedExpectation fulfill];
                                              NSDate * finish = [NSDate date];
                                              NSTimeInterval interstitialLifeTime = [finish timeIntervalSinceDate:start];
                                              NSLog(@"Interstitial lifetime was %f", interstitialLifeTime);
                                              XCTAssertTrue(interstitialLifeTime < 8.5 && interstitialLifeTime > 7.0);
                                          }
                                      }
     ];

    [self waitForExpectations:@[vcDismissedExpectation]
                      timeout:9];
}

@end
