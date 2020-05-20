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
#import "Criteo+Testing.h"
#import "XCTestCase+Criteo.h"

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

@end
