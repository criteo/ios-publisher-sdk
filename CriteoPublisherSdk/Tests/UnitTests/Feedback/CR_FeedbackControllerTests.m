//
//  CR_FeedbackControllerTests.m
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
#import "CR_Config.h"
#import "CR_ApiHandler.h"
#import "CR_FeedbackStorage.h"
#import "CR_FeedbackController.h"
#import "CriteoPublisherSdkTests-Swift.h"
#import "CR_CdbBidBuilder.h"

@interface CR_FeedbackControllerTests : XCTestCase

@property(nonatomic, strong) CR_FeedbackFileManagingMock *feedbackFileManagingMock;
@property(nonatomic, strong) CR_CASObjectQueue *feedbackSendingQueue;
@property(nonatomic, strong) CR_FeedbackStorage *feedbackStorage;
@property(nonatomic, strong) CR_ApiHandler *apiHandler;
@property(nonatomic, strong) CR_Config *config;

@property(nonatomic, strong) NSMutableArray<NSDate *> *mockedDates;
@property(nonatomic, strong) OCMockObject *nsDate;

@property(nonatomic, strong) NSMutableArray<NSNumber *> *mockedProfileIds;
@property(nonatomic, strong) CR_IntegrationRegistry *integrationRegistry;

@property(nonatomic, strong) NSMutableArray<NSString *> *mockedGeneratedIds;
@property(nonatomic, strong) OCMockObject *uniqueIdGenerator;

@property(nonatomic, strong) id<CR_FeedbackDelegate> feedbackController;

@end

@implementation CR_FeedbackControllerTests

- (void)setUp {
  [super setUp];

  self.feedbackFileManagingMock = [[CR_FeedbackFileManagingMock alloc] init];
  self.feedbackFileManagingMock.useReadWriteDictionary = YES;
  self.feedbackSendingQueue = [[CR_CASInMemoryObjectQueue alloc] init];
  self.feedbackStorage =
      [[CR_FeedbackStorage alloc] initWithFileManager:self.feedbackFileManagingMock
                                            withQueue:self.feedbackSendingQueue];

  self.apiHandler = OCMClassMock([CR_ApiHandler class]);
  self.config = [[CR_Config alloc] init];

  [self setUpMockedIntegrationRegistry];
  [self setUpMockedUniqueIdGenerator];
  [self setUpMockedClock];
  [self setUpFeedbackController];
}

- (void)tearDown {
  [self.nsDate stopMocking];
  [self.uniqueIdGenerator stopMocking];
  [super tearDown];
}

- (void)testOnCdbCallStarted_GivenDeactivatedCsm_DoNothing {
  [self prepareDisabledCsm];
  [self prepareStrictMockedFeedbackStorage];

  CR_CdbRequest *request = [self prepareCdbRequestWithProfileId:@42
                                                 requestGroupId:@"requestId"
                                                  impressionIds:@[ @"id" ]];

  [self.feedbackController onCdbCallStarted:request];

  [self assertNoInteractionOnFeedbackStorage];
}

- (void)testOnCdbCallStarted_GivenMultipleSlot_UpdateAllStartTimeAndRequestIdOfMetricsById {
  [self prepareEnabledCsm];

  CR_CdbRequest *request = [self prepareCdbRequestWithProfileId:@42
                                                 requestGroupId:@"myRequestId"
                                                  impressionIds:@[ @"id1", @"id2" ]];

  [self prepareMockedClock:42];
  NSNumber *profileId1 = @1337, *profileId2 = @4242;
  [self prepareProfileIdGenerator:profileId1];
  [self prepareProfileIdGenerator:profileId2];

  CR_FeedbackMessage *expected1 = [[CR_FeedbackMessage alloc] init];
  expected1.profileId = @42;
  expected1.requestGroupId = @"myRequestId";
  expected1.impressionId = @"id1";
  expected1.cdbCallStartTimestamp = @42000;

  CR_FeedbackMessage *expected2 = [[CR_FeedbackMessage alloc] init];
  expected2.profileId = @42;
  expected2.requestGroupId = @"myRequestId";
  expected2.impressionId = @"id2";
  expected2.cdbCallStartTimestamp = @42000;

  [self.feedbackController onCdbCallStarted:request];

  [self assertStorageOnlyContainsAll:@[ expected1, expected2 ]];
  [self assertQueueOnlyContainsAll:@[]];
}

