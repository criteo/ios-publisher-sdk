//
//  CR_BidManagerTests.m
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
#import "DFPRequestClasses.h"
#import "CR_BidManager+Testing.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DeviceInfoMock.h"
#import "CR_FeedbackController.h"
#import "CR_HeaderBidding.h"
#import "CR_SynchronousThreadManager.h"
#import "CriteoPublisherSdkTests-Swift.h"
#import "CRBannerAdUnit.h"
#import "XCTestCase+Criteo.h"

static NSString *const CR_BidManagerTestsCpm = @"crt_cpm";
static NSString *const CR_BidManagerTestsDfpDisplayUrl = @"crt_displayurl";

#define CR_OCMockVerifyCallCdb(apiHandlerMock, adUnits) \
  OCMVerify([apiHandlerMock callCdb:adUnits             \
                            consent:[OCMArg any]        \
                             config:[OCMArg any]        \
                         deviceInfo:[OCMArg any]        \
                      beforeCdbCall:[OCMArg any]        \
                  completionHandler:[OCMArg any]]);

#define CR_OCMockRejectCallCdb(apiHandlerMock, adUnits) \
  OCMReject([apiHandlerMock callCdb:adUnits             \
                            consent:[OCMArg any]        \
                             config:[OCMArg any]        \
                         deviceInfo:[OCMArg any]        \
                      beforeCdbCall:[OCMArg any]        \
                  completionHandler:[OCMArg any]]);

@interface CR_BidManagerTests : XCTestCase

@property(nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property(nonatomic, strong) CR_CdbBid *bid1;

@property(nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property(nonatomic, strong) CR_CdbBid *bid2;

@property(nonatomic, strong) CR_CacheAdUnit *adUnitForEmptyBid;
@property(nonatomic, strong) CR_CacheAdUnit *adUnitUncached;

@property(nonatomic, strong) DFPRequest *dfpRequest;

@property(nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property(nonatomic, strong) CR_CacheManager *cacheManager;
@property(nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property(nonatomic, strong) CR_ConfigManager *configManagerMock;
@property(nonatomic, strong) CR_HeaderBidding *headerBiddingMock;
@property(nonatomic, strong) CR_ThreadManager *threadManager;
@property(nonatomic, strong) CR_SynchronousThreadManager *synchronousThreadManager;
@property(nonatomic, strong) CR_DependencyProvider *dependencyProvider;
@property(nonatomic, strong) CR_BidManager *bidManager;
@property(nonatomic, strong) id<CR_FeedbackDelegate> feedbackDelegateMock;

@end

@implementation CR_BidManagerTests

#pragma mark - Lifecycle

- (void)setUp {
  self.deviceInfoMock = [[CR_DeviceInfoMock alloc] init];
  self.cacheManager = OCMPartialMock([[CR_CacheManager alloc] init]);
  self.configManagerMock = OCMClassMock([CR_ConfigManager class]);
  self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);
  self.headerBiddingMock = OCMPartialMock(CR_HeaderBidding.new);
  self.synchronousThreadManager = [[CR_SynchronousThreadManager alloc] init];
  self.threadManager = self.synchronousThreadManager;
  self.feedbackDelegateMock = OCMProtocolMock(@protocol(CR_FeedbackDelegate));

  [self setupDependencies];

  self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1" width:300 height:250];
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;
  self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit2" width:200 height:100];
  self.bid2 =
      CR_CdbBidBuilder.new.adUnit(self.adUnit2).cpm(@"0.5").displayUrl(@"bid2.displayUrl").build;
  self.adUnitForEmptyBid = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitForEmptyBid"
                                                              width:300
                                                             height:250];
  self.adUnitUncached = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitUncached"
                                                           width:200
                                                          height:100];

  self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  self.cacheManager.bidCache[self.adUnit2] = self.bid2;
  self.cacheManager.bidCache[self.adUnitForEmptyBid] = [CR_CdbBid emptyBid];

  self.dfpRequest = [[DFPRequest alloc] init];
  self.dfpRequest.customTargeting = @{@"key_1" : @"object 1", @"key_2" : @"object_2"};

  [self.dependencyProvider.feedbackStorage popMessagesToSend];
}

- (void)setupDependencies {
  CR_DependencyProvider *dependencyProvider = [CR_DependencyProvider testing_dependencyProvider];
  dependencyProvider.threadManager = self.threadManager;
  dependencyProvider.configManager = self.configManagerMock;
  dependencyProvider.cacheManager = self.cacheManager;
  dependencyProvider.apiHandler = self.apiHandlerMock;
  dependencyProvider.deviceInfo = self.deviceInfoMock;
  dependencyProvider.headerBidding = self.headerBiddingMock;
  dependencyProvider.feedbackDelegate = self.feedbackDelegateMock;

  self.dependencyProvider = dependencyProvider;
  self.bidManager = [dependencyProvider bidManager];
}

- (void)tearDown {
  [self.dependencyProvider.feedbackStorage popMessagesToSend];
}

#pragma mark - Tests
#pragma mark Cache Bidding

- (void)testGetBidForCachedAdUnits {
  CR_CdbBid *bid1 = [self.bidManager getBidThenFetch:self.adUnit1];
  CR_CdbBid *bid2 = [self.bidManager getBidThenFetch:self.adUnit2];

  XCTAssertEqualObjects(self.bid1, bid1);
  XCTAssertEqualObjects(self.bid2, bid2);
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit2 ]);
}

