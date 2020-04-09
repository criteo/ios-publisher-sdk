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
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "NSURL+Testing.h"
#import "XCTestCase+Criteo.h"

@interface CR_FeedbackMessageFunctionalTests : XCTestCase

@property (strong, nonatomic) Criteo *criteo;

@end

@implementation CR_FeedbackMessageFunctionalTests

- (void)setUp {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
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
    [self.criteo testing_registerWithAdUnits:adUnits];
    [self.criteo testing_waitForRegisterHTTPResponses];
    [self.criteo.testing_networkCaptor clear];

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
    [self.criteo testing_registerWithAdUnits:adUnits];
    [self.criteo testing_waitForRegisterHTTPResponses];
    [self.criteo.testing_networkCaptor clear];

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
    [self prepareBidRequestWithoutConnection];
    CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
    [self.criteo testing_registerWithAdUnits:@[adUnit]];
    [self.criteo testing_waitForRegisterHTTPResponses];
    [self.criteo.testing_networkCaptor clear];

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

#pragma mark - Private

- (void)prepareBidRequestWithoutConnection {
    CR_Config *config = self.criteo.bidManagerBuilder.config;
    id urlArg = [OCMArg checkWithBlock:^BOOL(NSURL *url) {
        return [url testing_isBidUrlWithConfig:config];
    }];
    id handlerArg = [OCMArg invokeBlockWithArgs:[NSNull null], self.noConnectionError, nil];
    OCMStub([self.criteo.testing_networkManagerMock postToUrl:urlArg
                                                     postBody:[OCMArg any]
                                              responseHandler:handlerArg]);
}

- (NSError *)noConnectionError {
    NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                code:NSURLErrorNotConnectedToInternet
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

@end
