//
//  CR_NativeAdFunctionalTests.m
//  pubsdkITests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_IntegrationsTestBase.h"
#import "CR_NativeAdTableViewController.h"
#import "CR_TestAdUnits.h"
#import "UIWindow+Testing.h"
#import "XCTestCase+Criteo.h"
#import "CR_NativeAdTableViewCell.h"
#import "CRMediaView+Internal.h"
#import "CR_NativeAssets+Testing.h"

@interface CR_NativeAdFunctionalTests : CR_IntegrationsTestBase

@property (strong, nonatomic) UIWindow *window;

@end

@implementation CR_NativeAdFunctionalTests

- (void)setUp {

}

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
    XCTAssertEqualObjects(adCell.productMediaView.imageUrl.absoluteString, expectedAssets.products.firstObject.image.url);

    // PreProd Advertiser logo is a SVG image which is not supported, so image is nil
    XCTAssertNil(adCell.advertiserLogoMediaView.imageView.image);
    XCTAssertNil(adCell.advertiserLogoMediaView.imageUrl);
}

@end
