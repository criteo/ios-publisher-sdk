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
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:@"adLoaded"
                                                                 object:ctrl];
    ctrl.adUnit = adUnit;

    [self cr_waitForExpectations:@[exp]];
}

- (void)testAdCellFilledWithDataInTableViewWithPreProdContent {
    CR_NativeAssets *expectedAssets = [CR_NativeAssets nativeAssetsFromCdb];
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[adUnit]];
    CR_NativeAdTableViewController *ctrl = [CR_NativeAdTableViewController
            nativeAdTableViewControllerWithCriteo:self.criteo];
    ctrl.mediaPlaceholder = [[UIImage alloc] init];
    self.window = [UIWindow cr_keyWindowWithViewController:ctrl];
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(lastFilledAdCell))
                                                                 object:ctrl];
    ctrl.adUnit = adUnit;

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

#pragma mark - Private

- (XCTestExpectation *)expectationForLeaingAppOnViewController:(CR_NativeAdViewController *)ctrl {
    NSString *keyPath = NSStringFromSelector(@selector(leaveAppCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@1];
    return exp;
}

- (XCTestExpectation *)expectationForClickDetectionOnViewController:(CR_NativeAdViewController *)ctrl {
    NSString *keyPath = NSStringFromSelector(@selector(detectClickCount));
    XCTestExpectation *exp = [[XCTKVOExpectation alloc] initWithKeyPath:keyPath
                                                                 object:ctrl
                                                          expectedValue:@1];
    return exp;
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

@end
