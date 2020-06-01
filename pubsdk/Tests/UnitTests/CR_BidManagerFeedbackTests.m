//
//  CR_BidManagerFeedbackTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "pubsdkTests-Swift.h"
#import "CR_CdbResponse.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_SynchronousThreadManager.h"

@interface CR_BidManagerFeedbackTests : XCTestCase

@property (nonatomic, strong) CR_CacheAdUnit *adUnit;
@property (nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property (nonatomic, strong) CR_CdbRequest *cdbRequest;
@property (nonatomic, strong) NSString *impressionId;
@property (nonatomic, strong) NSString *impressionId2;
@property (nonatomic, strong) CR_CdbBid *validBid;
@property (nonatomic, strong) CR_CdbBid *validBid2;
@property (nonatomic, strong) CR_CdbResponse *cdbResponse;
@property (nonatomic, strong) CR_FeedbackMessage *defaultMessage;

@property (nonatomic, strong) CR_CacheAdUnit *adUnitForInvalidBid;
@property (nonatomic, strong) CR_CdbRequest *cdbRequestForInvalidBid;
@property (nonatomic, strong) NSString *impressionIdForInvalidBid;
@property (nonatomic, strong) CR_CdbBid *invalidBid;
@property (nonatomic, strong) CR_CdbResponse *cdbResponseWithInvalidBid;

@property (nonatomic, strong) CR_FeedbackFileManagingMock *feedbackFileManagingMock;
@property (nonatomic, strong) CASObjectQueue *feedbackSendingQueue;
@property (nonatomic, strong) CR_BidManager *bidManager;
@property (nonatomic, strong) CR_CacheManager *cacheManager;
@property (nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property (nonatomic, strong) NSArray<CR_FeedbackMessage *> *lastSentMessages;

@property (nonatomic, strong) NSNumber *dateInMillisecondsNumber;
@property (nonatomic, strong) OCMockObject *nsdateMock;

@property (nonatomic, strong) NSString *generatedId;
@property (nonatomic, strong) OCMockObject *uniqueIdGeneratorMock;

@end

@implementation CR_BidManagerFeedbackTests

- (void)setUp {
    self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);
    OCMStub([self.apiHandlerMock sendFeedbackMessages:[OCMArg any]
                                               config:[OCMArg any]
                                    completionHandler:[OCMArg any]];)
        .andCall(self, @selector(captureSentMessages:));
    self.cacheManager = [[CR_CacheManager alloc] init];
    self.feedbackFileManagingMock = [[CR_FeedbackFileManagingMock alloc] init];
    self.feedbackFileManagingMock.useReadWriteDictionary = YES;
    self.feedbackSendingQueue = [[CASInMemoryObjectQueue alloc] init];
    CR_FeedbackStorage *feedbackStorage = [[CR_FeedbackStorage alloc] initWithFileManager:self.feedbackFileManagingMock
                                                                                withQueue:self.feedbackSendingQueue];

    CR_DependencyProvider *dependencyProvider = [CR_DependencyProvider testing_dependencyProvider];
    dependencyProvider.threadManager = [[CR_SynchronousThreadManager alloc] init];
    dependencyProvider.deviceInfo = [[CR_DeviceInfoMock alloc] init];
    dependencyProvider.apiHandler = self.apiHandlerMock;
    dependencyProvider.cacheManager = self.cacheManager;
    dependencyProvider.feedbackStorage = feedbackStorage;

    self.bidManager = [dependencyProvider buildBidManager];

    self.adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitForValid" width:300 height:250];
    self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitForValid2" width:300 height:250];
    self.cdbRequest = [[CR_CdbRequest alloc] initWithAdUnits:@[self.adUnit]];
    self.impressionId = [self.cdbRequest impressionIdForAdUnit:self.adUnit];
    self.impressionId2 = [self.cdbRequest impressionIdForAdUnit:self.adUnit2];
    self.validBid = CR_CdbBidBuilder.new.adUnit(self.adUnit).impressionId(self.impressionId).build;
    self.validBid2 = CR_CdbBidBuilder.new.adUnit(self.adUnit2).impressionId(self.impressionId2).build;
    self.cdbResponse = [[CR_CdbResponse alloc] init];
    self.cdbResponse.cdbBids = @[self.validBid, self.validBid2];

    self.adUnitForInvalidBid = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitForInvalid" width:300 height:250];
    self.cdbRequestForInvalidBid = [[CR_CdbRequest alloc] initWithAdUnits:@[self.adUnitForInvalidBid]];
    self.impressionIdForInvalidBid = [self.cdbRequestForInvalidBid impressionIdForAdUnit:self.adUnitForInvalidBid];
    self.invalidBid = CR_CdbBidBuilder.new.adUnit(self.adUnitForInvalidBid).impressionId(self.impressionIdForInvalidBid).cpm(@"-99.00").build;
    self.cdbResponseWithInvalidBid = [[CR_CdbResponse alloc] init];
    self.cdbResponseWithInvalidBid.cdbBids = @[self.invalidBid];

    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    NSTimeInterval dateInMilliseconds = [date timeIntervalSince1970] * 1000.0;
    self.dateInMillisecondsNumber = [[NSNumber alloc] initWithDouble:dateInMilliseconds];

    self.nsdateMock = OCMClassMock([NSDate class]);
    OCMStub([(id)self.nsdateMock date]).andReturn(date);

    self.generatedId = @"ID generated by a mocked CR_UniqueIdGenerator";
    self.uniqueIdGeneratorMock = OCMClassMock([CR_UniqueIdGenerator class]);
    OCMStub([(id)self.uniqueIdGeneratorMock generateId]).andReturn(self.generatedId);

    self.defaultMessage = [[CR_FeedbackMessage alloc] init];
    self.defaultMessage.requestGroupId = self.generatedId;
    self.defaultMessage.impressionId = self.impressionId;
    self.defaultMessage.cdbCallStartTimestamp = self.dateInMillisecondsNumber;
}

- (void)captureSentMessages:(NSArray<CR_FeedbackMessage *> *)messages {
    self.lastSentMessages = messages;
}

- (void)tearDown {
    self.lastSentMessages = nil;
    [self.nsdateMock stopMocking];
    [self.uniqueIdGeneratorMock stopMocking];
    [super tearDown];
}

#pragma mark - Feedback Message State
// Relies on the diagram introduced here:
// https://confluence.criteois.com/display/PUBSDK/Publisher+SDK+-+Client+Side+Metrics

- (void)testFeedbackMessageStateBeforeBidRequest {
    [self invokeBeforeCdbHandlerOnBidRequestWithCdbRequest:self.cdbRequest];

    [self.bidManager prefetchBid:self.adUnit];

    CR_FeedbackMessage *message = self.feedbackFileManagingMock.writeFeedbackResults.lastObject;
    XCTAssertEqualObjects(message, self.defaultMessage);
}

- (void)testFetchingBids_ShouldUpdateCdbCallRequestGroupId {
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest cdbResponse:self.cdbResponse error:nil];
    [self.bidManager prefetchBid:self.adUnit];

    NSArray<CR_FeedbackMessage *> *feedbacks = [self.feedbackFileManagingMock writeFeedbackResults];
    NSString *requestGroupId = feedbacks[0].requestGroupId;
    NSString *requestGroupId2 = feedbacks[1].requestGroupId;
    XCTAssertNotNil(requestGroupId);
    XCTAssertEqual(requestGroupId, requestGroupId2, @"requestGroupId should be identical for all feedbacks related to same request");
}

