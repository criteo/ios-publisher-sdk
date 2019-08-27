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
#import "CR_Config.h"

@interface CR_InterstitialViewController () {
    BOOL _hasBeenDismissed;
}

@property (nonatomic, strong) dispatch_block_t timeoutDismissBlock;

@end

@interface CRInterstitialViewControllerTests : XCTestCase

@property (nonatomic, strong) CRInterstitialAdUnit *adUnit;
@property (nonatomic, strong) CR_CacheAdUnit *cacheAdUnit;

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
    [interstitial viewDidAppear:YES];
    XCTAssertNotNil(interstitial.view);
    XCTAssertNotNil(interstitial.closeButton);
    XCTAssertEqual(interstitial.closeButton.superview, interstitial.view);
    XCTAssert([[interstitial.closeButton actionsForTarget:interstitial
                                          forControlEvent:UIControlEventTouchUpInside] containsObject:@"closeButtonPressed"]);
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
    [NSTimer scheduledTimerWithTimeInterval:1.0
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"

- (CR_CacheAdUnit *)expectedCacheAdUnit {
    if(!_cacheAdUnit) {
        _cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                           size:CGSizeMake(360, 640)];
    }
    return _cacheAdUnit;
}

// In the following we want to make sure
- (void)testCloseButtonClickCancelsDismissTimer {
    Criteo *mockCriteo = OCMClassMock([Criteo class]);
    OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
    NSString *displayURL = @"https://www.nytimes.com/";

    CR_CdbBid *bid = [[CR_CdbBid alloc] initWithZoneId:@123
                                           placementId:@"placementId"
                                                   cpm:@"4.2"
                                              currency:@"₹😀"
                                                 width:@360.0f
                                                height:[NSNumber numberWithFloat:640.0f]
                                                   ttl:26
                                              creative:@"THIS IS USELESS LEGACY"
                                            displayUrl:displayURL
                                            insertTime:[NSDate date]];

    NSLog(@"+++ [self expectedCacheAdUnit] = %@", [self expectedCacheAdUnit]);
    OCMStub([mockCriteo getBid:[self expectedCacheAdUnit]]).andReturn(bid);

    CR_InterstitialViewController *interstitialVC = [[CR_InterstitialViewController alloc]
                                                     initWithWebView:[WKWebView new]
                                                                view:nil
                                                        interstitial:nil];
    CRInterstitial *interstitial = [[CRInterstitial alloc] initWithCriteo:mockCriteo
                                                           viewController:interstitialVC
                                                              application:nil
                                                               isAdLoaded:YES
                                                                   adUnit:self.adUnit];

    XCTestExpectation *expectation = [self expectationWithDescription:@""];

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *vc = [UIViewController new];
    window.rootViewController = vc;
    interstitialVC.interstitial = interstitial;
    [interstitial presentFromRootViewController:vc];

    void (^verifyAdLoaded)(void) = ^() {
        XCTAssertNotNil(interstitialVC.webView);
        XCTAssertNotNil(interstitialVC.closeButton);
        XCTAssertNotEqual([interstitialVC.view subviews].count, 0);
        XCTAssertTrue(interstitial.isAdLoaded);
    };

    void (^verifyAdDismissed)(void) = ^() {
        XCTAssertNil(interstitialVC.webView);
        XCTAssertNil(interstitialVC.closeButton);
        XCTAssertEqual([interstitialVC.view subviews].count, 0);
        XCTAssertFalse([interstitial isAdLoaded]);
    };

    void (^verifyTimerCanceled)(void) = ^() {
        XCTAssertNil(interstitialVC.timeoutDismissBlock);
    };

    void (^afterCloseButtonPressed)(NSTimer * _Nonnull) = ^(NSTimer * _Nonnull timer) {
        NSLog(@"+++ afterCloseButtonPressed: interstitialVC = %@", interstitialVC);
        verifyAdDismissed();
        verifyTimerCanceled();
        [expectation fulfill];
    };

    void (^pressCloseButton)(NSTimer * _Nonnull) = ^(NSTimer * _Nonnull timer) {
        NSLog(@"+++ pressCloseButton");
        [interstitialVC.closeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        if (@available(iOS 10.0, *)) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:afterCloseButtonPressed];
        }
    };

    void (^beforeCloseButtonPressed)(NSTimer * _Nonnull) = ^(NSTimer * _Nonnull timer) {
        NSLog(@"+++ beforeCloseButtonPressed");
        verifyAdLoaded();
        if (@available(iOS 10.0, *)) {
            [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:pressCloseButton];
        }
    };

    if (@available(iOS 10.0, *)) {
        NSLog(@"+++ scheduling beforeCloseButtonPressed");
        [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:beforeCloseButtonPressed];
    }

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

#pragma clang diagnostic pop

@end
