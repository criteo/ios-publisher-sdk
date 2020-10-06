//
//  CR_FeedbackMessageFunctionalTests.m
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

#import <FunctionalObjC/FBLFunctional.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_Config.h"
#import "CR_FeedbackController.h"
#import "CR_FeedbackStorage.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkManagerSimulator.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSURL+Testing.h"

@interface CR_FeedbackMessageFunctionalTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) OCMockObject *nsdateMock;
@property(strong, nonatomic) CR_DependencyProvider *dependencyProvider;

@property(strong, nonatomic, readonly) CR_Config *config;

@end

@implementation CR_FeedbackMessageFunctionalTests

#pragma mark - Lifecycle

- (void)setUp {
  [super setUp];
  [self clearFileDisk];

  self.dependencyProvider =
      CR_DependencyProvider.new.withIsolatedUserDefaults.withWireMockConfiguration
          .withListenedNetworkManager
          // We don't want to isolate the tests from the disk
          //.withIsolatedFeedbackStorage
          .withIsolatedNotificationCenter.withIsolatedIntegrationRegistry;

  [self givenLiveBiddingEnabled:NO];  // Default legacy case
  self.criteo = [[Criteo alloc] initWithDependencyProvider:self.dependencyProvider];
  self.nsdateMock = OCMClassMock([NSDate class]);
}

- (void)tearDown {
  // We wait for the thread manager to be idle. The goal is to "unmock"
  // safely NSDate. We mock class methods of NSDate, and we had ABORT
  // signals coming for a thread doing unfinished business whereas
  // the associated test was finished on the main thread. This is an
  // erratic behavior and the stacktrace was always showing OCMockClass
  // API.
  CR_ThreadManager *threadManager = self.criteo.dependencyProvider.threadManager;
  [threadManager waiter_waitIdle];
  [self.nsdateMock stopMocking];
  [self clearFileDisk];
  [super tearDown];
}

#pragma mark - Macros

#define AssertHttpContentHasOneFeedback(httpContent)                        \
  do {                                                                      \
    XCTAssertNotNil(httpContent);                                           \
    XCTAssertEqual([httpContent.requestBody[@"feedbacks"] count], 1, @"%@", \
                   httpContent.requestBody[@"feedbacks"]);                  \
  } while (0)

#define AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, cachedBidUsed)                  \
  do {                                                                                      \
    XCTAssertEqual([feedback[@"slots"] count], 1, @"%@", feedback);                         \
    XCTAssertEqualObjects(feedback[@"slots"][0][@"cachedBidUsed"], @(cachedBidUsed), @"%@", \
                          feedback);                                                        \
    XCTAssertNotNil(feedback[@"slots"][0][@"impressionId"], @"%@", feedback);               \
    if (cachedBidUsed) {                                                                    \
      XCTAssertNotNil(feedback[@"slots"][0][@"zoneId"], @"%@", feedback);                   \
    } else {                                                                                \
      XCTAssertNil(feedback[@"slots"][0][@"zoneId"], @"%@", feedback);                      \
    }                                                                                       \
  } while (0)

#define AssertArrayWithUniqueElements(array, uniqueElementCount) \
  do {                                                           \
    NSSet *set = [[NSSet alloc] initWithArray:array];            \
    XCTAssertEqual(set.count, uniqueElementCount, @"%@", array); \
  } while (0)

#pragma mark - Tests
#pragma mark Cache bidding

- (void)testGivenPrefetchedBids_whenBidConsumed_thenFeedbackMessageSent {
  CRBannerAdUnit *adUnitForConsumption = [CR_TestAdUnits preprodBanner320x50];
  NSArray *adUnits = @[ adUnitForConsumption, [CR_TestAdUnits preprodInterstitial] ];
  [self prepareCriteoForGettingBidWithAdUnits:adUnits];

  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnitForConsumption];

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
  NSArray *adUnits = @[ adUnitForNoBid, [CR_TestAdUnits preprodInterstitial] ];
  [self prepareCriteoForGettingBidWithAdUnits:adUnits];

  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnitForNoBid];

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
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];

  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit];

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
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];

  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit];

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
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit ]];
  [self increaseCurrentDateWithDuration:CR_NetworkManagerSimulator.interstitialTtl];

  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit];

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
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit1, adUnit2 ]];
  [self prepareFeedbackRequestWithError];

  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit1];
  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit2];
  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit1];

  if (self.config.isLiveBiddingEnabled) {
    // FIXME: Giving some time for feedbacks to go back asynchronously to queue
    [NSThread sleepForTimeInterval:.3f];
  }

  NSArray *feedbacks = [self.feedbackStorage popMessagesToSend];
  XCTAssertEqual(feedbacks.count, 3);
}