- (void)testOnCdbCallResponse_GivenDeactivatedCsm_DoNothing {
  [self prepareDisabledCsm];
  [self prepareStrictMockedFeedbackStorage];

  CR_CdbRequest *request = [self prepareCdbRequestWithProfileId:@42
                                                 requestGroupId:@"requestId"
                                                  impressionIds:@[ @"id" ]];
  CR_CdbResponse *response = [[CR_CdbResponse alloc] init];

  [self.feedbackController onCdbCallResponse:response fromRequest:request];

  [self assertNoInteractionOnFeedbackStorage];
}

- (void)testOnCdbCallResponse_GivenNoBidAndInvalidBidAndValidBid_UpdateThemByIdAccordingly {
  [self prepareEnabledCsm];

  CR_CdbRequest *request =
      [self prepareCdbRequestWithProfileId:@42
                            requestGroupId:@"requestId"
                             impressionIds:@[ @"noBidId", @"invalidId", @"validId" ]];

  [self prepareMockedClock:1337];

  CR_CdbBid *invalidBid =
      CR_CdbBidBuilder.new.impressionId(@"invalidId").cpm(@"-1.0").zoneId(42).build;
  CR_CdbBid *validBid = CR_CdbBidBuilder.new.impressionId(@"validId").zoneId(1337).build;

  CR_CdbResponse *response = [[CR_CdbResponse alloc] init];
  response.cdbBids = @[ validBid, invalidBid ];

  CR_FeedbackMessage *expectedValid = [[CR_FeedbackMessage alloc] init];
  expectedValid.cdbCallEndTimestamp = @1337000;
  expectedValid.zoneId = @1337;

  CR_FeedbackMessage *expectedInvalid = [[CR_FeedbackMessage alloc] init];
  expectedInvalid.expired = YES;

  CR_FeedbackMessage *expectedNoBid = [[CR_FeedbackMessage alloc] init];
  expectedNoBid.cdbCallEndTimestamp = @1337000;
  expectedNoBid.expired = YES;

  [self.feedbackController onCdbCallResponse:response fromRequest:request];

  [self assertStorageOnlyContainsAll:@[ expectedValid ]];
  [self assertQueueOnlyContainsAll:@[ expectedInvalid, expectedNoBid ]];
}

- (void)testOnCdbCallFailure_GivenDeactivatedCsm_DoNothing {
  [self prepareDisabledCsm];
  [self prepareStrictMockedFeedbackStorage];

  CR_CdbRequest *request = [self prepareCdbRequestWithProfileId:@42
                                                 requestGroupId:@"requestId"
                                                  impressionIds:@[ @"id" ]];
  NSError *error = [[NSError alloc] init];

  [self.feedbackController onCdbCallFailure:error fromRequest:request];

  [self assertNoInteractionOnFeedbackStorage];
}

- (void)testOnCdbCallFailure_GivenTimeoutError_UpdateAllForTimeout {
  [self prepareEnabledCsm];

  CR_CdbRequest *request = [self prepareCdbRequestWithProfileId:@42
                                                 requestGroupId:@"requestId"
                                                  impressionIds:@[ @"id1", @"id2" ]];

  NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                              code:NSURLErrorTimedOut
                                          userInfo:nil];

  CR_FeedbackMessage *expected1 = [[CR_FeedbackMessage alloc] init];
  expected1.timeout = YES;
  expected1.expired = YES;

  CR_FeedbackMessage *expected2 = [[CR_FeedbackMessage alloc] init];
  expected2.timeout = YES;
  expected2.expired = YES;

  [self.feedbackController onCdbCallFailure:error fromRequest:request];

  [self assertStorageOnlyContainsAll:@[]];
  [self assertQueueOnlyContainsAll:@[ expected1, expected2 ]];
}

