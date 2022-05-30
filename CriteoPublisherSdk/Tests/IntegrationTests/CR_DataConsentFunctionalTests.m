//
//  CR_UsPrivacyConsentFunctionalTests.m
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

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_ApiQueryKeys.h"
#import "CR_DependencyProvider.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_Gdpr.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSString+GDPR.h"
#import "NSString+APIKeys.h"
#import "NSString+CriteoUrl.h"
#import "NSURL+Testing.h"
#import "NSUserDefaults+GDPR.h"

#define CR_AssertDoNotContainsAppEventRequest(requests)                                       \
  do {                                                                                        \
    for (CR_HttpContent * content in requests) {                                              \
      XCTAssertFalse([content.url testing_isAppLaunchEventUrlWithConfig:self.criteo.config]); \
    }                                                                                         \
  } while (0);

@interface CR_DataConsentFunctionalTests : XCTestCase

@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property(strong, nonatomic) Criteo *criteo;

// Overriden properties
@property(strong, nonatomic, readonly) NSDictionary *gdprInBidRequest;
@property(strong, nonatomic, readonly) NSString *appEventUrlString;

@end

@implementation CR_DataConsentFunctionalTests

- (void)setUp {
  self.criteo = [Criteo testing_criteoWithNetworkCaptor];
  self.userDefaults = self.criteo.dependencyProvider.userDefaults;
}

- (void)tearDown {
  [self.criteo.dependencyProvider.threadManager waiter_waitIdle];
  [super tearDown];
}

#pragma mark - GDPR

- (void)testGivenNoGdpr_whenCriteoRegister_thenConsentStringSetInBidRequest {
  [self.criteo testing_registerBannerAndWaitForHTTPResponses];

  XCTAssertNil(self.gdprInBidRequest);
  XCTAssertNil(self.appEventUrlString.cr_urlQueryParamsDictionary[NSString.gdprConsentKey]);
}

- (void)testGivenGdprV1ConsentStringSet_whenCriteoRegister_thenConsentStringSetInBidRequest {
  NSDictionary *expected = @{
    NSString.gdprVersionKey : @1,
    NSString.gdprConsentDataKey : NSString.gdprConsentStringForTcf1_1
  };
  [self.userDefaults setGdprTcf1_1DefaultConsentString];

  [self.criteo testing_registerBannerAndWaitForHTTPResponses];

  XCTAssertEqualObjects(self.gdprInBidRequest, expected);
  XCTAssertNotNil(
      self.appEventUrlString.cr_urlQueryParamsDictionary[NSString.gdprConsentKeyForGum]);
}

- (void)testGivenGdprV1Set_whenCriteoRegister_thenConsentStringSetInBidRequest {
  NSDictionary *expected = @{
    NSString.gdprVersionKey : @1,
    NSString.gdprConsentDataKey : NSString.gdprConsentStringForTcf1_1,
    NSString.gdprAppliesKey : @YES
  };
  [self.userDefaults setGdprTcf1_1DefaultConsentString];
  [self.userDefaults setGdprTcf1_1GdprApplies:@YES];

  [self.criteo testing_registerBannerAndWaitForHTTPResponses];

  XCTAssertEqualObjects(self.gdprInBidRequest, expected);
  XCTAssertNotNil(
      self.appEventUrlString.cr_urlQueryParamsDictionary[NSString.gdprConsentKeyForGum]);
}

- (void)testGivenGdprV2Set_whenCriteoRegister_thenConsentStringSetInBidRequest {
  NSDictionary *expected = @{
    NSString.gdprVersionKey : @2,
    NSString.gdprConsentDataKey : NSString.gdprConsentStringForTcf2_0,
    NSString.gdprAppliesKey : @YES
  };
  [self.userDefaults setGdprTcf2_0DefaultConsentString];
  [self.userDefaults setGdprTcf2_0GdprApplies:@YES];

  [self.criteo testing_registerBannerAndWaitForHTTPResponses];

  XCTAssertEqualObjects(self.gdprInBidRequest, expected);
}

- (void)testGivenGdprV2AndV1Set_whenCriteoRegister_thenConsentStringV2SetInBidRequest {
  NSDictionary *expected = @{
    NSString.gdprVersionKey : @2,
    NSString.gdprConsentDataKey : NSString.gdprConsentStringForTcf2_0,
    NSString.gdprAppliesKey : @YES
  };
  [self.userDefaults setGdprTcf1_1DefaultConsentString];
  [self.userDefaults setGdprTcf2_0DefaultConsentString];
  [self.userDefaults setGdprTcf2_0GdprApplies:@YES];

  [self.criteo testing_registerBannerAndWaitForHTTPResponses];

  XCTAssertEqualObjects(self.gdprInBidRequest, expected);
}

#pragma mark - CCPA

