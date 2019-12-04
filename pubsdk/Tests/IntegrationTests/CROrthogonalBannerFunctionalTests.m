//
//  CROrthogonalBannerFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 12/4/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_NetworkCaptor.h"
#import "CR_Config.h"
#import "XCTestCase+Criteo.h"

@interface CROrthogonalBannerFunctionalTests : XCTestCase

@end

@implementation CROrthogonalBannerFunctionalTests

- (void)test_givenCriteoInit_whenRegisterTwice_thenOneCBDCall {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [criteo testing_registerBannerAndWaitForHTTPResponses];
    XCTestExpectation *expectation = [self expectationForNotCallingCDBOnCriteo:criteo];

    [criteo testing_registerBanner];

    [self criteo_waitForExpectations:@[expectation]];
}

- (XCTestExpectation *)expectationForNotCallingCDBOnCriteo:(Criteo *)criteo {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"CBD should not be called a second time"];
    expectation.inverted = YES;
    criteo.testing_networkCaptor.requestListener = ^(NSURL * _Nonnull url, CR_HTTPVerb verb, NSDictionary * _Nullable body) {
        if ([url.absoluteString containsString:criteo.config.cdbUrl]) {
            [expectation fulfill]; // Note that we invert the expectation previously
        }
    };
    return expectation;
}


@end
