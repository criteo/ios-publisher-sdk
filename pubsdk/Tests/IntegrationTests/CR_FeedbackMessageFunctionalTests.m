//
//  CR_FeedbackMessageFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 4/8/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_BidManagerBuilder+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkManagerSimulator.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSURL+Testing.h"
#import "XCTestCase+Criteo.h"

@interface CR_FeedbackMessageFunctionalTests : XCTestCase

@property (strong, nonatomic) Criteo *criteo;
@property (strong, nonatomic) OCMockObject *nsdateMock;

@end

@implementation CR_FeedbackMessageFunctionalTests

- (void)setUp {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    self.nsdateMock = OCMClassMock([NSDate class]);
}

- (void)tearDown {
    // We wait for the thread manager to be idle. The goal is to "unmock"
    // safely NSDate. We mock class methods of NSDate, and we had ABORT
    // signals comming for a thread doing unfinished business whereas
    // the associated test was finished on the main thread. This is an
    // erratic behavior and the stacktrace was always showing OCMockClass
    // API.
    CR_ThreadManager *threadManager = self.criteo.bidManagerBuilder.threadManager;
    [threadManager waiter_waitIdle];
    [self.nsdateMock stopMocking];
}

#define AssertHttpContentHasOneFeedback(httpContent) \
do { \
    XCTAssertNotNil(httpContent); \
    XCTAssertEqual([httpContent.requestBody[@"feedbacks"] count], 1,\
                   @"%@", httpContent.requestBody[@"feedbacks"]); \
} while (0)

#define AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, cachedBidUsed) \
do { \
    XCTAssertEqual([feedback[@"slots"] count], 1, @"%@", feedback); \
    XCTAssertEqualObjects(feedback[@"slots"][0][@"cachedBidUsed"], @(cachedBidUsed), @"%@", feedback); \
    XCTAssertNotNil(feedback[@"slots"][0][@"impressionId"], @"%@", feedback); \
} while (0)

- (void)testGivenPrefetchedBids_whenBidConsumed_thenFeedbackMessageSent {
    CRBannerAdUnit *adUnitForConsumation = [CR_TestAdUnits preprodBanner320x50];
    NSArray *adUnits = @[adUnitForConsumation, [CR_TestAdUnits preprodInterstitial]];
    [self prepareCriteoForGettingBidWithAdUnits:adUnits];

    [self.criteo getBidResponseForAdUnit:adUnitForConsumation];

    [self waitFeedbackMessageRequest];
    CR_HttpContent *content = [self feedbackMessageRequest];
    AssertHttpContentHasOneFeedback(content);
    NSDictionary *feedback = content.requestBody[@"feedbacks"][0];
    XCTAssertEqualObjects(feedback[@"cdbCallStartElapsed"], @0);
    XCTAssertNotNil(feedback[@"cdbCallEndElapsed"]);
    XCTAssertNotNil(feedback[@"elapsed"]);
    AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, YES);
}

- (void)testGivenNoBidReturned_whenBidConsumed_thenFeedbackMessageSent {
    CRBannerAdUnit *adUnitForNoBid = [CR_TestAdUnits randomBanner320x50];
    NSArray *adUnits = @[adUnitForNoBid, [CR_TestAdUnits preprodInterstitial]];
    [self prepareCriteoForGettingBidWithAdUnits:adUnits];

    [self.criteo getBidResponseForAdUnit:adUnitForNoBid];

    [self waitFeedbackMessageRequest];
    CR_HttpContent *content = [self feedbackMessageRequest];
    AssertHttpContentHasOneFeedback(content);
    NSDictionary *feedback = content.requestBody[@"feedbacks"][0];
    XCTAssertEqualObjects(feedback[@"cdbCallStartElapsed"], @0);
    XCTAssertNotNil(feedback[@"cdbCallEndElapsed"]);
    XCTAssertNil(feedback[@"elapsed"]);
    XCTAssertEqualObjects(feedback[@"isTimeout"], @0);
    AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, NO);
}

- (void)testGivenNetworkErrorOnPrefetch_whenGettingBid_thenSendFeedbackMessage {
    CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
    [self prepareBidRequestWithError:self.noConnectionError];
    [self prepareCriteoForGettingBidWithAdUnits:@[adUnit]];

    [self.criteo getBidResponseForAdUnit:adUnit];

    [self waitFeedbackMessageRequest];
    CR_HttpContent *content = [self feedbackMessageRequest];
    AssertHttpContentHasOneFeedback(content);
    NSDictionary *feedback = content.requestBody[@"feedbacks"][0];
    XCTAssertEqualObjects(feedback[@"cdbCallStartElapsed"], @0);
    XCTAssertNil(feedback[@"cdbCallEndElapsed"]);
    XCTAssertNil(feedback[@"elapsed"]);
    XCTAssertEqualObjects(feedback[@"isTimeout"], @0);
    AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, NO);
}

- (void)testGivenTimeoutErrorOnPrefetch_whenGettingBid_thenSendFeedbackMessage {
    CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
    [self prepareBidRequestWithError:self.timeoutError];
    [self prepareCriteoForGettingBidWithAdUnits:@[adUnit]];

    [self.criteo getBidResponseForAdUnit:adUnit];

    [self waitFeedbackMessageRequest];
    CR_HttpContent *content = [self feedbackMessageRequest];
    AssertHttpContentHasOneFeedback(content);
    NSDictionary *feedback = content.requestBody[@"feedbacks"][0];
    XCTAssertEqualObjects(feedback[@"cdbCallStartElapsed"], @0);
    XCTAssertNil(feedback[@"cdbCallEndElapsed"]);
    XCTAssertNil(feedback[@"elapsed"]);
    XCTAssertEqualObjects(feedback[@"isTimeout"], @1);
    AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, NO);
}

