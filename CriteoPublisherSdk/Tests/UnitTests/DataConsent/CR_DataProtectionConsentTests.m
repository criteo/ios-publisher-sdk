//
//  CR_DataProtectionConsentTests.m
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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "XCTestCase+Criteo.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_InMemoryUserDefaults.h"

NSString *const CR_DataProtectionConsentTestsApprovedVendorString =
    @"0000000000000010000000000000000000000100000000000000000000000000000000000000000000000000001";
NSString *const CR_DataProtectionConsentTestsUnapprovedVendorString =
    @"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
NSString *const CR_DataProtectionConsentTestsMalformed80CharsVendorString =
    @"000000000000000000000000000000000000000000000000000000000000000000000000000000000";
NSString *const CR_DataProtectionConsentTestsMalformed90CharsVendorString =
    @"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

#define CR_AssertShouldSendEvent(consentString, usPrivacyCriteoState, shouldSendAppEvent) \
  do {                                                                                    \
    [self _checkShouldSendAppEvent:shouldSendAppEvent                                     \
          withUsPrivacyCriteoState:usPrivacyCriteoState                                   \
                  iabConsentString:consentString                                          \
                            atLine:__LINE__];                                             \
  } while (0);

@interface CR_DataProtectionConsentTests : XCTestCase

@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, assign) BOOL defaultGdprApplies;
@property(nonatomic, strong) NSString *defaultConsentString;

@property(nonatomic, strong) CR_DataProtectionConsent *consent1;
@property(nonatomic, strong) CR_DataProtectionConsent *consent2;

@end

@implementation CR_DataProtectionConsentTests

- (void)setUp {
  self.userDefaults = OCMPartialMock([[CR_InMemoryUserDefaults alloc] init]);
  self.defaultGdprApplies = YES;
  [self.userDefaults setObject:@(self.defaultGdprApplies) forKey:@"IABConsent_SubjectToGDPR"];

  self.defaultConsentString = CR_DataProtectionConsentMockDefaultConsentString;
  [self.userDefaults setObject:self.defaultConsentString forKey:@"IABConsent_ConsentString"];

  self.consent1 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
  self.consent2 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
}