- (void)testGivenFeedbackRequestError_whenGettingBids_thenFeedbackRequest {
  CRAdUnit *adUnit1 = [CR_TestAdUnits preprodInterstitial];
  CRAdUnit *adUnit2 = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit1, adUnit2 ]];
  [self prepareFeedbackRequestWithError];

  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit1];
  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit2];
  [self getBidAndWaitForFetchAndFeedbackWithAdUnit:adUnit2];

  // In live bidding mode, as metrics are sent in // with bid request, there is an offset,
  // so let's flush the remaining metrics
  if (self.config.isLiveBiddingEnabled) {
    [self sendFeedbacksAndWaitFeedbackSent];
  }
  CR_HttpContent *content = [self feedbackMessageRequest];
  XCTAssertNotNil(content);
  NSArray *feedbacks = content.requestBody[@"feedbacks"];
  XCTAssertEqual([feedbacks count], 3);
  for (NSUInteger index = 0; index < [feedbacks count]; index++) {
    NSDictionary *feedback = feedbacks[index];
    XCTAssertEqualObjects(feedback[@"cdbCallStartElapsed"], @0, @"index: %ld feedback: %@",
                          (unsigned long)index, feedback);
    XCTAssertNotNil(feedback[@"cdbCallEndElapsed"], @"index: %ld feedback: %@",
                    (unsigned long)index, feedback);
    XCTAssertNotNil(feedback[@"elapsed"], @"index: %ld feedback: %@", (unsigned long)index,
                    feedback);
    AssertFeedbackHasOneSlotWithCachedBidUsed(feedback, YES);
  }
  NSArray *impressionIds = [feedbacks fbl_flatMap:^id _Nullable(NSDictionary *value) {
    return value[@"slots"][0][@"impressionId"];
  }];
  NSArray *requestGroupIds = [feedbacks fbl_flatMap:^id _Nullable(NSDictionary *value) {
    return value[@"requestGroupId"];
  }];
  AssertArrayWithUniqueElements(impressionIds, 3);

  // Live bidding works as cache bidding when time budget is exceeded
  if (self.config.isLiveBiddingEnabled && !self.isLiveBidTimeBudgetExceeded) {
    // Three bids having each its own request
    AssertArrayWithUniqueElements(requestGroupIds, 3);
  } else {
    // Two bids was in the same request (and share a common groupId)
    AssertArrayWithUniqueElements(requestGroupIds, 2);
  }
}

#pragma mark Live bidding within time budget

- (void)testGivenPrefetchedBids_whenLiveBidConsumed_thenFeedbackMessageSent {
  [self givenLiveBiddingEnabled:YES];
  [self testGivenPrefetchedBids_whenBidConsumed_thenFeedbackMessageSent];
}

- (void)testGivenNoBidReturned_whenLiveBidConsumed_thenFeedbackMessageSent {
  [self givenLiveBiddingEnabled:YES];
  [self testGivenNoBidReturned_whenBidConsumed_thenFeedbackMessageSent];
}

- (void)testGivenNetworkErrorOnPrefetch_whenGettingLiveBid_thenSendFeedbackMessage {
  [self givenLiveBiddingEnabled:YES];
  [self testGivenNetworkErrorOnPrefetch_whenGettingBid_thenSendFeedbackMessage];
}

- (void)testGivenTimeoutErrorOnPrefetch_whenGettingLiveBid_thenSendFeedbackMessage {
  [self givenLiveBiddingEnabled:YES];
  [self testGivenTimeoutErrorOnPrefetch_whenGettingBid_thenSendFeedbackMessage];
}

- (void)testGivenFeedbackRequestError_whenGettingLiveBids_thenQueueingFeedbackMessage {
  [self givenLiveBiddingEnabled:YES];
  [self testGivenFeedbackRequestError_whenGettingBids_thenQueueingFeedbackMessage];
}

- (void)testGivenFeedbackRequestError_whenGettingLiveBids_thenFeedbackRequest {
  [self givenLiveBiddingEnabled:YES];
  [self testGivenFeedbackRequestError_whenGettingBids_thenFeedbackRequest];
}

#pragma mark Live bidding exceeding time budget

- (void)testGivenPrefetchedBids_whenLiveBidTimeBudgetExceeded_thenFeedbackMessageSent {
  [self givenLiveBidTimeBudgetExceeded];
  [self testGivenPrefetchedBids_whenBidConsumed_thenFeedbackMessageSent];
}

- (void)testGivenNoBidReturned_whenLiveBidTimeBudgetExceeded_thenFeedbackMessageSent {
  [self givenLiveBidTimeBudgetExceeded];
  [self testGivenNoBidReturned_whenBidConsumed_thenFeedbackMessageSent];
}

- (void)testGivenNetworkErrorOnPrefetch_whenLiveBidTimeBudgetExceeded_thenSendFeedbackMessage {
  [self givenLiveBidTimeBudgetExceeded];
  [self testGivenNetworkErrorOnPrefetch_whenGettingBid_thenSendFeedbackMessage];
}

- (void)testGivenTimeoutErrorOnPrefetch_whenLiveBidTimeBudgetExceeded_thenSendFeedbackMessage {
  [self givenLiveBidTimeBudgetExceeded];
  [self testGivenTimeoutErrorOnPrefetch_whenGettingBid_thenSendFeedbackMessage];
}