- (void)testFeedbackMessageStateOnValidBidReceived {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.cdbCallEndTimestamp = self.dateInMillisecondsNumber;
    expected.cachedBidUsed = YES;
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];

    [self.bidManager prefetchBid:self.adUnit];

    CR_FeedbackMessage *message = self.feedbackFileManagingMock.writeFeedbackResults.lastObject;
    XCTAssertEqualObjects(message, expected);
}


- (void)testFeedbackMessageStateOnNoBidReceived {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.cdbCallEndTimestamp = self.dateInMillisecondsNumber;
    expected.expired = YES;
    self.cdbResponse.cdbBids = @[];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];

    [self.bidManager prefetchBid:self.adUnit];

    CR_FeedbackMessage *message = self.feedbackFileManagingMock.writeFeedbackResults.lastObject;
    XCTAssertEqualObjects(message, expected);
}

- (void)testFeedbackMessageStateOnTimeoutError {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.timeout = YES;
    expected.expired = YES;
    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                code:NSURLErrorTimedOut
                                            userInfo:nil];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:nil
                                          error:error];

    [self.bidManager prefetchBid:self.adUnit];

    CR_FeedbackMessage *message = self.lastSentMessages[0];
    XCTAssertEqualObjects(message, expected);
}

- (void)testFeedbackMessageStateOnNetworkError {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.expired = YES;
    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                code:NSURLErrorNetworkConnectionLost
                                            userInfo:nil];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:nil
                                          error:error];

    [self.bidManager prefetchBid:self.adUnit];

    CR_FeedbackMessage *message = self.lastSentMessages[0];
    XCTAssertEqualObjects(message, expected);
}

