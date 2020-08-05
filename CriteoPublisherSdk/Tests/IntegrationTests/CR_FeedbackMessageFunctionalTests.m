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
#import "CR_DependencyProvider+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkManagerSimulator.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSURL+Testing.h"
#import "CR_FeedbackStorage.h"
#import "XCTestCase+Criteo.h"

@interface CR_FeedbackMessageFunctionalTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) OCMockObject *nsdateMock;

@end

@implementation CR_FeedbackMessageFunctionalTests

- (void)setUp {
  [super setUp];
  [self clearFileDisk];

  CR_DependencyProvider *dependencyProvider =
      CR_DependencyProvider.new.withIsolatedUserDefaults.withWireMockConfiguration
          .withListenedNetworkManager
          // We don't want to isolate the tests from the disk
          //.withIsolatedFeedbackStorage
          .withIsolatedNotificationCenter.withIsolatedIntegrationRegistry;

  self.criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProvider];
  self.nsdateMock = OCMClassMock([NSDate class]);
}

- (void)tearDown {
  // We wait for the thread manager to be idle. The goal is to "unmock"
  // safely NSDate. We mock class methods of NSDate, and we had ABORT
  // signals comming for a thread doing unfinished business whereas
  // the associated test was finished on the main thread. This is an
  // erratic behavior and the stacktrace was always showing OCMockClass
  // API.
  CR_ThreadManager *threadManager = self.criteo.dependencyProvider.threadManager;
  [threadManager waiter_waitIdle];
  [self.nsdateMock stopMocking];
  [self clearFileDisk];
  [super tearDown];
}

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

- (void)testGivenPrefetchedBids_whenBidConsumed_thenFeedbackMessageSent {
  CRBannerAdUnit *adUnitForConsumation = [CR_TestAdUnits preprodBanner320x50];
  NSArray *adUnits = @[ adUnitForConsumation, [CR_TestAdUnits preprodInterstitial] ];
  [self prepareCriteoForGettingBidWithAdUnits:adUnits];

  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnitForConsumation];

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

  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnitForNoBid];

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

  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit];

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

  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit];

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

  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit];

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

  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit1];
  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit2];
  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit1];

  NSArray *feedbacks = [self.feedbackStorage popMessagesToSend];
  XCTAssertEqual(feedbacks.count, 3);
}

- (void)testGivenFeedbackRequestError_whenGettingBids_thenFeedbackRequest {
  CRAdUnit *adUnit1 = [CR_TestAdUnits preprodInterstitial];
  CRAdUnit *adUnit2 = [CR_TestAdUnits preprodBanner320x50];
  [self prepareCriteoForGettingBidWithAdUnits:@[ adUnit1, adUnit2 ]];
  [self prepareFeedbackRequestWithError];

  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit1];
  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit2];
  [self getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:adUnit2];

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
  // Two bids was in the same request (and share a commun groupId)
  AssertArrayWithUniqueElements(requestGroupIds, 2);
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

- (void)getBidResponseAndWaitForPrefetchAndFeedbackWithAdUnit:(CRAdUnit *)adUnit {
  [self.criteo.testing_networkCaptor clear];
  [self.criteo getBidResponseForAdUnit:adUnit];

  CR_NetworkWaiterBuilder *builder =
      [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.criteo.config
                                        networkCaptor:self.criteo.testing_networkCaptor];
  CR_NetworkWaiter *waiter =
      builder.withFeedbackMessageSent.withBid.withFinishedRequestsIncluded.build;
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
      // framework. We simply skeep it.
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

@end