- (void)testGivenFeedbackRequestError_whenLiveBidsTimeBudgetExceeded_thenQueueingFeedbackMessage {
  [self givenLiveBidTimeBudgetExceeded];
  [self testGivenFeedbackRequestError_whenGettingBids_thenQueueingFeedbackMessage];
}

- (void)testGivenFeedbackRequestError_whenLiveBidsTimeBudgetExceeded_thenFeedbackRequest {
  [self givenLiveBidTimeBudgetExceeded];
  [self testGivenFeedbackRequestError_whenGettingBids_thenFeedbackRequest];
}

#pragma mark - Private

- (CR_Config *)config {
  return self.dependencyProvider.config;
}

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
                          urlChecker:(BOOL (^)(NSURL *url, CR_Config *config))urlChecker {
  CR_Config *config = self.criteo.dependencyProvider.config;
  id urlArg = [OCMArg checkWithBlock:^BOOL(NSURL *url) {
    return urlChecker(url, config);
  }];
  id handlerArg = [OCMArg invokeBlockWithArgs:[NSNull null], error, nil];
  OCMStub([self.criteo.testing_networkManagerMock postToUrl:urlArg
                                                   postBody:[OCMArg any]
                                            responseHandler:handlerArg]);
}

- (void)getBidAndWaitForFetchAndFeedbackWithAdUnit:(CRAdUnit *)adUnit {
  [self.criteo.testing_networkCaptor clear];

  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  [self.criteo getBid:cacheAdUnit
      responseHandler:^(CR_CdbBid *bid) {
        // In live bidding mode, as metrics are sent in // with bid request, there is an offset,
        // so let's flush the remaining metrics
        if (self.config.isLiveBiddingEnabled) {
          [self.dependencyProvider.feedbackDelegate sendFeedbackBatch];
        }
      }];
  CR_NetworkWaiterBuilder *builder =
      [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.criteo.config
                                        networkCaptor:self.criteo.testing_networkCaptor];
  CR_NetworkWaiter *waiter =
      builder.withFeedbackMessageSent.withBid.withFinishedRequestsIncluded.build;
  const BOOL result = [waiter wait];
  XCTAssert(result);
}

- (void)sendFeedbacksAndWaitFeedbackSent {
  [self.criteo.testing_networkCaptor clear];
  CR_NetworkWaiterBuilder *builder =
      [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.criteo.config
                                        networkCaptor:self.criteo.testing_networkCaptor];
  CR_NetworkWaiter *waiter = builder.withFeedbackMessageSent.withFinishedRequestsIncluded.build;

  [self.dependencyProvider.feedbackDelegate sendFeedbackBatch];
  XCTAssert([waiter wait]);
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

- (CR_HttpContent *)feedbackMessageRequest {
  NSArray<CR_HttpContent *> *requests = self.criteo.testing_networkCaptor.allRequests;
  NSUInteger index = [requests indexOfObjectPassingTest:^BOOL(CR_HttpContent *_Nonnull obj,
                                                              NSUInteger idx, BOOL *_Nonnull stop) {
    return [obj.url testing_isFeedbackMessageUrlWithConfig:self.criteo.config];
  }];
  CR_HttpContent *feedbackRequest = (index != NSNotFound) ? requests[index] : nil;
  return feedbackRequest;
}

- (CR_FeedbackStorage *)feedbackStorage {
  return self.criteo.dependencyProvider.feedbackStorage;
}

- (void)clearFileDisk {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray<NSURL *> *directoryUrls = [fileManager URLsForDirectory:NSLibraryDirectory
                                                        inDomains:NSUserDomainMask];
  NSArray<NSString *> *files = [directoryUrls fbl_flatMap:^id _Nullable(NSURL *_Nonnull directory) {
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtURL:directory
                                includingPropertiesForKeys:nil
                                                   options:0
                                                     error:&error];
    XCTAssertNil(error);
    return files;
  }];
  [files fbl_forEach:^(NSString *file) {
    NSError *error = nil;
    BOOL result = [fileManager removeItemAtPath:file error:&error];
    if ([self isPermissionError:error]) {
      // We have experienced a file named "Cache".
      // We didn't have the permission to remove it.
      // It may be the cache of WebKit or another
      // framework. We simply skip it.
      return;
    }

    XCTAssertNil(error);
    XCTAssert(result);
  }];
}

- (BOOL)isPermissionError:(NSError *)error {
  return [error.domain isEqualToString:NSCocoaErrorDomain] &&
         error.code == NSFileWriteNoPermissionError;
}

- (void)givenLiveBiddingEnabled:(BOOL)enabled {
  self.config.liveBiddingEnabled = enabled;
}

- (void)givenLiveBidTimeBudgetExceeded {
  self.dependencyProvider = [self.dependencyProvider withListenedNetworkManagerWithDelay:0.1f];
  self.config.liveBiddingEnabled = YES;
  self.config.liveBiddingTimeBudget = 0;
  self.criteo = [[Criteo alloc] initWithDependencyProvider:self.dependencyProvider];
}

- (BOOL)isLiveBidTimeBudgetExceeded {
  return self.config.liveBiddingEnabled && self.config.liveBiddingTimeBudget == 0;
}

@end
