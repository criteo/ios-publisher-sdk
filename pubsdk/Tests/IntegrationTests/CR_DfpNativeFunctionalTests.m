//
//  CR_CdbCallsIntegrationTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 02/12/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_AssertDfp.h"
@import GoogleMobileAds;

@interface CR_DfpNativeFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_DfpNativeFunctionalTests

- (void)test_givenNativeWithBadAdUnitId_whenSetBids_thenRequestKeywordsDoNotChange {
    CRNativeAdUnit *native = [CR_TestAdUnits randomNative];
    [self initCriteoWithAdUnits:@[native]];
    DFPRequest *dfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:dfpRequest withAdUnit:native];

    XCTAssertNil(dfpRequest.customTargeting);
}


- (void)test_givenNativeWithGoodAdUnitId_whenSetBids_thenRequestKeywordsUpdated {
    CRNativeAdUnit *native = [CR_TestAdUnits preprodNative];
    [self initCriteoWithAdUnits:@[native]];
    DFPRequest *dfpRequest = [[DFPRequest alloc] init];

    [self.criteo setBidsForRequest:dfpRequest withAdUnit:native];

    CR_AssertDfpNativeCustomTargetingContainsCriteoBid(dfpRequest.customTargeting);
}

@end
