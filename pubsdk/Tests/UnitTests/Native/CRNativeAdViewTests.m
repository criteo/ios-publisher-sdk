//
//  CRNativeAdViewTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "CRNativeAdView.h"
#import "CR_AdChoice.h"
#import "CRNativeAd+Internal.h"
#import "CR_NativeAssetsTests.h"
#import "OCMock.h"
#import "NSURL+Criteo.h"
#import "CRNativeLoader.h"
#import "CRMediaDownloader.h"

@interface CRNativeAdViewTests : XCTestCase
@end

@implementation CRNativeAdViewTests

#pragma mark - Tests
#pragma mark Ad

- (void)testAdClickOpenExternalURL {
    CRNativeAdView *adView = [self buildNativeAdView];
    UIWindow *window = [self createUIWindow];
    [window.rootViewController.view addSubview:adView];
    adView.nativeAd = [self buildNativeAd];

    id mockUrl = OCMClassMock([NSURL class]);
    OCMStub([mockUrl cr_URLWithStringOrNil:OCMOCK_ANY]).andReturn(mockUrl);
    OCMExpect([mockUrl cr_openExternal:OCMOCK_ANY]);

    [adView sendActionsForControlEvents:UIControlEventTouchUpInside];
    OCMVerifyAll(mockUrl);
}

#pragma mark AdChoice

- (void)testAdChoiceMissingWithoutAd {
    CRNativeAdView *adView = [self buildNativeAdView];
    CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
    XCTAssertNil(adChoice);
}

- (void)testAdChoiceWithAd {
    CRNativeAdView *adView = [self buildNativeAdView];
    adView.nativeAd = [self buildNativeAd];
    CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
    XCTAssertNotNil(adChoice);
}

- (void)testAdChoiceOnTopRightAndFrontMost {
    CRNativeAdView *adView = [self buildNativeAdView];
    UIWindow *window = [self createUIWindow];
    [window.rootViewController.view addSubview:adView];
    adView.nativeAd = [self buildNativeAd];
    [adView layoutSubviews];
    CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
    CGFloat adRight = adView.frame.size.width;
    CGFloat adChoiceRight = adChoice.frame.origin.x + adChoice.frame.size.width;
    XCTAssertEqual(adRight, adChoiceRight, @"AdChoice should be at right");
    XCTAssertEqual(adChoice.frame.origin.y, 0, @"AdChoice should be at top");
    XCTAssertEqual([adView.subviews indexOfObject:adChoice], 0, @"AdChoice should be frontmost view");
}

- (void)testAdChoiceClickOpenExternalURL {
    CRNativeAdView *adView = [self buildNativeAdView];
    UIWindow *window = [self createUIWindow];
    [window.rootViewController.view addSubview:adView];
    adView.nativeAd = [self buildNativeAd];

    id mockUrl = OCMClassMock([NSURL class]);
    OCMStub([mockUrl cr_URLWithStringOrNil:OCMOCK_ANY]).andReturn(mockUrl);
    OCMExpect([mockUrl cr_openExternal:OCMOCK_ANY]);

    CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
    [adChoice sendActionsForControlEvents:UIControlEventTouchUpInside];
    OCMVerifyAll(mockUrl);
}

- (void)testAdChoiceImageDownload {
    CRNativeAdView *adView = [self buildNativeAdView];
    UIWindow *window = [self createUIWindow];
    [window.rootViewController.view addSubview:adView];

    id mockDownloader = OCMProtocolMock(@protocol(CRMediaDownloader));
    OCMExpect([mockDownloader downloadImage:OCMOCK_ANY completionHandler:OCMOCK_ANY]);

    CRNativeLoader *loader = OCMClassMock(CRNativeLoader.class);
    OCMStub([loader mediaDownloader]).andReturn(mockDownloader);

    CRNativeAd *ad = [self buildNativeAdWithLoader:loader];
    adView.nativeAd = ad;
    OCMVerifyAll(mockDownloader);
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

- (CRNativeAd *)buildNativeAdWithLoader:(CRNativeLoader *)loader {
    CR_NativeAssets *assets = [CR_NativeAssetsTests loadNativeAssets:@"NativeAssetsFromCdb"];
    CRNativeAd *nativeAd = [[CRNativeAd alloc] initWithLoader:loader assets:assets];
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
