//
//  CR_FeedbackConsentGuardTests.m
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
#import <OCMock/OCMock.h>
#import "CR_FeedbackConsentGuard.h"
#import "CR_CdbRequest.h"
#import "CR_CdbResponse.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DataProtectionConsentMock.h"
#import "CriteoPublisherSdkTests-Swift.h"

@interface CR_FeedbackConsentGuardTests : XCTestCase

@property(nonatomic, strong) CR_FeedbackController *controller;
@property(nonatomic, strong) CR_DataProtectionConsentMock *consent;
@property(nonatomic, strong) CR_FeedbackConsentGuard *guard;

@end

@implementation CR_FeedbackConsentGuardTests

- (void)setUp {
  [super setUp];

  self.controller = OCMStrictClassMock([CR_FeedbackController class]);
  self.consent = [[CR_DataProtectionConsentMock alloc] init];
  self.guard = [[CR_FeedbackConsentGuard alloc] initWithController:self.controller
                                                           consent:self.consent];
}

#pragma mark - Purpose consent

- (void)testGuard_GivenPurpose1NoConsent_DoNothing {
  self.consent.gdprMock.purposeConsents[1] = @NO;

  [self verifyControllerCalled:NO];
}

- (void)testGuard_GivenPurpose7NoConsent_CallDelegate {
  self.consent.gdprMock.purposeConsents[7] = @NO;

  [self verifyControllerCalled:YES];
}

- (void)testGuard_GivenAllPurposesConsent_CallDelegate {
  // Mock by default give all consents
  [self verifyControllerCalled:YES];
}

#pragma mark - Publisher Restrictions

- (void)testGuard_GivenPublisherNotAllowed_DoNothing {
  self.consent.gdprMock.publisherRestrictions[1] = [NSString stringWithFormat:@"%91d", 0];

  [self verifyControllerCalled:NO];
}

- (void)testGuard_GivenPublisherRequireConsentAndHasConsent_CallDelegate {
  self.consent.gdprMock.publisherRestrictions[1] = [NSString stringWithFormat:@"%91d", 1];

  [self verifyControllerCalled:YES];
}

- (void)testGuard_GivenPublisherRequireConsentAndNoConsent_DoNothing {
  self.consent.gdprMock.publisherRestrictions[1] = [NSString stringWithFormat:@"%91d", 1];
  self.consent.gdprMock.purposeConsents[1] = @NO;

  [self verifyControllerCalled:NO];
}

- (void)testGuard_GivenPublisherRequireLegitimateInterest_DoNothing {
  self.consent.gdprMock.publisherRestrictions[1] = [NSString stringWithFormat:@"%91d", 2];

  [self verifyControllerCalled:NO];
}

#pragma mark - Vendor consent

- (void)testGuard_GivenCriteoVendorNoConsent_DoNothing {
  self.consent.gdprMock.vendorConsents[91] = @NO;

  [self verifyControllerCalled:NO];
}

- (void)testGuard_GivenCriteoVendorConsent_CallDelegate {
  self.consent.gdprMock.vendorConsents[91] = @YES;

  [self verifyControllerCalled:YES];
}

- (void)testGuard_GivenAllVendorConsent_CallDelegate {
  // Mock by default give all consents
  [self verifyControllerCalled:YES];
}

- (void)testGuard_GivenOtherVendorNoConsent_CallDelegate {
  self.consent.gdprMock.vendorConsents[19] = @NO;

  [self verifyControllerCalled:YES];
}

#pragma mark - Vendor legitimate interest

- (void)testGuard_GivenCriteoVendorNoLegitimateInterest_DoNothing {
  self.consent.gdprMock.vendorLegitimateInterests[91] = @NO;

  [self verifyControllerCalled:NO];
}

- (void)testGuard_GivenCriteoVendorLegitimateInterest_CallDelegate {
  self.consent.gdprMock.vendorLegitimateInterests[91] = @YES;

  [self verifyControllerCalled:YES];
}

- (void)testGuard_GivenAllVendorLegitimateInterest_CallDelegate {
  // Mock by default give all consents
  [self verifyControllerCalled:YES];
}

- (void)testGuard_GivenOtherVendorNoLegitimateInterest_CallDelegate {
  self.consent.gdprMock.vendorLegitimateInterests[19] = @NO;

  [self verifyControllerCalled:YES];
}

#pragma mark - Private

- (void)verifyControllerCalled:(BOOL)called {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
  CR_CdbResponse *response = OCMClassMock([CR_CdbResponse class]);
  NSError *failure = OCMClassMock([NSError class]);
  CR_CdbBid *bid = OCMClassMock([CR_CdbBid class]);
  if (called) {
    OCMExpect([self.controller onCdbCallStarted:request]);
    OCMExpect([self.controller onCdbCallResponse:response fromRequest:request]);
    OCMExpect([self.controller onCdbCallFailure:failure fromRequest:request]);
    OCMExpect([self.controller onBidConsumed:bid]);
    OCMExpect([self.controller sendFeedbackBatch]);
  }
  [self.guard onCdbCallStarted:request];
  [self.guard onCdbCallResponse:response fromRequest:request];
  [self.guard onCdbCallFailure:failure fromRequest:request];
  [self.guard onBidConsumed:bid];
  [self.guard sendFeedbackBatch];

  // Controller mock being strict, any non expected call will fail
  OCMVerifyAll((id)self.controller);
}

@end