- (void)testOnCdbCallFailure_GivenNotATimeoutError_UpdateAllForNetworkError {
  [self prepareEnabledCsm];

  CR_CdbRequest *request = [self prepareCdbRequestWithProfileId:@42
                                                 requestGroupId:@"requestId"
                                                  impressionIds:@[ @"id1", @"id2" ]];

  NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                              code:NSURLErrorNetworkConnectionLost
                                          userInfo:nil];

  CR_FeedbackMessage *expected1 = [[CR_FeedbackMessage alloc] init];
  expected1.expired = YES;

  CR_FeedbackMessage *expected2 = [[CR_FeedbackMessage alloc] init];
  expected2.expired = YES;

  [self.feedbackController onCdbCallFailure:error fromRequest:request];

  [self assertStorageOnlyContainsAll:@[]];
  [self assertQueueOnlyContainsAll:@[ expected1, expected2 ]];
}

- (void)testOnBidConsumed_GivenDeactivatedCsm_DoNothing {
  [self prepareDisabledCsm];
  [self prepareStrictMockedFeedbackStorage];

  CR_CdbBid *bid = CR_CdbBidBuilder.new.impressionId(@"id").build;

  [self.feedbackController onBidConsumed:bid];

  [self assertNoInteractionOnFeedbackStorage];
}

- (void)testOnBidConsumed_GivenNotExpiredBid_SetElapsedTime {
  [self prepareEnabledCsm];

  CR_CdbBid *bid = CR_CdbBidBuilder.new.impressionId(@"id").build;

  [self prepareMockedClock:42];

  CR_FeedbackMessage *expected = [[CR_FeedbackMessage alloc] init];
  expected.elapsedTimestamp = @42000;

  [self.feedbackController onBidConsumed:bid];

  [self assertStorageOnlyContainsAll:@[]];
  [self assertQueueOnlyContainsAll:@[ expected ]];
}

- (void)testOnBidConsumed_GivenExpiredBid_SetExpiredFlag {
  [self prepareEnabledCsm];

  CR_CdbBid *bid = CR_CdbBidBuilder.new.impressionId(@"id").ttl(-1).build;

  CR_FeedbackMessage *expected = [[CR_FeedbackMessage alloc] init];
  expected.expired = YES;

  [self.feedbackController onBidConsumed:bid];

  [self assertStorageOnlyContainsAll:@[]];
  [self assertQueueOnlyContainsAll:@[ expected ]];
}

- (void)testSendFeedbackBatch_GivenDeactivatedCsm_DoNothing {
  [self prepareDisabledCsm];
  [self prepareStrictMockedFeedbackStorage];

  [self.feedbackController sendFeedbackBatch];

  [self assertNoInteractionOnFeedbackStorage];
}

#pragma mark - Private

- (void)setUpFeedbackController {
  self.feedbackController =
      [CR_FeedbackController controllerWithFeedbackStorage:self.feedbackStorage
                                                apiHandler:self.apiHandler
                                                    config:self.config];
}

- (void)setUpMockedIntegrationRegistry {
  self.integrationRegistry = OCMClassMock([CR_IntegrationRegistry class]);
  self.mockedProfileIds = [[NSMutableArray alloc] init];
  OCMStub([(id)self.integrationRegistry profileId])
      .andDo([self returnSequentialValues:self.mockedProfileIds]);
}

- (void)setUpMockedUniqueIdGenerator {
  self.uniqueIdGenerator = OCMClassMock([CR_UniqueIdGenerator class]);
  self.mockedGeneratedIds = [[NSMutableArray alloc] init];
  OCMStub([(id)self.uniqueIdGenerator generateId])
      .andDo([self returnSequentialValues:self.mockedGeneratedIds]);
}

