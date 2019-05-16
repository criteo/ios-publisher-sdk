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
#import "CRInterstitial.h"
#import "CRInterstitial+Internal.h"

@interface CRInterstitialViewControllerTests : XCTestCase

@end

@implementation CRInterstitialViewControllerTests

- (void)testCloseButtonInitialization {
    MockWKWebView *mockWebView = [MockWKWebView new];
    CR_InterstitialViewController *interstitial = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView interstitial:nil];
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
    UIWindow __block *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    MockWKWebView *mockWebView = [MockWKWebView new];

    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:mockWebView interstitial:nil];

    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:nil
                                                           viewController:interstitialVC
                                                              application:nil];
    XCTestExpectation __block *vcDismissedExpectation = [self expectationWithDescription:@"View Controller dismissed on close button click"];
    UIViewController *vc = [UIViewController new];
    window.rootViewController = vc;
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
                                                                                        [vcDismissedExpectation fulfill];
                                                                                    }
                                                                                }
                                               ];
                                          }
                                      }
     ];

    [self waitForExpectations:@[vcDismissedExpectation]
                      timeout:5];
}

@end
