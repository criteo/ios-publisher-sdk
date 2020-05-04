//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CR_FeedbackFeatureGuard.h"
#import "CR_CdbRequest.h"
#import "CR_CdbResponse.h"
#import "CR_Config.h"

@interface CR_FeedbackFeatureGuardTests : XCTestCase

@property(nonatomic, strong) CR_FeedbackController *controller;
@property(nonatomic, strong) CR_Config *config;

@end

@implementation CR_FeedbackFeatureGuardTests


- (void)setUp {
    [super setUp];

    self.controller = OCMStrictClassMock([CR_FeedbackController class]);
    self.config = [[CR_Config alloc] init];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma ide diagnostic ignored "UnusedValue"
- (void)testDealloc_GivenFreedFeatureGuardAndConfigChange_DoNotThrow {
    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    featureGuard = nil;

    self.config.csmEnabled = YES;
}
#pragma clang diagnostic pop

- (void)testOnCdbCallStarted_GivenDisabledCsm_DoNothing {
    CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
    self.config.csmEnabled = NO;

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onCdbCallStarted:request];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnCdbCallStarted_GivenEnabledCsm_CallDelegate {
    CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
    self.config.csmEnabled = YES;

    OCMExpect([self.controller onCdbCallStarted:request]);

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onCdbCallStarted:request];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnCdbCallStarted_GivenEnabledCsmThenDisabled_DoNothing {
    CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);

    self.config.csmEnabled = YES;
    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    self.config.csmEnabled = NO;

    [featureGuard onCdbCallStarted:request];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnCdbCallResponse_GivenDisabledCsm_DoNothing {
    CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
    CR_CdbResponse *response = OCMClassMock([CR_CdbResponse class]);
    self.config.csmEnabled = NO;

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onCdbCallResponse:response fromRequest:request];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnCdbCallResponse_GivenEnabledCsm_CallDelegate {
    CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
    CR_CdbResponse *response = OCMClassMock([CR_CdbResponse class]);
    self.config.csmEnabled = YES;

    OCMExpect([self.controller onCdbCallResponse:response fromRequest:request]);

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onCdbCallResponse:response fromRequest:request];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnCdbCallFailure_GivenDisabledCsm_DoNothing {
    CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
    NSError *failure = OCMClassMock([NSError class]);
    self.config.csmEnabled = NO;

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onCdbCallFailure:failure fromRequest:request];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnCdbCallFailure_GivenEnabledCsm_CallDelegate {
    CR_CdbRequest *request = OCMClassMock([CR_CdbRequest class]);
    NSError *failure = OCMClassMock([NSError class]);
    self.config.csmEnabled = YES;

    OCMExpect([self.controller onCdbCallFailure:failure fromRequest:request]);

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onCdbCallFailure:failure fromRequest:request];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnBidConsumed_GivenDisabledCsm_DoNothing {
    CR_CdbBid *bid = OCMClassMock([CR_CdbBid class]);
    self.config.csmEnabled = NO;

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onBidConsumed:bid];

    OCMVerifyAll((id) self.controller);
}

- (void)testOnBidConsumed_GivenEnabledCsm_CallDelegate {
    CR_CdbBid *bid = OCMClassMock([CR_CdbBid class]);
    self.config.csmEnabled = YES;

    OCMExpect([self.controller onBidConsumed:bid]);

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard onBidConsumed:bid];

    OCMVerifyAll((id) self.controller);
}

- (void)testSendFeedbackBatch_GivenDisabledCsm_DoNothing {
    self.config.csmEnabled = NO;

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard sendFeedbackBatch];

    OCMVerifyAll((id) self.controller);
}

- (void)testSendFeedbackBatch_GivenEnabledCsm_CallDelegate {
    self.config.csmEnabled = YES;

    OCMExpect([self.controller sendFeedbackBatch]);

    CR_FeedbackFeatureGuard *featureGuard = [self createFeatureGuard];
    [featureGuard sendFeedbackBatch];

    OCMVerifyAll((id) self.controller);
}

- (CR_FeedbackFeatureGuard *)createFeatureGuard {
    return [[CR_FeedbackFeatureGuard alloc] initWithController:self.controller config:self.config];
}

@end
