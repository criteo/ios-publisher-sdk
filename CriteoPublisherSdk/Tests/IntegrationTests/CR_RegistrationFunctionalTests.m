//
//  CROrthogonalBannerFunctionalTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_Config.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_NetworkCaptor.h"
#import "CR_TestAdUnits.h"
#import "XCTestCase+Criteo.h"

@interface CR_RegistrationFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_RegistrationFunctionalTests

- (void)test_givenCriteoInitWithBanner_whenRegisterTwice_thenOneCBDCall {
  [self givenCriteoInit_whenRegisterTwice_thenOneCBDCall_withAdUnits:[CR_TestAdUnits
                                                                         randomBanner320x50]];
}

- (void)test_givenCriteoInitWithInterstitial_whenRegisterTwice_thenOneCBDCall {
  [self givenCriteoInit_whenRegisterTwice_thenOneCBDCall_withAdUnits:[CR_TestAdUnits
                                                                         randomInterstitial]];
}

- (void)test_givenCriteoInitWithNative_whenRegisterTwice_thenOneCBDCall {
  [self givenCriteoInit_whenRegisterTwice_thenOneCBDCall_withAdUnits:[CR_TestAdUnits randomNative]];
}

- (void)givenCriteoInit_whenRegisterTwice_thenOneCBDCall_withAdUnits:(CRAdUnit *)adUnit {
  [self initCriteoWithAdUnits:@[ adUnit ]];
  XCTestExpectation *expectation = [self expectationForNotCallingCDBOnCriteo:self.criteo];

  [self.criteo testing_registerWithAdUnits:@[ adUnit ]];
  [self cr_waitShortlyForExpectations:@[ expectation ]];
}

- (XCTestExpectation *)expectationForNotCallingCDBOnCriteo:(Criteo *)criteo {
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"CBD should not be called a second time"];
  expectation.inverted = YES;
  criteo.testing_networkCaptor.requestListener =
      ^(NSURL *_Nonnull url, CR_HTTPVerb verb, NSDictionary *_Nullable body) {
        if ([url.absoluteString containsString:criteo.config.cdbUrl]) {
          [expectation fulfill];  // Note that we invert the expectation previously
        }
      };
  return expectation;
}

@end
