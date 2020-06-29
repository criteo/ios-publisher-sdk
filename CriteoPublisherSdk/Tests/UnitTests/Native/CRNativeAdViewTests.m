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
#import "CR_ImpressionDetector.h"
#import "OCMock.h"
#import "NSURL+Criteo.h"
#import "UIWindow+Testing.h"
#import "CRNativeLoader+Internal.h"
#import "CRMediaDownloader.h"
#import "CR_NativeAssets+Testing.h"

@interface CRNativeAdViewTests : XCTestCase

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) id impressionDetectorMock;

@end

@implementation CRNativeAdViewTests

- (void)setUp {
  self.impressionDetectorMock = [self mockImpressionDectectorInstantiation];
}

- (void)tearDown {
  [self.window cr_removeFromScreen];
}

#pragma mark - Tests
#pragma mark AdChoice

- (void)testAdChoiceMissingWithoutAd {
  CRNativeAdView *adView = [self buildNativeAdView];
  CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
  XCTAssertTrue(adChoice.isHidden);
}

- (void)testAdChoiceWithAd {
  CRNativeAdView *adView = [self buildNativeAdView];
  adView.nativeAd = [self buildNativeAd];
  CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
  XCTAssertNotNil(adChoice);
  XCTAssertFalse(adChoice.isHidden);
}

- (void)testAdChoiceOnTopRightAndFrontMost {
  CRNativeAdView *adView = [self buildNativeAdView];
  self.window = [UIWindow cr_keyWindowWithView:adView];
  adView.nativeAd = [self buildNativeAd];
  [adView layoutSubviews];
  CR_AdChoice *adChoice = [self getAdChoiceFromAdView:adView];
  CGFloat adRight = adView.frame.size.width;
  CGFloat adChoiceRight = adChoice.frame.origin.x + adChoice.frame.size.width;
  XCTAssertEqual(adRight, adChoiceRight, @"AdChoice should be at right");
  XCTAssertEqual(adChoice.frame.origin.y, 0, @"AdChoice should be at top");
  XCTAssertEqual([adView.subviews indexOfObject:adChoice], 0, @"AdChoice should be frontmost view");
}

- (void)testAdChoiceImageDownload {
  CRNativeAdView *adView = [self buildNativeAdView];
  self.window = [UIWindow cr_keyWindowWithView:adView];
  id mockDownloader = OCMProtocolMock(@protocol(CRMediaDownloader));
  CRNativeLoader *loader = OCMClassMock(CRNativeLoader.class);
  OCMStub([loader mediaDownloader]).andReturn(mockDownloader);
  CRNativeAd *ad = [self buildNativeAdWithLoader:loader];

  adView.nativeAd = ad;

  OCMVerify(times(1), [mockDownloader downloadImage:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

- (void)testAdChoiceClickCallDelegateForClicking {
  id loaderMock = [self buildNativeLoaderMock];
  CRNativeAd *ad = [self buildNativeAdWithLoader:loaderMock];
  CRNativeAdView *adView = [self buildNativeAdViewWithNativeAd:ad];

  [adView sendActionsForControlEvents:UIControlEventTouchUpInside];

  OCMVerify(times(1), [loaderMock handleClickOnNativeAd:ad]);
}

#pragma mark Impression

- (void)testNoImpressionDetectorStartedWithoutNativeAd {
  CRNativeAdView *view = [[CRNativeAdView alloc] initWithFrame:CGRectZero];

  view.nativeAd = nil;

  OCMVerify(never(), [self.impressionDetectorMock startDetection]);
  OCMVerify(never(), [self.impressionDetectorMock stopDetection]);
}

- (void)testImpressionDetectorStartedWithNativeAd {
  id loaderMock = [self buildNativeLoaderMock];
  CRNativeAd *ad = [self buildNativeAdWithLoader:loaderMock];
  CRNativeAdView *view = [[CRNativeAdView alloc] initWithFrame:CGRectZero];

  view.nativeAd = ad;

  OCMVerify(times(1), [self.impressionDetectorMock startDetection]);
  OCMVerify(never(), [self.impressionDetectorMock stopDetection]);
}

- (void)testNoImpressionDetectorWithAlreadyImpressedNativeAd {
  id loaderMock = [self buildNativeLoaderMock];
  CRNativeAd *ad = [self buildNativeAdWithLoader:loaderMock];
  CRNativeAdView *view = [[CRNativeAdView alloc] initWithFrame:CGRectZero];
  [ad markAsImpressed];

  view.nativeAd = ad;

  OCMVerify(never(), [self.impressionDetectorMock startDetection]);
  OCMVerify(times(1), [self.impressionDetectorMock stopDetection]);
}

- (void)testChangeNativeAdUpdateCorrectlyAdChoiceAndDetector {
  id loaderMock = [self buildNativeLoaderMock];
  CRNativeAd *ad1 = [self buildNativeAdWithLoader:loaderMock];
  CRNativeAd *ad2 = [self buildNativeAdWithLoader:loaderMock];
  CRNativeAdView *view = [[CRNativeAdView alloc] initWithFrame:CGRectZero];

  view.nativeAd = ad1;
  view.nativeAd = ad1;
  view.nativeAd = ad2;

  CR_AdChoice *adChoice = [self getAdChoiceFromAdView:view];
  XCTAssertEqual(adChoice.nativeAd, ad2);
  OCMVerify(times(2), [self.impressionDetectorMock startDetection]);
  OCMVerify(never(), [self.impressionDetectorMock stopDetection]);
}

#pragma mark - Private

- (CRNativeAdView *)buildNativeAdView {
  return [self buildNativeAdViewWithNativeAd:nil];
}

- (CRNativeAdView *)buildNativeAdViewWithNativeAd:(CRNativeAd *)nativeAd {
  CRNativeAdView *view = [[CRNativeAdView alloc] initWithFrame:(CGRect){0, 0, 320, 50}];
  view.nativeAd = nativeAd;
  return view;
}

- (CRNativeAd *)buildNativeAd {
  CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
  CRNativeAd *nativeAd = [[CRNativeAd alloc] initWithNativeAssets:assets];
  return nativeAd;
}

- (CRNativeAd *)buildNativeAdWithLoader:(CRNativeLoader *)loader {
  CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
  CRNativeAd *nativeAd = [[CRNativeAd alloc] initWithLoader:loader assets:assets];
  return nativeAd;
}

- (OCMockObject *)buildNativeLoaderMock {
  CRNativeLoader *loader = OCMClassMock(CRNativeLoader.class);
  return (OCMockObject *)loader;
}

- (__kindof UIView *)getAdChoiceFromAdView:(CRNativeAdView *)adView {
  NSUInteger index = [adView.subviews
      indexOfObjectPassingTest:^BOOL(__kindof UIView *view, NSUInteger idx, BOOL *stop) {
        return [view isKindOfClass:CR_AdChoice.class];
      }];
  return index != NSNotFound ? adView.subviews[index] : nil;
}

- (OCMockObject *)mockImpressionDectectorInstantiation {
  OCMockObject *mock = OCMClassMock([CR_ImpressionDetector class]);
  OCMStub([(id)mock alloc]).andReturn(mock);
  OCMStub([(id)mock initWithView:[OCMArg any]]).andReturn(mock);
  return mock;
}

@end