- (void)setUpMockedClock {
  self.nsDate = OCMClassMock([NSDate class]);
  self.mockedDates = [[NSMutableArray alloc] init];
  OCMStub([(id)self.nsDate date]).andDo([self returnSequentialValues:self.mockedDates]);
}

- (CR_CdbRequest *)prepareCdbRequestWithProfileId:(NSNumber *)profileId
                                   requestGroupId:(NSString *)requestGroupId
                                    impressionIds:(NSArray<NSString *> *)impressionIds {
  [self prepareMockedIdGenerator:requestGroupId];

  NSMutableArray<CR_CacheAdUnit *> *adUnits = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < impressionIds.count; i++) {
    NSString *adUnitId = [NSString stringWithFormat:@"adUnit%lu", (unsigned long)i];
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:adUnitId
                                                                width:300
                                                               height:250];
    [adUnits addObject:adUnit];

    [self prepareMockedIdGenerator:impressionIds[i]];
  }

  CR_CdbRequest *request = [[CR_CdbRequest alloc] initWithProfileId:profileId adUnits:adUnits];
  [self prepareProfileIdGenerator:profileId];
  return request;
}

- (void)prepareMockedClock:(NSTimeInterval)dateInSeconds {
  NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dateInSeconds];
  [self.mockedDates addObject:date];
}

- (void)prepareProfileIdGenerator:(NSNumber *)profileId {
  [self.mockedProfileIds addObject:profileId];
}

- (void)prepareMockedIdGenerator:(NSString *)generatedId {
  [self.mockedGeneratedIds addObject:generatedId];
}

- (void)prepareEnabledCsm {
  self.config.csmEnabled = YES;
}

- (void)prepareDisabledCsm {
  self.config.csmEnabled = NO;
}

- (void)prepareStrictMockedFeedbackStorage {
  self.feedbackStorage = OCMStrictClassMock([CR_FeedbackStorage class]);
  [self setUpFeedbackController];
}

- (void)assertNoInteractionOnFeedbackStorage {
  // as the mock is strict, and nothing is expected, this will fail if there is an interaction.
  OCMVerifyAll((id)self.feedbackStorage);
}

- (void)assertStorageOnlyContainsAll:(NSArray<CR_FeedbackMessage *> *)allExpected {
  NSArray *feedbacks = self.feedbackFileManagingMock.writeFeedbackResults;
  [self assertContainer:feedbacks onlyContainsAll:allExpected];
}

- (void)assertQueueOnlyContainsAll:(NSArray<CR_FeedbackMessage *> *)allExpected {
  NSArray *feedbacks = [self.feedbackSendingQueue peek:NSUIntegerMax];
  [self assertContainer:feedbacks onlyContainsAll:allExpected];
}

- (void)assertContainer:(NSArray<CR_FeedbackMessage *> *)container
        onlyContainsAll:(NSArray<CR_FeedbackMessage *> *)allExpected {
  XCTAssertEqual(
      container.count, allExpected.count,
      "Expected container to only contain all expected elements but their lengths differ.\n"
      "Container length: %lu, expected elements length: %lu",
      (unsigned long)container.count, (unsigned long)allExpected.count);

  for (NSUInteger index = 0; index < allExpected.count; index++) {
    CR_FeedbackMessage *expectedMessage = allExpected[index];
    XCTAssertTrue(
        [container containsObject:expectedMessage],
        "Expected container to contain the element `%@` at index %lu but it is not found.\n"
        "Container: %@",
        expectedMessage, (unsigned long)index, container);
  }
}

- (void (^)(NSInvocation *))returnSequentialValues:(NSMutableArray *)values {
  __block NSNumber *index = @-1;

  return ^(NSInvocation *invocation) {
    NSUInteger currentIndex = index.unsignedIntegerValue;

    if (currentIndex + 1 < values.count) {
      currentIndex = currentIndex + 1;
    }

    if (currentIndex < values.count) {
      NSObject *value = values[currentIndex];
      [invocation setReturnValue:&value];
    }

    index = @(currentIndex);
  };
}

@end
