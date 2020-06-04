//
//  CR_NativeAdFunctionalTests.m
//  pubsdkITests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <OCMock.h>
#import "CR_IntegrationsTestBase.h"
#import "CR_NativeAdTableViewController.h"
#import "CR_NativeAdViewController.h"
#import "CR_CustomNativeAdView.h"
#import "CR_TestAdUnits.h"
#import "CRNativeLoader.h"
#import "Criteo+Testing.h"
#import "NSURL+Criteo.h"
#import "UIWindow+Testing.h"
#import "XCTestCase+Criteo.h"
#import "CR_NativeAdTableViewCell.h"
#import "CRMediaView+Internal.h"
#import "CR_NativeAssets+Testing.h"
#import "UIImage+Testing.h"

@interface CR_NativeAdFunctionalTests : CR_IntegrationsTestBase

@property (strong, nonatomic) UIWindow *window;

@end

@implementation CR_NativeAdFunctionalTests

- (void)tearDown {
    [self.window cr_removeFromScreen];
}

- (void)testAdLoadedInTableView {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdTableViewController *ctrl = [CR_NativeAdTableViewController
            nativeAdTableViewControllerWithCriteo:self.criteo];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    NSString *keyPath = NSStringFromSelector(@selector(adLoadedCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl];
    ctrl.adUnit = adUnit;
    [ctrl.adLoader loadAd];

    [self cr_waitForExpectations:@[exp]];
}

- (void)testAdCellFilledWithDataInTableViewWithPreProdContent {
    CR_NativeAssets *expectedAssets = [CR_NativeAssets nativeAssetsFromCdb];
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdTableViewController *ctrl = [CR_NativeAdTableViewController
            nativeAdTableViewControllerWithCriteo:self.criteo];
    ctrl.mediaPlaceholder = [self placeholderImage];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(lastFilledAdCell))
                                                                 object:ctrl];
    ctrl.adUnit = adUnit;
    [ctrl.adLoader loadAd];

    [self cr_waitForExpectations:@[exp]];
    [self waitForIdleState];
    CR_NativeAdTableViewCell *adCell = ctrl.lastFilledAdCell;

    // Text content
    XCTAssertEqualObjects(adCell.titleLabel.text, expectedAssets.products.firstObject.title);
    XCTAssertEqualObjects(adCell.bodyLabel.text, expectedAssets.products.firstObject.description);
    XCTAssertEqualObjects(adCell.priceLabel.text, expectedAssets.products.firstObject.price);
    XCTAssertEqualObjects(adCell.callToActionLabel.text, expectedAssets.products.firstObject.callToAction);
    XCTAssertEqualObjects(adCell.advertiserDomainUrlLabel.text, expectedAssets.advertiser.domain);
    XCTAssertEqualObjects(adCell.advertiserDescriptionLabel.text, expectedAssets.advertiser.description);

    // Product image
    XCTAssertNotNil(adCell.productMediaView.imageView.image);
    XCTAssertNotEqualObjects(adCell.productMediaView.imageView.image, ctrl.mediaPlaceholder);
    XCTAssertEqualObjects(adCell.productMediaView.imageUrl.absoluteString, expectedAssets.products.firstObject.image.url);

    // PreProd Advertiser logo is a SVG image which is not supported, so image is the placeholder
    XCTAssertNotNil(adCell.advertiserLogoMediaView.imageView.image);
    XCTAssertEqualObjects(adCell.advertiserLogoMediaView.imageView.image, ctrl.mediaPlaceholder);
    XCTAssertNil(adCell.advertiserLogoMediaView.imageUrl);
}

- (void)testGivenNativeAd_whenClickOnAd_thenClickDetected {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdViewController *ctrl = [CR_NativeAdViewController
                                       nativeAdViewControllerWithCriteo:self.criteo];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    [self loadNativeAdUnit:adUnit inViewController:ctrl];
    XCTestExpectation *exp = [self expectationForClickDetectionOnViewController:ctrl];

    [ctrl.adView sendActionsForControlEvents:UIControlEventTouchUpInside];

    [self cr_waitForExpectations:@[exp]];
}