- (void)testGivenBidExpired_whenGettingBid_thenSendFeedbackMessage {
    CRAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
    [self prepareCriteoForGettingBidWithAdUnits:@[adUnit]];
    [self increaseCurrentDateWithDuration:CR_NetworkManagerSimulator.interstitialTtl];

    [self.criteo getBidResponseForAdUnit:adUnit];

    [self waitFeedbackMessageRequest];
    CR_HttpContent *content = [self feedbackMessageRequest];
    AssertHttpContentHasOneFeedback(content);
    NSDictionary *feedback = content.requestBody[@"feedbacks"][0];
    XCTAssertEqualObjects(feedback[@"cdbCallStartElapsed"], @0);
    XCTAssertNotNil(feedback[@"cdbCallEndElapsed"]);
    XCTAssertNil(feedback[@"elapsed"]);
    XCTAssertEqualObjects(feedback[@"isTimeout"], @0);
    AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, YES);
}

- (void)testGivenFeedbackRequestError_whenGettingBids_thenQueueingFeedbackMessage {
    CRAdUnit *adUnit1 = [CR_TestAdUnits preprodInterstitial];
    CRAdUnit *adUnit2 = [CR_TestAdUnits preprodBanner320x50];
    [self prepareCriteoForGettingBidWithAdUnits:@[adUnit1, adUnit2]];
    [self prepareFeedbackRequestWithError];

    [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit1];
    [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit2];
    [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit1];

    NSArray *feedbacks = [self.feedbackStorage popMessagesToSend];
    XCTAssertEqual(feedbacks.count, 3);
}

#pragma mark - Private

- (void)prepareCriteoForGettingBidWithAdUnits:(NSArray *)adUnits {
    [self.criteo testing_registerWithAdUnits:adUnits];
    [self.criteo testing_waitForRegisterHTTPResponses];
    [self.criteo.testing_networkCaptor clear];
}

- (void)prepareBidRequestWithError:(NSError *)error {
    [self preparePostResponseWithError:error
                            urlChecker:^BOOL(NSURL *url, CR_Config *config) {
                                return [url testing_isBidUrlWithConfig:config];
                            }];
}

- (void)prepareFeedbackRequestWithError {
    [self preparePostResponseWithError:self.timeoutError
                            urlChecker:^BOOL(NSURL *url, CR_Config *config) {
                                return [url testing_isFeedbackMessageUrlWithConfig:config];
                            }];
}

- (void)preparePostResponseWithError:(NSError *)error
                          urlChecker:(BOOL(^)(NSURL *url, CR_Config *config))urlChecker {
    CR_Config *config = self.criteo.bidManagerBuilder.config;
    id urlArg = [OCMArg checkWithBlock:^BOOL(NSURL *url) {
        return urlChecker(url, config);
    }];
    id handlerArg = [OCMArg invokeBlockWithArgs:[NSNull null], error, nil];
    OCMStub([self.criteo.testing_networkManagerMock postToUrl:urlArg
                                                     postBody:[OCMArg any]
                                              responseHandler:handlerArg]);
}

- (void)getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:(CRAdUnit *)adUnit {
    [self.criteo.testing_networkCaptor clear];
    [self.criteo getBidResponseForAdUnit:adUnit];

    CR_NetworkWaiterBuilder *builder = [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.criteo.config
                                                                         networkCaptor:self.criteo.testing_networkCaptor];
    CR_NetworkWaiter *waiter = builder  .withFeedbackMessageSent
                                        .withBid
                                        .withFinishedRequestsIncluded
                                        .build;
    const BOOL result = [waiter wait];
    XCTAssert(result);
}

- (void)increaseCurrentDateWithDuration:(NSTimeInterval)duration {
    NSDate *newNow = [[NSDate alloc] initWithTimeIntervalSinceNow:duration];
    OCMStub([(id)self.nsdateMock date]).andReturn(newNow);
}

- (NSError *)noConnectionError {
    NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                code:NSURLErrorNotConnectedToInternet
                                            userInfo:nil];
    return error;
}

- (NSError *)timeoutError {
    NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                code:NSURLErrorTimedOut
                                            userInfo:nil];
    return error;
}


- (void)waitFeedbackMessageRequest {
    CR_NetworkWaiterBuilder *builder = [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.criteo.config
                                                                         networkCaptor:self.criteo.testing_networkCaptor];
    CR_NetworkWaiter *waiter = builder.withFeedbackMessageSent.withFinishedRequestsIncluded.build;
    const BOOL result = [waiter wait];
    XCTAssert(result);
}

- (CR_HttpContent *)feedbackMessageRequest {
    NSArray<CR_HttpContent *> *requests = self.criteo.testing_networkCaptor.allRequests;
    NSUInteger index = [requests indexOfObjectPassingTest:^BOOL(CR_HttpContent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.url testing_isFeedbackMessageUrlWithConfig:self.criteo.config];
    }];
    CR_HttpContent *feedbackRequest = (index != NSNotFound) ? requests[index] : nil;
    return feedbackRequest;
}

- (CR_FeedbackStorage *)feedbackStorage {
    return self.criteo.bidManagerBuilder.feedbackStorage;
}

@end