- (void)testGetBidForUncachedAdUnit {
  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnitUncached];

  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnitUncached ]);
  XCTAssert(bid.isEmpty);
}

- (void)testGetEmptyBid {
  OCMReject([self.cacheManager removeBidForAdUnit:self.adUnitForEmptyBid]);

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnitForEmptyBid];

  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnitForEmptyBid ]);
  XCTAssert(bid.isEmpty);
}

- (void)testGetBidUncachedAdUnitInSilentMode {
  self.bidManager = [self.dependencyProvider bidManager];
  self.bidManager.cdbTimeToNextCall = INFINITY;  // in silent mode

  CR_OCMockRejectCallCdb(self.apiHandlerMock, @[ self.adUnitUncached ]);

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnitUncached];

  XCTAssert(bid.isEmpty);
}

- (void)testGetEmptyBidForAdUnitInSilentMode {
  self.bidManager = [self.dependencyProvider bidManager];
  self.bidManager.cdbTimeToNextCall = INFINITY;  // in silent mode

  CR_OCMockRejectCallCdb(self.apiHandlerMock, @[ self.adUnitForEmptyBid ]);

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnitForEmptyBid];

  XCTAssert(bid.isEmpty);
}

- (void)testGetBidWhenBeforeTimeToNextCall {
  self.bidManager = [self.dependencyProvider bidManager];
  self.bidManager.cdbTimeToNextCall =
      [[NSDate dateWithTimeIntervalSinceNow:360] timeIntervalSinceReferenceDate];
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  self.cacheManager.bidCache[self.adUnit2] = self.bid2;

  CR_OCMockRejectCallCdb(self.apiHandlerMock, [OCMArg any]);

  CR_CdbBid *bid1 = [self.bidManager getBidThenFetch:self.adUnit1];
  CR_CdbBid *bid2 = [self.bidManager getBidThenFetch:self.adUnit2];

  XCTAssertEqualObjects(self.bid1, bid1);
  XCTAssertEqualObjects(self.bid2, bid2);
}

- (void)testGetBidForAdUnitInSilenceMode {
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  CR_OCMockRejectCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnit1];

  XCTAssert(bid.isEmpty);
}

- (void)testGetBidForBidWithSilencedModeElapsed {
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().expired().build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnit1];

  XCTAssert(bid.isEmpty);
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);
}

- (void)testGetBidWhenNoBid {
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).noBid().build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnit1];

  XCTAssertTrue(bid.isEmpty);
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);
}

- (void)testGetBidWhenBidExpired {
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expired().build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnit1];

  XCTAssertTrue(bid.isEmpty);
}

- (void)testInitDoNotRefreshConfiguration {
  OCMReject([self.configManagerMock refreshConfig:[OCMArg any]]);
}