- (void)testGivenIabConsentStringSet_whenCriteoRegister_thenUsIabSetInBidRequest {
  [self.userDefaults setObject:CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString
                        forKey:CR_CcpaIabConsentStringKey];

  [self.criteo testing_registerBannerAndWaitForHTTPResponses];

  NSString *actualConsent = [self _iabConsentInLastBidRequestWithCriteo:self.criteo];
  XCTAssertEqualObjects(actualConsent,
                        CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)
    testGivenIabConsentStringSetWithoutConsent_whenCriteoRegister_thenUsIabSetInBidRequestAndAppEventNotSent {
  [self.userDefaults setObject:@"1YYN" forKey:CR_CcpaIabConsentStringKey];

  [self.criteo testing_registerBanner];
  [self _waitForBidAndConfurationOnlyWithCriteo:self.criteo];

  NSString *actualConsent = [self _iabConsentInLastBidRequestWithCriteo:self.criteo];
  XCTAssertEqualObjects(actualConsent, @"1YYN");
  CR_AssertDoNotContainsAppEventRequest(self.criteo.testing_networkCaptor.allRequests);
}

- (void)testGivenIabConsentStringNil_whenCriteoRegister_thenUsIabNotSetInBidRequest {
  Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

  [criteo testing_registerBannerAndWaitForHTTPResponses];

  NSString *actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
  XCTAssertNil(actualConsent);
}

- (void)testGivenIabConsentStringEmpty_whenCriteoRegister_thenUsIabNotSetInBidRequest {
  [self.userDefaults setObject:@"" forKey:CR_CcpaIabConsentStringKey];
  Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

  [criteo testing_registerBannerAndWaitForHTTPResponses];

  NSString *actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
  XCTAssertNil(actualConsent);
}

#pragma mark - Criteo Optout

- (void)
    testGivenCriteoUsPrivacyOptOutYES_whenCriteoRegister_thenBidIncludeUsPrivacyOptOutToYES_noAppEventSent {
  Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
  [criteo setUsPrivacyOptOut:YES];

  [criteo testing_registerBanner];
  [self _waitForBidAndConfurationOnlyWithCriteo:criteo];

  NSNumber *actualConsent = [self _criteoUsPrivacyConsentInLastBidRequestWithCriteo:criteo];
  XCTAssertTrue([actualConsent boolValue]);
  CR_AssertDoNotContainsAppEventRequest(criteo.testing_networkCaptor.allRequests);
}

- (void)
    testGivenCriteoUsPrivacyOptOutNO_whenCriteoRegister_thenBidIncludeUsPrivacyOptOutToNO_appEventSent {
  [self.criteo setUsPrivacyOptOut:NO];

  [self.criteo testing_registerBannerAndWaitForHTTPResponses];

  XCTAssertEqual(self.criteo.testing_networkCaptor.allRequests.count, 3);
  XCTAssertNotNil(self.criteo.testing_lastBidHttpContent);
  NSNumber *actualConsent = [self _criteoUsPrivacyConsentInLastBidRequestWithCriteo:self.criteo];
  XCTAssertNotNil(actualConsent);
  XCTAssertFalse([actualConsent boolValue]);
}

#pragma mark - Private methods

- (NSDictionary *)gdprInBidRequest {
  CR_HttpContent *bidRequest = self.criteo.testing_lastBidHttpContent;
  return bidRequest.requestBody[NSString.gdprConsentKey];
}

- (NSString *)appEventUrlString {
  CR_HttpContent *request = self.criteo.testing_lastAppEventHttpContent;
  return request.url.absoluteString;
}

- (NSNumber *)_criteoUsPrivacyConsentInLastBidRequestWithCriteo:(Criteo *)criteo {
  CR_HttpContent *bidRequest = criteo.testing_lastBidHttpContent;
  NSNumber *actualConsent = bidRequest.requestBody[NSString.userKey][NSString.uspCriteoOptout];
  return actualConsent;
}

- (NSString *)_iabConsentInLastBidRequestWithCriteo:(Criteo *)criteo {
  CR_HttpContent *bidRequest = criteo.testing_lastBidHttpContent;
  NSString *actualConsent = bidRequest.requestBody[NSString.userKey][NSString.uspIabKey];
  return actualConsent;
}

- (void)_waitForBidAndConfurationOnlyWithCriteo:(Criteo *)criteo {
  CR_NetworkWaiterBuilder *builder =
      [[CR_NetworkWaiterBuilder alloc] initWithConfig:criteo.config
                                        networkCaptor:criteo.testing_networkCaptor];
  CR_NetworkWaiter *waiter = builder.withFinishedRequestsIncluded.withBid.withConfig.build;
  const BOOL result = [waiter wait];
  XCTAssert(result);
  sleep(1);  // To be sure that the launch app event isn't sent asynchronously.
}

@end
