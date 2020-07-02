//
//  CROrthogonalBannerFunctionalTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