- (void)testFeedbackMessageStateOnInvalidBid {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.impressionId = self.impressionIdForInvalidBid;
    expected.expired = YES;
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequestForInvalidBid
                                    cdbResponse:self.cdbResponseWithInvalidBid
                                          error:nil];

    [self.bidManager prefetchBid:self.adUnitForInvalidBid];

    CR_FeedbackMessage *message = self.lastSentMessages[0];
    XCTAssertEqualObjects(message, expected);
}

- (void)testFeedbackMessageStateOnBidConsumed {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.cdbCallEndTimestamp = self.dateInMillisecondsNumber;
    expected.elapsedTimestamp = self.dateInMillisecondsNumber;
    expected.cachedBidUsed = YES;
    // TODO: improve this test so that we don't need to call
    // the prefetchBid. Make sure that the message is already in
    // a state verified here: testFeedbackMessageStateOnValidBidReceived
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];
    [self.bidManager prefetchBid:self.adUnit];

    [self.bidManager getBid:self.adUnit];

    CR_FeedbackMessage *message = [self.feedbackSendingQueue peek:1][0];
    XCTAssertEqualObjects(message, expected);
}

- (void)testFeedbackMessageStateOnBidExpired {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.cdbCallEndTimestamp = self.dateInMillisecondsNumber;
    expected.expired = YES;
    expected.cachedBidUsed = YES;
    // TODO: improve this test so that we don't need to call
    // the prefetchBid. Make sure that the message is already in
    // a state verified here: testFeedbackMessageStateOnValidBidReceived
    CR_CdbBid *expired = CR_CdbBidBuilder.new.adUnit(self.adUnit).ttl(-1).impressionId(self.impressionId).build;
    self.cdbResponse.cdbBids = @[expired];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];
    [self.bidManager prefetchBid:self.adUnit];

    [self.bidManager getBid:self.adUnit];

    CR_FeedbackMessage *message = [self.feedbackSendingQueue peek:1][0];
    XCTAssertEqualObjects(message, expected);
}

- (void)testFeedbackMessageStateOnEmptyBid {
    CR_FeedbackMessage *expected = [self.defaultMessage copy];
    expected.cdbCallEndTimestamp = self.dateInMillisecondsNumber;
    expected.expired = YES;
    self.cdbResponse.cdbBids = @[];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];
    [self.bidManager registerWithSlots:@[self.adUnit]]; // fullfill the cache with an empty bid
    [self.bidManager prefetchBid:self.adUnit];

    [self.bidManager getBid:self.adUnit];

    CR_FeedbackMessage *message = self.lastSentMessages[0];
    XCTAssertEqualObjects(message, expected);
}

#pragma mark - Ready to send management

- (void)testReadyToSendOnValidBidReceived {
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];

    [self.bidManager prefetchBid:self.adUnit];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 1);
    XCTAssertEqual([self.feedbackSendingQueue size], 0);
}

- (void)testReadyToSendOnNoBidReceived {
    self.cdbResponse.cdbBids = @[];

    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];

    [self.bidManager prefetchBid:self.adUnit];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 0);
    XCTAssertEqual(self.lastSentMessages.count, 1);
}