- (void)tearDown {
  self.userDefaults = nil;
  [[NSUserDefaults standardUserDefaults]
      removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
  [NSUserDefaults resetStandardUserDefaults];
  [super tearDown];
}

- (void)testGetUsPrivacyIABContent {
  [self.userDefaults setObject:CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString
                        forKey:CR_CcpaIabConsentStringKey];

  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  NSString *actualUspIab = consent.usPrivacyIabConsentString;
  XCTAssertEqualObjects(actualUspIab, CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)testGetUsPrivacyCriteoStateUnset {
  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  XCTAssertEqual(consent.usPrivacyCriteoState, CR_CcpaCriteoStateUnset);
}

- (void)testGetUsPrivacyCriteoStateOptIn {
  [self.userDefaults setInteger:CR_CcpaCriteoStateOptIn forKey:CR_CcpaCriteoStateKey];

  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  XCTAssertEqual(consent.usPrivacyCriteoState, CR_CcpaCriteoStateOptIn);
}

- (void)testGetUsPrivacyCriteoStateOptOut {
  [self.userDefaults setInteger:CR_CcpaCriteoStateOptOut forKey:CR_CcpaCriteoStateKey];

  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  XCTAssertEqual(consent.usPrivacyCriteoState, CR_CcpaCriteoStateOptOut);
}

- (void)testSetUsPrivacyCriteoStateOptOut {
  self.consent1.usPrivacyCriteoState = CR_CcpaCriteoStateOptOut;

  XCTAssertEqual(self.consent2.usPrivacyCriteoState, CR_CcpaCriteoStateOptOut);
}

#pragma mark - Consent Given

- (void)testConsentGivenInitialDefaultValue {
  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  XCTAssertFalse(consent.isConsentGiven);
}

- (void)testConsentGivenInitialValue {
  [self.userDefaults setBool:YES forKey:CR_DataProtectionConsentGivenKey];

  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  XCTAssertTrue(consent.isConsentGiven);
}

- (void)testConsentGivenWhenSet {
  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  consent.consentGiven = YES;

  OCMVerify([self.userDefaults setBool:YES forKey:CR_DataProtectionConsentGivenKey]);
  XCTAssertTrue(consent.isConsentGiven);
}

#pragma mark - ShouldSendAppEvent

- (void)testShouldSendAppEventWithUsPrivacy {
  // All cases for the CCPA Criteo State only.
  CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateOptIn, YES);
  CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateOptOut, NO);
  CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, YES);

  // CCPA Criteo State with IAB Consent empty.
  CR_AssertShouldSendEvent(@"", CR_CcpaCriteoStateUnset, YES);
  CR_AssertShouldSendEvent(@"", CR_CcpaCriteoStateOptOut, NO);

  // Not-empty IAB consent string takes over the criteo state.
  CR_AssertShouldSendEvent(@"random string", CR_CcpaCriteoStateOptIn, YES);
  CR_AssertShouldSendEvent(@"random string", CR_CcpaCriteoStateOptOut, YES);

  // Opt-in IAB consent strings including lowercases.
  CR_AssertShouldSendEvent(@"1---", CR_CcpaCriteoStateUnset, YES);
  CR_AssertShouldSendEvent(@"1YNY", CR_CcpaCriteoStateUnset, YES);
  CR_AssertShouldSendEvent(@"1yny", CR_CcpaCriteoStateUnset, YES);
  CR_AssertShouldSendEvent(@"1Ynn", CR_CcpaCriteoStateUnset, YES);
  CR_AssertShouldSendEvent(@"1Yn-", CR_CcpaCriteoStateUnset, YES);
  CR_AssertShouldSendEvent(@"1-n-", CR_CcpaCriteoStateUnset, YES);

  // Opt-in CCPA IAB Consent string takes over CriteoState.
  CR_AssertShouldSendEvent(@"1---", CR_CcpaCriteoStateOptOut, YES);
  CR_AssertShouldSendEvent(@"1YNY", CR_CcpaCriteoStateOptOut, YES);
  CR_AssertShouldSendEvent(@"1YNN", CR_CcpaCriteoStateOptOut, YES);
  CR_AssertShouldSendEvent(@"1Yn-", CR_CcpaCriteoStateOptOut, YES);
  CR_AssertShouldSendEvent(@"1-n-", CR_CcpaCriteoStateOptOut, YES);

  // Opt-out CCPA IAB Consent string.
  CR_AssertShouldSendEvent(@"1yyy", CR_CcpaCriteoStateUnset, NO);
  CR_AssertShouldSendEvent(@"1yyn", CR_CcpaCriteoStateUnset, NO);

  // Opt-out CCPA IAB Consent string takes over CCPA CriteoState.
  CR_AssertShouldSendEvent(@"1YYY", CR_CcpaCriteoStateOptIn, NO);
  CR_AssertShouldSendEvent(@"1YYN", CR_CcpaCriteoStateOptIn, NO);
}

#pragma mark Private for ShouldSendAppEvent

- (void)_checkShouldSendAppEvent:(BOOL)shouldSendAppEvent
        withUsPrivacyCriteoState:(CR_CcpaCriteoState)usPrivacyCriteoState
                iabConsentString:(NSString *)iabConsentString
                          atLine:(NSUInteger)lineNumber {
  if (iabConsentString) {
    [self.userDefaults setObject:iabConsentString forKey:CR_CcpaIabConsentStringKey];
  }
  [self.userDefaults setInteger:usPrivacyCriteoState forKey:CR_CcpaCriteoStateKey];

  CR_DataProtectionConsent *consent =
      [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

  if (consent.shouldSendAppEvent != shouldSendAppEvent) {
    NSString *desc = [[NSString alloc]
        initWithFormat:
            @"usPrivacyCriteoState = %ld & iabConsentString = %@ => shouldSendAppEvent %d",
            (long)usPrivacyCriteoState, iabConsentString, shouldSendAppEvent];
    NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    [self cr_recordFailureWithDescription:desc inFile:file atLine:lineNumber expected:YES];
  }

  [self.userDefaults removeObjectForKey:CR_CcpaCriteoStateKey];
  [self.userDefaults removeObjectForKey:CR_CcpaIabConsentStringKey];
}

@end