- (void)testGivenNativeAd_whenClickOnAd_thenLeaveApp {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdViewController *ctrl = [CR_NativeAdViewController
                                       nativeAdViewControllerWithCriteo:self.criteo];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    [self loadNativeAdUnit:adUnit inViewController:ctrl];
    XCTestExpectation *exp = [self expectationForLeaingAppOnViewController:ctrl];

    [ctrl.adView sendActionsForControlEvents:UIControlEventTouchUpInside];

    [self cr_waitForExpectations:@[exp]];
}

- (void)testGivenNativeAds_whenClickOnAd_thenClickDetected {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdViewController *ctrl = [CR_NativeAdViewController
                                       nativeAdViewControllerWithCriteo:self.criteo];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    [self loadNativeAdUnit:adUnit inViewController:ctrl];
    XCTestExpectation *exp = [self expectationForClickDetectionOnViewController:ctrl];

    [ctrl.adView sendActionsForControlEvents:UIControlEventTouchUpInside];

    [self cr_waitForExpectations:@[exp]];
}

- (void)testGivenNativeAds_whenLoadingAllNativeAd_triggerImpressionForVisibleAd {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdTableViewController *ctrl = [CR_NativeAdTableViewController
                                       nativeAdTableViewControllerWithCriteo:self.criteo];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    ctrl.adUnit = adUnit;
    XCTestExpectation *expFor2 = [self expectationForImpressionOnViewController:ctrl
                                                                  expectedCount:2];
    XCTestExpectation *notExpFor3 = [self expectationForImpressionOnViewController:ctrl
                                                                     expectedCount:3];
    notExpFor3.inverted = YES;

    [self loadAllNativeAdInTableViewController:ctrl];

    [self cr_waitShortlyForExpectations:@[expFor2, notExpFor3]];
}

- (void)testGivenNativeAds_whenScrolling_triggerAllImpression {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdTableViewController *ctrl = [CR_NativeAdTableViewController
                                       nativeAdTableViewControllerWithCriteo:self.criteo];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    ctrl.adUnit = adUnit;
    [self loadAllNativeAdInTableViewController:ctrl
                       expectedImpressionCount:2];
    XCTestExpectation *exp = [self expectationForImpressionOnViewController:ctrl
                                                              expectedCount:3];

    [ctrl scrollAtIndexPath:ctrl.nativeAdIndexPaths.lastObject];

    [self cr_waitForExpectations:@[exp]];
}

- (void)testGivenNativeAd_whenDisplayInSafeArea_thenImpressionDetected {
    if (@available(iOS 11.0, *)) { // Safe area is available on iOS versions >= 11
        CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
        [self initCriteoWithAdUnits:@[adUnit]];
        CR_NativeAdViewController *ctrl = [CR_NativeAdViewController
                                           nativeAdViewControllerWithCriteo:self.criteo];
        ctrl.adViewInSafeArea = YES;
        self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
        XCTestExpectation *exp = [self expectationForImpressionOnViewController:ctrl
                                                                  expectedCount:1];

        [self loadNativeAdUnit:adUnit
              inViewController:ctrl];

        [self cr_waitForExpectations:@[exp]];
    }
}

- (void)testGivenNativeAd_whenDisplayInNotSafeArea_thenImpressionNotDetected {
    if (@available(iOS 11.0, *)) { // Safe area is available on iOS versions >= 11
        CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
        [self initCriteoWithAdUnits:@[adUnit]];
        CR_NativeAdViewController *ctrl = [CR_NativeAdViewController
                                           nativeAdViewControllerWithCriteo:self.criteo];
        ctrl.adViewInSafeArea = NO;
        self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
        XCTestExpectation *exp = [self expectationForImpressionOnViewController:ctrl
                                                                  expectedCount:1];
        exp.inverted = YES;

        [self loadNativeAdUnit:adUnit
              inViewController:ctrl];

        [self cr_waitShortlyForExpectations:@[exp]];
    }
}