- (void)testReadyToSendOnTimeoutError {
    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                code:NSURLErrorTimedOut
                                            userInfo:nil];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:nil
                                          error:error];

    [self.bidManager prefetchBid:self.adUnit];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 0);
    XCTAssertEqual(self.lastSentMessages.count, 1);
}

- (void)testReadyToSendOnNetworkError {
    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:(NSURLErrorTimedOut + 1) userInfo:nil];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest cdbResponse:nil error:error];

    [self.bidManager prefetchBid:self.adUnit];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 0);
    XCTAssertEqual(self.lastSentMessages.count, 1);
}

- (void)testReadyToSendOnInvalidBid {
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequestForInvalidBid
                                    cdbResponse:self.cdbResponseWithInvalidBid
                                          error:nil];

    [self.bidManager prefetchBid:self.adUnitForInvalidBid];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 0);
    XCTAssertEqual(self.lastSentMessages.count, 1);
}

- (void)testReadyToSendOnBidConsumed {
    // TODO: improve this test so that we don't need to call
    // the prefetchBid. Make sure that the message is already in
    // a state verified here: testFeedbackMessageStateOnValidBidReceived
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];
    [self.bidManager prefetchBid:self.adUnit];

    [self.bidManager getBid:self.adUnit];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 0);
    XCTAssertEqual([self.feedbackSendingQueue size], 1);
}

- (void)testReadyToSendOnBidExpired {
    CR_CdbBid *expiredBid = CR_CdbBidBuilder.new.adUnit(self.adUnit).ttl(-1).build;
    self.cacheManager.bidCache[self.adUnit] = expiredBid;

    [self.bidManager getBid:self.adUnit];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 0);
    XCTAssertEqual([self.feedbackSendingQueue size], 1);
}

- (void)testReadyToSendOnBidStateOnEmptyBid {
    self.cdbResponse.cdbBids = @[];
    [self configureApiHandlerMockWithCdbRequest:self.cdbRequest
                                    cdbResponse:self.cdbResponse
                                          error:nil];
    [self.bidManager registerWithSlots:@[self.adUnit]]; // fullfill the cache with an empty bid
    [self.bidManager prefetchBid:self.adUnit];
    self.lastSentMessages = nil;

    [self.bidManager getBid:self.adUnit];

    XCTAssertEqual(self.feedbackFileManagingMock.readWriteDictionary.count, 0);
    XCTAssertEqual([self.feedbackSendingQueue size], 0);
    XCTAssertNil(self.lastSentMessages);
}

#pragma mark - Private

- (void)configureApiHandlerMockWithCdbRequest:(CR_CdbRequest * _Nullable)cdbRequest
                                  cdbResponse:(CR_CdbResponse * _Nullable)cdbResponse
                                        error:(NSError * _Nullable)error {
    id beforeCdbCall = [OCMArg invokeBlockWithArgs:cdbRequest, nil];
    id completion = [OCMArg invokeBlockWithArgs:
                 (cdbRequest ? cdbRequest : [NSNull  null]),
                 (cdbResponse ? cdbResponse : [NSNull  null]),
                 (error ? error : [NSNull null]),
                 nil];
    OCMStub([self.apiHandlerMock callCdb:[OCMArg any]
                                 consent:[OCMArg any]
                                  config:[OCMArg any]
                              deviceInfo:[OCMArg any]
                           beforeCdbCall:beforeCdbCall
                       completionHandler:completion]);
}

- (void)invokeBeforeCdbHandlerOnBidRequestWithCdbRequest:(CR_CdbRequest * _Nullable)cdbRequest {
    id beforeCdbCall = [OCMArg invokeBlockWithArgs:cdbRequest, nil];
    OCMStub([self.apiHandlerMock callCdb:[OCMArg any]
                                 consent:[OCMArg any]
                                  config:[OCMArg any]
                              deviceInfo:[OCMArg any]
                           beforeCdbCall:beforeCdbCall
                       completionHandler:[OCMArg any]]);
}

@end
