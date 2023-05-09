//
//  CRInterstitialViewControllerTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
#import "CR_Timer.h"
#import "CR_URLOpenerMock.h"
#import "XCTestCase+Criteo.h"

@interface CR_InterstitialViewController () {
  BOOL _hasBeenDismissed;
}

@property(nonatomic, strong) dispatch_block_t timeoutDismissBlock;

@end

@interface CRInterstitialViewControllerTests : XCTestCase

@property(nonatomic, strong) CRInterstitialAdUnit *adUnit;
@property(nonatomic, strong) CR_CacheAdUnit *cacheAdUnit;

@end

@implementation CRInterstitialViewControllerTests

- (void)setUp {
  _adUnit = nil;
}

- (CRInterstitialAdUnit *)adUnit {
  if (!_adUnit) {
    _adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"123"];
  }
  return _adUnit;
}

- (void)testCloseButtonInitialization {
  MockWKWebView *mockWebView = [MockWKWebView new];
  CR_InterstitialViewController *interstitial =
      [[CR_InterstitialViewController alloc] initWithWebView:mockWebView view:nil interstitial:nil];
  [interstitial viewDidAppear:YES];
  XCTAssertNotNil(interstitial.view);
  XCTAssertNotNil(interstitial.closeButton);
  XCTAssertEqual(interstitial.closeButton.superview, interstitial.view);
  XCTAssert([[interstitial.closeButton actionsForTarget:interstitial
                                        forControlEvent:UIControlEventTouchUpInside]
      containsObject:@"closeButtonPressed"]);
  XCTAssertNotNil([interstitial.closeButton.layer.sublayers objectAtIndex:0]);
  CAShapeLayer *circleLayer = [interstitial.closeButton.layer.sublayers objectAtIndex:0];
  XCTAssertEqual([circleLayer fillColor], [UIColor blackColor].CGColor);
  XCTAssertEqual([circleLayer strokeColor], [UIColor whiteColor].CGColor);
  XCTAssertEqual(circleLayer.lineWidth, 1.0);
  XCTAssertNotNil([interstitial.closeButton.layer.sublayers objectAtIndex:1]);
  CAShapeLayer *xLayer = [interstitial.closeButton.layer.sublayers objectAtIndex:1];
  XCTAssertEqual([xLayer strokeColor], [UIColor whiteColor].CGColor);
  XCTAssertEqual([xLayer lineWidth], 3.0);
}

- (void)testCloseButtonClick {
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  CR_InterstitialViewController *interstitialVC =
      [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                        view:nil
                                                interstitial:nil];
  CRInterstitial *interstitial =
      [[CRInterstitial alloc] initWithCriteo:mockCriteo
                              viewController:interstitialVC
                                  isAdLoaded:YES
                                      adUnit:self.adUnit
                                   urlOpener:[[CR_URLOpenerMock alloc] init]];
  XCTestExpectation *vcDismissedExpectation =
      [self expectationWithDescription:@"View Controller dismissed on close button click"];

  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
  [window makeKeyAndVisible];
  UIViewController *vc = [UIViewController new];
  window.rootViewController = vc;
  interstitialVC.interstitial = interstitial;

  [interstitial presentFromRootViewController:vc];
  [CR_Timer
      scheduledTimerWithTimeInterval:1.0
                             repeats:YES
                               block:^(NSTimer *_Nonnull timer) {
                                 if (vc && vc.presentedViewController) {
                                   [interstitialVC.closeButton
                                       sendActionsForControlEvents:UIControlEventTouchUpInside];
                                   [timer invalidate];
                                   [CR_Timer
                                       scheduledTimerWithTimeInterval:0.1
                                                              repeats:YES
                                                                block:^(NSTimer *_Nonnull timer) {
                                                                  if (vc &&
                                                                      !vc.presentedViewController) {
                                                                    [timer invalidate];
                                                                    XCTAssertNil(
                                                                        interstitialVC.webView);
                                                                    XCTAssertNil(
                                                                        interstitialVC.closeButton);
                                                                    XCTAssertEqual(
                                                                        [interstitialVC
                                                                                .view subviews]
                                                                            .count,
                                                                        0);
                                                                    XCTAssertFalse(
                                                                        [interstitial isAdLoaded]);
                                                                    [vcDismissedExpectation
                                                                        fulfill];
                                                                  }
                                                                }];
                                 }
                               }];

  [self cr_waitForExpectations:@[ vcDismissedExpectation ]];
}

- (void)testDismissCompletion {
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  CR_InterstitialViewController *interstitialVC =
      [[CR_InterstitialViewController alloc] initWithWebView:[WKWebView new]
                                                        view:nil
                                                interstitial:nil];
  CRInterstitial *interstitial =
      [[CRInterstitial alloc] initWithCriteo:mockCriteo
                              viewController:interstitialVC
                                  isAdLoaded:YES
                                      adUnit:self.adUnit
                                   urlOpener:[[CR_URLOpenerMock alloc] init]];
  XCTestExpectation *vcDismissedExpectation = [self
      expectationWithDescription:
          @"View Controller dismissed on close button click should call dismiss completion block"];

  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
  [window makeKeyAndVisible];
  UIViewController *vc = [UIViewController new];
  window.rootViewController = vc;
  interstitialVC.interstitial = interstitial;

  [interstitial presentFromRootViewController:vc];
  [CR_Timer
      scheduledTimerWithTimeInterval:1.0
                             repeats:YES
                               block:^(NSTimer *_Nonnull timer) {
                                 if (vc && vc.presentedViewController) {
                                   interstitialVC.dismissCompletion = ^{
                                     [vcDismissedExpectation fulfill];
                                   };
                                   [interstitialVC.closeButton
                                       sendActionsForControlEvents:UIControlEventTouchUpInside];
                                   [timer invalidate];
                                 }
                               }];

  [self cr_waitForExpectations:@[ vcDismissedExpectation ]];
}

@end
