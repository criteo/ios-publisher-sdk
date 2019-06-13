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

@interface CRInterstitialViewControllerTests : XCTestCase
{
    CR_CacheAdUnit *adUnit;
    CR_CdbBid *bid;
}
@end

@implementation CRInterstitialViewControllerTests

- (void)setUp {
    bid = nil;
    adUnit = nil;
}

- (CR_CacheAdUnit *)expectedAdUnit {
    if(!adUnit) {
        adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                     size:CGSizeMake(320.0, 480.0)];
    }
    return adUnit;
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

// iTest
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
    Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);

    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                                                              interstitial:nil];

    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil];
    XCTestExpectation __block *vcDismissedExpectation = [self expectationWithDescription:@"View Controller dismissed on close button click"];

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *vc = [UIViewController new];
    window.rootViewController = vc;

    CR_CdbBid *bid = [self bidWithDisplayURL:@""];

    id mockAdUnitHelper = OCMStrictClassMock([CR_AdUnitHelper class]);
    OCMStub([mockAdUnitHelper interstitialCacheAdUnitForAdUnitId:@"123"
                                                      screenSize:[[CR_DeviceInfo new] screenSize]]).andReturn([self expectedAdUnit]);

    OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn(bid);
    interstitialVC.interstitial = interstitial;
    [interstitial loadAd:@"123"];

    [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(interstitial.isAdLoaded) {
            [timer invalidate];
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
                                                                                        }];
                                                  }
                                              }];
        }
    }];

    [self waitForExpectations:@[vcDismissedExpectation]
                      timeout:5];
}

@end