- (void)testGetBid_GivenLiveBiddingIsEnabled_ThenFetchLiveBid {
  CR_CdbBidResponseHandler responseHandler = ^(CR_CdbBid *bid) {
  };
  self.bidManager = OCMPartialMock(self.bidManager);
  self.dependencyProvider.config.liveBiddingEnabled = YES;

  OCMExpect([self.bidManager fetchLiveBidForAdUnit:self.adUnit1 responseHandler:responseHandler]);
  OCMReject([self.bidManager getBidThenFetch:self.adUnit1]);

  [self.bidManager loadCdbBidForAdUnit:self.adUnit1 responseHandler:responseHandler];
}

- (void)testGetBid_GivenLiveBiddingIsDisabled_ThenGetBidThenFetch {
  CR_CdbBidResponseHandler responseHandler = ^(CR_CdbBid *bid) {
  };
  self.bidManager = OCMPartialMock(self.bidManager);
  self.dependencyProvider.config.liveBiddingEnabled = NO;

  OCMExpect([self.bidManager getBidThenFetch:self.adUnit1]);
  OCMReject([self.bidManager fetchLiveBidForAdUnit:self.adUnit1 responseHandler:responseHandler]);

  [self.bidManager loadCdbBidForAdUnit:self.adUnit1 responseHandler:responseHandler];
}

#pragma mark Live Bidding

- (void)testLiveBid_GivenResponseBeforeTimeBudget_ThenBidFromResponseGiven {
  CR_CdbBid *liveBid = [self givenApiHandlerRespondValidBid];
  self.synchronousThreadManager.isTimeout = NO;

  // Bid Manager returns bid from cdb call
  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           XCTAssertEqualObjects(bid, liveBid);
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  // Bid from cdb call has not been cached
  OCMReject([self.cacheManager setBid:[OCMArg any]]);
  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], liveBid);
}

- (void)testLiveBid_GivenResponseAfterTimeBudget_ThenBidFromCacheGiven {
  CR_CdbBid *liveBid = [self givenApiHandlerRespondValidBid];
  self.synchronousThreadManager.isTimeout = YES;

  // Bid Manager returns bid from cache
  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           XCTAssertEqualObjects(bid, self.bid1);
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  // Bid from cdb call has been cached
  OCMVerify([self.cacheManager setBid:liveBid]);
  XCTAssertEqual(self.cacheManager.bidCache[self.adUnit1], liveBid);
}

- (void)testLiveBid_GivenSilentMode_ThenCdbNotCalled_AndNoResponseGiven {
  self.bidManager = [self.dependencyProvider bidManager];
  self.bidManager.cdbTimeToNextCall = INFINITY;  // in silent mode

  CR_OCMockRejectCallCdb(self.apiHandlerMock, [OCMArg any]);
  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           XCTAssertNil(bid);
                         }];
}

- (void)testLiveBid_GivenSilentBid_ThenNoResponseGiven {
  CR_CdbBid *silentBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().build;
  [self givenApiHandlerRespondBid:silentBid];

  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           XCTAssertNil(bid);
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  // Silent bid from cdb call has been cached
  OCMVerify([self.cacheManager setBid:silentBid]);
  XCTAssertEqual(self.cacheManager.bidCache[self.adUnit1], silentBid);
}

- (void)testLiveBid_GivenInvalidBid_ThenNoResponseGiven {
  CR_CdbBid *invalidBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).displayUrl(nil).build;
  [self givenApiHandlerRespondBid:invalidBid];

  // Invalid bid from cdb call has not been cached
  OCMReject([self.cacheManager setBid:[OCMArg any]]);

  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           XCTAssertNil(bid);
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  // Invalid bid from cdb call has not been cached
  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], invalidBid);
}

- (void)testLiveBid_GivenExpiredBid_ThenNoResponseGiven {
  CR_CdbBid *expiredBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expired().build;
  [self givenApiHandlerRespondBid:expiredBid];

  // Expired bid from cdb call has not been cached
  OCMReject([self.cacheManager setBid:[OCMArg any]]);

  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           XCTAssertNil(bid);
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  // Expired bid from cdb call has not been cached
  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], expiredBid);
}

