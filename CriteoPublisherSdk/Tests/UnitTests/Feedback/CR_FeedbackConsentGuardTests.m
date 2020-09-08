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

- (void)testOnCdbCallStarted_GivenPurpose1NoConsent_DoNothing {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
  self.consent.gdprMock.purposeConsents[1] = @NO;

  [self.guard onCdbCallStarted:request];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnCdbCallStarted_GivenPurpose7NoConsent_DoNothing {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
  self.consent.gdprMock.purposeConsents[7] = @NO;

  [self.guard onCdbCallStarted:request];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnCdbCallStarted_GivenAllPurposesConsent_CallDelegate {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);

  OCMExpect([self.controller onCdbCallStarted:request]);

  [self.guard onCdbCallStarted:request];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnCdbCallResponse_GivenNoConsent_DoNothing {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
  CR_CdbResponse *response = OCMClassMock([CR_CdbResponse class]);
  self.consent.gdprMock.purposeConsents[1] = @NO;

  [self.guard onCdbCallResponse:response fromRequest:request];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnCdbCallResponse_GivenConsent_CallDelegate {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
  CR_CdbResponse *response = OCMClassMock([CR_CdbResponse class]);

  OCMExpect([self.controller onCdbCallResponse:response fromRequest:request]);

  [self.guard onCdbCallResponse:response fromRequest:request];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnCdbCallFailure_GivenNoConsent_DoNothing {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
  NSError *failure = OCMClassMock([NSError class]);
  self.consent.gdprMock.purposeConsents[1] = @NO;

  [self.guard onCdbCallFailure:failure fromRequest:request];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnCdbCallFailure_GivenConsent_CallDelegate {
  CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
  NSError *failure = OCMClassMock([NSError class]);

  OCMExpect([self.controller onCdbCallFailure:failure fromRequest:request]);

  [self.guard onCdbCallFailure:failure fromRequest:request];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnBidConsumed_GivenNoConsent_DoNothing {
  CR_CdbBid *bid = OCMClassMock([CR_CdbBid class]);
  self.consent.gdprMock.purposeConsents[1] = @NO;

  [self.guard onBidConsumed:bid];

  OCMVerifyAll((id)self.controller);
}

- (void)testOnBidConsumed_GivenConsent_CallDelegate {
  CR_CdbBid *bid = OCMClassMock([CR_CdbBid class]);

  OCMExpect([self.controller onBidConsumed:bid]);

  [self.guard onBidConsumed:bid];

  OCMVerifyAll((id)self.controller);
}

- (void)testSendFeedbackBatch_GivenNoConsent_DoNothing {
  self.consent.gdprMock.purposeConsents[1] = @NO;

  [self.guard sendFeedbackBatch];

  OCMVerifyAll((id)self.controller);
}

- (void)testSendFeedbackBatch_GivenConsent_CallDelegate {
  OCMExpect([self.controller sendFeedbackBatch]);

  [self.guard sendFeedbackBatch];

  OCMVerifyAll((id)self.controller);
}

@end
