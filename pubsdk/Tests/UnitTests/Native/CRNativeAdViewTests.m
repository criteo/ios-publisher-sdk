//
//  CRNativeAdViewTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "CRNativeAdView.h"
#import "CR_AdChoice.h"
#import "CRNativeAd+Internal.h"
#import "CR_NativeAssetsTests.h"

@interface CRNativeAdViewTests : XCTestCase
@end

@implementation CRNativeAdViewTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testAdChoiceMissingWithoutAd {
    CRNativeAdView *adView = [self buildNativeAdView];
    CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
    XCTAssertNil(adChoice);
}

- (void)testAddChoiceWithAd {
    CRNativeAdView *adView = [self buildNativeAdView];
    adView.nativeAd = [self buildNativeAd];
    CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
    XCTAssertNotNil(adChoice);
}

- (void)testAddChoiceOnTopRightAndFrontMost {
    CRNativeAdView *adView = [self buildNativeAdView];
    UIWindow *window = [self createUIWindow];
    [window.rootViewController.view addSubview:adView];
    adView.nativeAd = [self buildNativeAd];

    XCTestExpectation *adChoiceExpectation = [self expectationWithDescription:@"URL opened in browser expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
        CGFloat adRight = adView.frame.size.width;
        CGFloat adChoiceRight = adChoice.frame.origin.x + adChoice.frame.size.width;
        XCTAssertEqual(adRight, adChoiceRight, @"AdChoice should be at right");
        XCTAssertEqual(adChoice.frame.origin.y, 0, @"AdChoice should be at top");
        XCTAssertEqual([adView.subviews indexOfObject:adChoice], 0, @"AdChoice should be frontmost view");
        [adChoiceExpectation fulfill];
    });

    [self waitForExpectations:@[adChoiceExpectation] timeout:1];
}

#pragma mark - Private

- (CRNativeAdView *)buildNativeAdView {
    return [[CRNativeAdView alloc] initWithFrame:(CGRect) {0, 0, 320, 50}];
}

- (CRNativeAd *)buildNativeAd {
    CR_NativeAssets *assets = [CR_NativeAssetsTests loadNativeAssets:@"NativeAssetsFromCdb"];
    CRNativeAd *nativeAd = [[CRNativeAd alloc] initWithNativeAssets:assets];
    return nativeAd;
}

- (__kindof UIView *)getAdChoiceFromAdView:(CRNativeAdView *)adView {
    NSUInteger index = [adView.subviews indexOfObjectPassingTest:^BOOL(__kindof UIView *view, NSUInteger idx, BOOL *stop) {
        return [view isKindOfClass:CR_AdChoice.class];
    }];
    return index != NSNotFound ? adView.subviews[index] : nil;
}

- (UIWindow *)createUIWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 50, 320, 480)];
    [window makeKeyAndVisible];
    UIViewController *viewController = [UIViewController new];
    window.rootViewController = viewController;
    return window;
}

@end