- (void)testGivenNativeAds_whenTapOnLastOne_thenDetectClick {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdTableViewController *ctrl = [CR_NativeAdTableViewController
                                       nativeAdTableViewControllerWithCriteo:self.criteo];
    ctrl.adUnit = adUnit;
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    [self loadAllNativeAdInTableViewController:ctrl
                       expectedImpressionCount:ctrl.nativeAdIndexPaths.count - 1];
    [self scrollAtNativeAdAtIndexPath:ctrl.nativeAdIndexPaths.lastObject
                inTableViewController:ctrl];
    XCTestExpectation *exp = [self expectationForClickDetectionOnViewController:ctrl];

    [ctrl tapOnNativeAdAtIndexPath:ctrl.nativeAdIndexPaths.lastObject];

    [self cr_waitForExpectations:@[exp]];
}

#pragma mark - Private

- (XCTestExpectation *)expectationForNativeAdLoadedInTableViewController:(CR_NativeAdTableViewController *)ctrl
                                                           expectedCount:(NSUInteger)expectedCount {
    NSString *keyPath = NSStringFromSelector(@selector(adLoadedCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@(expectedCount)];
    return exp;
}

- (XCTestExpectation *)expectationForLeaingAppOnViewController:(CR_NativeAdViewController *)ctrl {
    NSString *keyPath = NSStringFromSelector(@selector(leaveAppCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@1];
    return exp;
}

- (XCTestExpectation *)expectationForClickDetectionOnViewController:(UIViewController *)ctrl {
    NSAssert([ctrl respondsToSelector:@selector(detectClickCount)],
    @"The given VC doesn't respond to 'detectClickCount' %@", ctrl);
    NSString *keyPath = NSStringFromSelector(@selector(detectClickCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@1];
    return exp;
}

- (XCTestExpectation *)expectationForImpressionOnViewController:(UIViewController *)ctrl
                                                  expectedCount:(NSUInteger)expectedCount {
    NSAssert([ctrl respondsToSelector:@selector(detectImpressionCount)],
             @"The given VC doesn't respond to 'detectImpressionCount' %@", ctrl);
    NSString *keyPath = NSStringFromSelector(@selector(detectImpressionCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@(expectedCount)];
    return exp;
}

- (void)scrollAtNativeAdAtIndexPath:(NSIndexPath *)indexPath
              inTableViewController:(CR_NativeAdTableViewController *)ctrl {
    NSUInteger expectedCount = ctrl.detectImpressionCount + 1;
    XCTestExpectation *exp = [self expectationForImpressionOnViewController:ctrl
                                                              expectedCount:expectedCount];

    [ctrl scrollAtIndexPath:indexPath];

    [self cr_waitForExpectations:@[exp]];
}

- (void)loadNativeAdUnit:(CRNativeAdUnit *)adUnit
        inViewController:(CR_NativeAdViewController *)ctrl {
    ctrl.adUnit = adUnit;
    NSString *keyPath = NSStringFromSelector(@selector(adLoadedCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@1];
    [ctrl.adLoader loadAd];
    [self cr_waitForExpectations:@[exp]];
}

- (UIImage *)placeholderImage {
    return [UIImage testImageNamed:@"image.jpeg"];
}

- (void)loadAllNativeAdInTableViewController:(CR_NativeAdTableViewController *)ctrl
                     expectedImpressionCount:(NSUInteger)expectedImpressionCount {
    XCTestExpectation *exp = [self expectationForImpressionOnViewController:ctrl
                                                              expectedCount:expectedImpressionCount];
    [self loadAllNativeAdInTableViewController:ctrl];

    [self cr_waitForExpectations:@[exp]];
}

- (void)loadAllNativeAdInTableViewController:(CR_NativeAdTableViewController *)ctrl {
    for (NSUInteger i = 0; i < ctrl.nativeAdIndexPaths.count; i++) {
        [self loadNativeAdInTableViewController:ctrl];
    }
}

- (void)loadNativeAdInTableViewController:(CR_NativeAdTableViewController *)ctrl {
    NSUInteger nextLoadCount = ctrl.adLoadedCount + 1;
    NSString *keyPath = NSStringFromSelector(@selector(adLoadedCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@(nextLoadCount)];
    [ctrl.adLoader loadAd];
    [self cr_waitForExpectations:@[exp]];
}

@end