- (void)testLiveBid_GivenNoBid_ThenNoResponseGiven {
  CR_CdbBid *noBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).noBid().build;
  [self givenApiHandlerRespondBid:noBid];

  // No bid from cdb call has not been cached
  OCMReject([self.cacheManager setBid:[OCMArg any]]);

  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           XCTAssertNil(bid);
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  // No bid from cdb call has not been cached
  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], noBid);
}

- (void)testLiveBid_GivenConcurrentCalls_ThenBidsFromResponsesGivenWithOrder {
  // Enable asynchronous queueing
  self.threadManager = [[CR_ThreadManager alloc] init];
  [self setupDependencies];
  // Increase default test time budget
  self.dependencyProvider.config.liveBiddingTimeBudget = 3;

  // Request a slow bid with 1s
  XCTestExpectation *slowBidExpectation = [self bidExpectationWithDelay:1];

  // Reset dependencies to setup a new response mock
  self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);
  [self setupDependencies];
  // Increase default test time budget
  self.dependencyProvider.config.liveBiddingTimeBudget = 3;

  // Request a fast bid with 0.1s
  XCTestExpectation *fastBidExpectation = [self bidExpectationWithDelay:.1];

  [self cr_waitShortlyForExpectationsWithOrder:@[ fastBidExpectation, slowBidExpectation ]];
}

#pragma mark - Header Bidding

- (void)testAddCriteoBidToNonBiddableObjectsDoesNotCrash {
  CRBid *bid = [self validBid];
  [self.bidManager enrichAdObject:[NSDictionary new] withBid:bid];
  [self.bidManager enrichAdObject:[NSSet new] withBid:bid];
  [self.bidManager enrichAdObject:@"1234abcd" withBid:bid];
  [self.bidManager enrichAdObject:(NSMutableDictionary *)nil withBid:bid];
}

- (void)testAddCriteoBidToRequestCallHeaderBidding {
  [self.bidManager enrichAdObject:self.dfpRequest withBid:self.validBid];

  OCMVerify([self.headerBiddingMock enrichRequest:self.dfpRequest
                                          withBid:self.bid1
                                           adUnit:self.adUnit1]);
}

#pragma mark - Private

- (CR_CdbBid *)givenApiHandlerRespondValidBidWithDelay:(NSTimeInterval)delay {
  CR_CdbBid *validBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;
  return [self givenApiHandlerRespondBid:validBid withDelay:delay];
}

- (CR_CdbBid *)givenApiHandlerRespondValidBid {
  return [self givenApiHandlerRespondValidBidWithDelay:0];
}

- (CR_CdbBid *)givenApiHandlerRespondBid:(CR_CdbBid *)bid withDelay:(NSTimeInterval)delay {
  CR_CdbResponse *cdbResponseMock = OCMClassMock(CR_CdbResponse.class);
  OCMStub([cdbResponseMock cdbBids]).andReturn(@[ bid ]);
  OCMStub([self.apiHandlerMock callCdb:[OCMArg any]
                               consent:[OCMArg any]
                                config:[OCMArg any]
                            deviceInfo:[OCMArg any]
                         beforeCdbCall:[OCMArg any]
                     completionHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        [NSThread sleepForTimeInterval:delay];
        CR_CdbCompletionHandler handler;
        [invocation getArgument:&handler atIndex:7];
        handler(nil, cdbResponseMock, nil);
      });
  return bid;
}

- (CR_CdbBid *)givenApiHandlerRespondBid:(CR_CdbBid *)bid {
  return [self givenApiHandlerRespondBid:bid withDelay:0];
}

- (XCTestExpectation *)bidExpectationWithDelay:(NSTimeInterval)delay {
  NSString *description = [NSString stringWithFormat:@"Bid expected after %2fs", delay];
  XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:description];
  CR_CdbBid *expectedBid = [self givenApiHandlerRespondValidBidWithDelay:delay];
  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                         responseHandler:^(CR_CdbBid *bid) {
                           [expectation fulfill];
                           XCTAssertEqualObjects(bid, expectedBid);
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);
  return expectation;
}

- (CRBid *)validBid {
  CRAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:self.adUnit1.adUnitId
                                                         size:self.adUnit1.size];
  return [[CRBid alloc] initWithCdbBid:self.bid1 adUnit:adUnit];
}

@end
