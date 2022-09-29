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
#import "CR_Logging.h"
#import "CR_SynchronousThreadManager.h"
#import "CriteoPublisherSdkTests-Swift.h"
#import "CRBannerAdUnit.h"
#import "XCTestCase+Criteo.h"
#import "CRContextData.h"

#define CR_OCMockVerifyCallCdb(apiHandlerMock, adUnits) \
  OCMVerify([apiHandlerMock callCdb:adUnits             \
                            consent:[OCMArg any]        \
                             config:[OCMArg any]        \
                         deviceInfo:[OCMArg any]        \
                            context:[OCMArg any]        \
                      beforeCdbCall:[OCMArg any]        \
                  completionHandler:[OCMArg any]]);

#define CR_OCMockRejectCallCdb(apiHandlerMock, adUnits) \
  OCMReject([apiHandlerMock callCdb:adUnits             \
                            consent:[OCMArg any]        \
                             config:[OCMArg any]        \
                         deviceInfo:[OCMArg any]        \
                            context:[OCMArg any]        \
                      beforeCdbCall:[OCMArg any]        \
                  completionHandler:[OCMArg any]]);

@interface CR_BidManagerTests : XCTestCase

@property(nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property(nonatomic, strong) CR_CdbBid *bid1;

@property(nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property(nonatomic, strong) CR_CdbBid *bid2;

@property(nonatomic, strong) CR_CacheAdUnit *adUnitRewarded;
@property(nonatomic, strong) CR_CdbBid *bidRewarded;

@property(nonatomic, strong) CR_CacheAdUnit *adUnitForEmptyBid;
@property(nonatomic, strong) CR_CacheAdUnit *adUnitUncached;

@property(nonatomic, strong) CRContextData *contextData;

@property(nonatomic, strong) GAMRequest *request;

@property(nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property(nonatomic, strong) CR_CacheManager *cacheManager;
@property(nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property(nonatomic, readonly) CR_DataProtectionConsent *consent;
@property(nonatomic, strong) CR_ConfigManager *configManagerMock;
@property(nonatomic, strong) CR_HeaderBidding *headerBiddingMock;
@property(nonatomic, strong) id loggingMock;
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
  self.loggingMock = OCMPartialMock(CR_Logging.sharedInstance);

  [self setupDependencies];

  self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1" width:300 height:250];
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;
  self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit2" width:200 height:100];
  self.bid2 =
      CR_CdbBidBuilder.new.adUnit(self.adUnit2).cpm(@"0.5").displayUrl(@"bid2.displayUrl").build;

  self.adUnitRewarded = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitRewarded"
                                                            size:CGSizeMake(200, 100)
                                                      adUnitType:CRAdUnitTypeRewarded];
  self.bidRewarded = CR_CdbBidBuilder.new.adUnit(self.adUnitRewarded).build;
  self.adUnitForEmptyBid = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitForEmptyBid"
                                                              width:300
                                                             height:250];
  self.adUnitUncached = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitUncached"
                                                           width:200
                                                          height:100];

  self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  self.cacheManager.bidCache[self.adUnit2] = self.bid2;
  self.cacheManager.bidCache[self.adUnitForEmptyBid] = [CR_CdbBid emptyBid];
  self.cacheManager.bidCache[self.adUnitRewarded] = self.bidRewarded;

  self.request = [[GAMRequest alloc] init];
  self.request.customTargeting = @{@"key_1" : @"object 1", @"key_2" : @"object_2"};

  self.contextData = CRContextData.new;

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
  [self.loggingMock stopMocking];
  [self.dependencyProvider.feedbackStorage popMessagesToSend];
}

#pragma mark - Tests
#pragma mark Cache Bidding



// #######################################################################################################

- (void)testGetBid_GivenLiveBiddingIsEnabled_ThenFetchLiveBid {
  CR_CdbBidResponseHandler responseHandler = ^(CR_CdbBid *bid) {
    XCTAssertNil(bid);
  };
  self.bidManager = OCMPartialMock(self.bidManager);
  self.dependencyProvider.config.liveBiddingEnabled = YES;

  OCMExpect([self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                                       withContext:self.contextData
                                   responseHandler:responseHandler]);
  OCMReject([self.bidManager getBidThenFetch:self.adUnit1 withContext:self.contextData]);

  [self.bidManager loadCdbBidForAdUnit:self.adUnit1
                           withContext:self.contextData
                       responseHandler:responseHandler];
}

// #######################################################################################################



- (void)testGetBid_GivenLiveBiddingIsDisabled_ThenGetBidThenFetch {
  CR_CdbBidResponseHandler responseHandler = ^(CR_CdbBid *bid) {
    XCTAssertNil(bid);
  };
  self.bidManager = OCMPartialMock(self.bidManager);
  self.dependencyProvider.config.liveBiddingEnabled = NO;

  OCMExpect([self.bidManager getBidThenFetch:self.adUnit1 withContext:self.contextData]);
  OCMReject([self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                                       withContext:self.contextData
                                   responseHandler:responseHandler]);

  [self.bidManager loadCdbBidForAdUnit:self.adUnit1
                           withContext:self.contextData
                       responseHandler:responseHandler];
}

#pragma mark - Live Bidding
#pragma mark Helpers

- (void)expectBidConsumed:(CR_CdbBid *)bid {
  if (bid) {
    OCMExpect([self.feedbackDelegateMock onBidConsumed:bid]);
  } else {
    OCMReject([self.feedbackDelegateMock onBidConsumed:[OCMArg any]]);
  }
}

- (void)expectBidCached:(CR_CdbBid *)bid {
  if (bid) {
    OCMExpect([self.cacheManager setBid:bid]);
    OCMExpect([self.feedbackDelegateMock onBidCached:bid]);
  } else {
    OCMReject([self.cacheManager setBid:[OCMArg any]]);
    OCMReject([self.feedbackDelegateMock onBidCached:[OCMArg any]]);
  }
}

- (void)fetchLiveBidForAdUnit:(CR_CacheAdUnit *)adUnit
             andExpectCdbCall:(BOOL)cdbCalled
                    bidCached:(CR_CdbBid *)bidCached
                  bidConsumed:(CR_CdbBid *)bidConsumed
                 bidResponded:(CR_CdbBid *)bidResponded {
  [self expectBidCached:bidCached];
  [self expectBidConsumed:bidConsumed];

  if (!cdbCalled) {
    CR_OCMockRejectCallCdb(self.apiHandlerMock, [OCMArg any]);
  }
  [self.bidManager fetchLiveBidForAdUnit:adUnit
                             withContext:self.contextData
                         responseHandler:^(CR_CdbBid *bid) {
                           if (bidResponded) {
                             XCTAssertEqualObjects(bid, bidResponded);
                           } else {
                             XCTAssertTrue(!bid || bid.isEmpty);
                           }
                         }];
  if (cdbCalled) {
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ adUnit ]);
  }

  OCMVerifyAll(self.cacheManager);
  OCMVerifyAll(self.feedbackDelegateMock);
}

- (void)fetchLiveBidForAdUnit:(CR_CacheAdUnit *)adUnit
           andExpectBidCached:(CR_CdbBid *)bidCached
                  bidConsumed:(CR_CdbBid *)bidConsumed
                 bidResponded:(CR_CdbBid *)bidResponded {
  [self fetchLiveBidForAdUnit:adUnit
             andExpectCdbCall:YES
                    bidCached:bidCached
                  bidConsumed:bidConsumed
                 bidResponded:bidResponded];
}

- (void)fetchLiveBidAndExpectBidCached:(CR_CdbBid *)bidCached
                           bidConsumed:(CR_CdbBid *)bidConsumed
                          bidResponded:(CR_CdbBid *)bidResponded {
  [self fetchLiveBidForAdUnit:self.adUnit1
           andExpectBidCached:bidCached
                  bidConsumed:bidConsumed
                 bidResponded:bidResponded];
}

- (void)fetchLiveBidAndExpectBidCached:(CR_CdbBid *)bidCached
               bidConsumedAndResponded:(CR_CdbBid *)bidResponded {
  [self fetchLiveBidAndExpectBidCached:bidCached
                           bidConsumed:bidResponded
                          bidResponded:bidResponded];
}

#pragma mark Basic

- (void)testLiveBid_GivenResponseBeforeTimeBudget_ThenBidFromResponseGiven {
  CR_CdbBid *liveBid = [self givenApiHandlerRespondValidImmediateBid];
  [self givenApiHandlerRespondBid:liveBid];
  self.synchronousThreadManager.isTimeout = NO;

  [self fetchLiveBidAndExpectBidCached:nil bidConsumed:liveBid bidResponded:liveBid];

  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], liveBid);
}

- (void)testLiveBid_GivenResponseAfterTimeBudget_ThenBidFromCacheGiven {
  CR_CdbBid *liveBid = [self givenApiHandlerRespondValidImmediateBid];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidAndExpectBidCached:liveBid bidConsumedAndResponded:self.bid1];
}

- (void)testLiveBid_GivenResponseError_ThenBidFromCacheGiven {
  [self givenApiHandlerRespondError];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumedAndResponded:self.bid1];
}

- (void)testLiveBid_GivenResponseAfterTimeBudgetAndNoBidInCache_ThenNoBidGiven {
  CR_CdbBid *liveBid = [self givenApiHandlerRespondValidBid];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidForAdUnit:self.adUnitForEmptyBid
           andExpectBidCached:liveBid
                  bidConsumed:nil
                 bidResponded:nil];
}

- (void)testLiveBid_GivenResponseErrorAfterTimeBudgetAndNoBidInCache_ThenNoBidGiven {
  [self givenApiHandlerRespondError];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidForAdUnit:self.adUnitForEmptyBid
           andExpectBidCached:nil
                  bidConsumed:nil
                 bidResponded:nil];
}

- (void)testLiveBid_GivenResponseErrorAndNoBidInCache_ThenNoBidGiven {
  [self givenApiHandlerRespondError];

  [self fetchLiveBidForAdUnit:self.adUnitForEmptyBid
           andExpectBidCached:nil
                  bidConsumed:nil
                 bidResponded:nil];
}

- (void)testLiveBid_GivenResponseAfterTimeBudgetAndExpiredBidInCache_ThenNoBidGiven {
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expired().build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  CR_CdbBid *liveBid = [self givenApiHandlerRespondValidBid];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidAndExpectBidCached:liveBid bidConsumed:self.bid1 bidResponded:nil];
}

- (void)testLiveBid_GivenResponseErrorAndExpiredBidInCache_ThenNoBidGiven {
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expired().build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  [self givenApiHandlerRespondError];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumed:self.bid1 bidResponded:nil];
}

- (void)testLiveBid_GivenResponseErrorAfterTimeBudgetAndExpiredBidInCache_ThenNoBidGiven {
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expired().build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  [self givenApiHandlerRespondError];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumed:self.bid1 bidResponded:nil];
}

#pragma mark Silent user

- (void)testLiveBid_GivenSilentMode_ThenCdbNotCalled_AndNoResponseGiven {
  [self givenUserSilenced];

  [self fetchLiveBidForAdUnit:self.adUnitForEmptyBid
             andExpectCdbCall:NO
                    bidCached:nil
                  bidConsumed:nil
                 bidResponded:nil];
}

- (void)testLiveBid_GivenSilentModeAndValidBidInCache_ThenCdbNotCalled_AndResponseGiven {
  [self givenUserSilenced];

  [self fetchLiveBidForAdUnit:self.adUnit1
             andExpectCdbCall:NO
                    bidCached:nil
                  bidConsumed:self.bid1
                 bidResponded:self.bid1];
}

- (void)testLiveBid_GivenSilentModeAndExpiredBidInCache_ThenCdbNotCalled_AndNoResponseGiven {
  [self givenUserSilenced];
  CR_CdbBid *expiredBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expired().build;
  self.bid1 = expiredBid;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  [self fetchLiveBidForAdUnit:self.adUnit1
             andExpectCdbCall:NO
                    bidCached:nil
                  bidConsumed:expiredBid
                 bidResponded:nil];
}

- (void)testLiveBid_GivenSilentModeAndNoBidInCache_ThenCdbNotCalled_AndNoResponseGiven {
  [self givenUserSilenced];
  CR_CdbBid *noBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).noBid().build;
  self.bid1 = noBid;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  [self fetchLiveBidForAdUnit:self.adUnit1
             andExpectCdbCall:NO
                    bidCached:nil
                  bidConsumed:noBid
                 bidResponded:nil];
}

- (void)testLiveBid_GivenSilentModeAndEmptyCache_ThenCdbNotCalled_AndNoResponseGiven {
  [self givenUserSilenced];

  [self fetchLiveBidForAdUnit:self.adUnitForEmptyBid
             andExpectCdbCall:NO
                    bidCached:nil
                  bidConsumed:nil
                 bidResponded:nil];
}

- (void)testLiveBid_GivenSilentModeAndSilentBidInCache_ThenCdbNotCalled_AndNoResponseGiven {
  [self givenUserSilenced];
  CR_CdbBid *silentBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().build;
  self.bid1 = silentBid;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  [self fetchLiveBidForAdUnit:self.adUnitForEmptyBid
             andExpectCdbCall:NO
                    bidCached:nil
                  bidConsumed:nil
                 bidResponded:nil];

  XCTAssertEqual(self.cacheManager.bidCache[self.adUnit1], silentBid);
}

- (void)testLiveBid_GivenExpiredSilentMode_ThenCdbCalled_AndResponseGiven {
  // Expired user silent, 1s before now
  self.bidManager.cdbTimeToNextCall =
      [[NSDate dateWithTimeIntervalSinceNow:-1] timeIntervalSinceReferenceDate];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumed:nil bidResponded:self.bid1];
}

- (void)testLiveBid_GivenResponseErrorAndSilentModeAndValidBidInCache_ThenResponseGiven {
  [self givenApiHandlerRespondError:NSError.new
              doingBeforeResponding:^{
                [self givenUserSilenced];
              }];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumedAndResponded:self.bid1];
}

- (void)givenApiHandlerRespondWithUserSilence {
  CR_CdbResponse *cdbResponseMock = OCMClassMock(CR_CdbResponse.class);
  OCMStub(cdbResponseMock.timeToNextCall).andReturn(123);
  [self givenApiHandlerRespond:cdbResponseMock
         doingBeforeResponding:^{
         }];
}

- (void)testLiveBid_GivenSilentUserResponse_ThenUserSilenceUpdated {
  [self givenApiHandlerRespondWithUserSilence];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertTrue(self.bidManager.isInSilenceMode);
}

- (void)testLiveBid_GivenSilentUserResponseAfterTimeBudget_ThenUserSilenceUpdated {
  [self givenApiHandlerRespondWithUserSilence];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertTrue(self.bidManager.isInSilenceMode);
}

- (void)testLiveBid_GivenNotSilentUserResponse_ThenUserSilenceNotUpdated {
  [self givenApiHandlerRespondBid:[self validCdbBidForAdUnit:self.adUnit1]
            doingBeforeResponding:^{
              [self givenUserSilenced];
            }];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertTrue(self.bidManager.isInSilenceMode);
}

- (void)testLiveBid_GivenNotSilentUserResponseAfterTimeBudget_ThenUserSilenceNotUpdated {
  [self givenApiHandlerRespondBid:[self validCdbBidForAdUnit:self.adUnit1]
            doingBeforeResponding:^{
              [self givenUserSilenced];
            }];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertTrue(self.bidManager.isInSilenceMode);
}

#pragma mark Consent Given

- (void)givenApiHandlerRespondWithConsentGiven:(NSNumber *)consentGiven {
  CR_CdbResponse *cdbResponseMock = OCMClassMock(CR_CdbResponse.class);
  OCMStub(cdbResponseMock.consentGiven).andReturn(consentGiven);
  [self givenApiHandlerRespond:cdbResponseMock
         doingBeforeResponding:^{
         }];
}

- (void)testLiveBid_GivenConsentGivenResponse_ThenConsentGivenUpdated {
  self.consent.consentGiven = NO;
  [self givenApiHandlerRespondWithConsentGiven:@YES];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertTrue(self.consent.isConsentGiven);
}

- (void)testLiveBid_GivenNoConsentGivenResponse_ThenConsentGivenUpdated {
  self.consent.consentGiven = YES;
  [self givenApiHandlerRespondWithConsentGiven:@NO];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertFalse(self.consent.isConsentGiven);
}

- (void)testLiveBid_GivenConsentAndNotInResponse_ThenConsentGivenNotUpdated {
  self.consent.consentGiven = YES;
  [self givenApiHandlerRespondWithConsentGiven:nil];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertTrue(self.consent.isConsentGiven);
}

- (void)testLiveBid_GivenNoConsentAndNotInResponse_ThenConsentGivenNotUpdated {
  self.consent.consentGiven = NO;
  [self givenApiHandlerRespondWithConsentGiven:nil];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertFalse(self.consent.isConsentGiven);
}

- (void)testLiveBid_GivenConsentGivenResponseAfterTimeBudget_ThenConsentGivenUpdated {
  self.consent.consentGiven = NO;
  [self givenApiHandlerRespondWithConsentGiven:@YES];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidForAdUnit:self.adUnit1];

  XCTAssertTrue(self.consent.isConsentGiven);
}

#pragma mark Silent slot

- (void)testLiveBid_GivenSilentBidInCache_ThenCdbNotCalledAndNoResponseGiven {
  CR_CdbBid *silentBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().build;
  self.bid1 = silentBid;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  [self givenApiHandlerRespondValidBid];

  [self fetchLiveBidForAdUnit:self.adUnit1
             andExpectCdbCall:NO
                    bidCached:nil
                  bidConsumed:nil
                 bidResponded:nil];

  // Silent bid not consumed from cache
  XCTAssertEqual(self.cacheManager.bidCache[self.adUnit1], silentBid);
}

- (void)testLiveBid_GivenExpiredSilentBidInCache_ThenBidFromResponseGiven {
  CR_CdbBid *expiredSilentBid =
      CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().expired().build;
  self.bid1 = expiredSilentBid;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  CR_CdbBid *liveBid = [self givenApiHandlerRespondValidBid];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumed:expiredSilentBid bidResponded:liveBid];

  // Silent bid has been removed from cache
  XCTAssertNil(self.cacheManager.bidCache[self.adUnit1]);
}

- (void)testLiveBid_GivenSilentBid_ThenNoResponseGivenAndSlotSilenced {
  CR_CdbBid *silentBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().build;
  [self givenApiHandlerRespondBid:silentBid];

  [self fetchLiveBidAndExpectBidCached:silentBid bidConsumed:nil bidResponded:nil];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"SilentMode"] &&
                                       [logMessage.message
                                           containsString:@"Silent mode enabled for slot"] &&
                                       [logMessage.message containsString:self.adUnit1.adUnitId] &&
                                       [logMessage.message containsString:@"300"];
                              }]]);
}

- (void)testLiveBid_GivenSilentBidPutInCache_ThenBidFromResponseGiven {
  CR_CdbBid *silentBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().build;
  void (^silenceSlot)(void) = ^{
    self.bid1 = silentBid;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  };
  CR_CdbBid *liveBid = [self givenApiHandlerRespondBid:[self validCdbBidForAdUnit:self.adUnit1]
                                 doingBeforeResponding:silenceSlot];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumedAndResponded:liveBid];

  XCTAssertEqual(self.cacheManager.bidCache[self.adUnit1], silentBid);
}

- (void)testLiveBid_GivenResponseAfterTimeBudgetAndSilentBidPutInCache_ThenNoResponseGiven {
  CR_CdbBid *silentBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().build;
  void (^silenceSlot)(void) = ^{
    self.bid1 = silentBid;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  };
  [self givenApiHandlerRespondBid:[self validCdbBidForAdUnit:self.adUnit1]
            doingBeforeResponding:silenceSlot];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumed:nil bidResponded:nil];

  XCTAssertEqual(self.cacheManager.bidCache[self.adUnit1], silentBid);
}

- (void)testLiveBid_GivenResponseAfterTimeBudgetAndExpiredSilentBidPutInCache_ThenNoResponseGiven {
  CR_CdbBid *expiredSilentBid =
      CR_CdbBidBuilder.new.adUnit(self.adUnit1).silenced().expired().build;
  void (^silenceSlot)(void) = ^{
    self.bid1 = expiredSilentBid;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
  };
  CR_CdbBid *liveBid = [self givenApiHandlerRespondBid:[self validCdbBidForAdUnit:self.adUnit1]
                                 doingBeforeResponding:silenceSlot];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidAndExpectBidCached:liveBid bidConsumed:expiredSilentBid bidResponded:nil];
}

#pragma mark Invalid response

- (void)testLiveBid_GivenInvalidBid_ThenNoResponseGiven {
  CR_CdbBid *invalidBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).displayUrl(nil).build;
  [self givenApiHandlerRespondBid:invalidBid];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumedAndResponded:self.bid1];

  // Invalid bid from cdb call has not been cached
  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], invalidBid);
}

- (void)testLiveBid_GivenNoBid_ThenNoResponseGiven {
  CR_CdbBid *noBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).noBid().build;
  [self givenApiHandlerRespondBid:noBid];

  [self fetchLiveBidAndExpectBidCached:nil bidConsumedAndResponded:noBid];

  // No bid from cdb call has not been cached
  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], noBid);
}

- (void)testLiveBid_GivenNoBidAfterTimeBudget_ThenNoResponseGiven {
  CR_CdbBid *noBid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).noBid().build;
  [self givenApiHandlerRespondBid:noBid];
  [self givenTimeBudgetExceeded];

  [self fetchLiveBidAndExpectBidCached:noBid bidConsumedAndResponded:self.bid1];

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
  XCTestExpectation *fastBidExpectation = [self bidExpectationWithDelay:0.1];

  [self cr_waitShortlyForExpectationsWithOrder:@[ fastBidExpectation, slowBidExpectation ]];
}

#pragma mark - Header Bidding

- (void)testAddCriteoBidToNonBiddableObjectsDoesNotCrash {
  CRBid *bid = [self validBid];
  [self.bidManager enrichAdObject:[NSDictionary new] withBid:bid];
  [self.bidManager enrichAdObject:[NSSet new] withBid:bid];
  [self.bidManager enrichAdObject:@"string" withBid:bid];
  [self.bidManager enrichAdObject:(NSMutableDictionary *)nil withBid:bid];
}

- (void)testAddCriteoBidToRequestCallHeaderBidding {
  CRBid *validBid = self.validBid;
  CR_CdbBid *cdbBid = validBid.cdbBid;
  [self.bidManager enrichAdObject:self.request withBid:validBid];

  OCMVerify([self.headerBiddingMock enrichRequest:self.request withBid:cdbBid adUnit:self.adUnit1]);
}

#pragma mark - Private

- (void)givenTimeBudgetExceeded {
  self.synchronousThreadManager.isTimeout = YES;
}

- (void)givenUserSilenced {
  self.bidManager.cdbTimeToNextCall = INFINITY;
}

- (CR_CdbBid *)givenApiHandlerRespondValidBidWithDelay:(NSTimeInterval)delay {
  CR_CdbBid *validBid = [self validCdbBidForAdUnit:self.adUnit1];
  return [self givenApiHandlerRespondBid:validBid withDelay:delay];
}

- (CR_CdbBid *)givenApiHandlerRespondValidBid {
  return [self givenApiHandlerRespondBid:[self validCdbBidForAdUnit:self.adUnit1] withDelay:0];
}
- (CR_CdbBid *)givenApiHandlerRespondValidImmediateBid {
  return [self givenApiHandlerRespondBid:[self validImmediateCdbBidForAdUnit:self.adUnit1]
                               withDelay:0];
}

- (void)givenApiHandlerRespond:(CR_CdbResponse *)cdbResponse
         doingBeforeResponding:(void (^)(void))block {
  OCMStub([self.apiHandlerMock callCdb:[OCMArg any]
                               consent:[OCMArg any]
                                config:[OCMArg any]
                            deviceInfo:[OCMArg any]
                               context:[OCMArg any]
                         beforeCdbCall:[OCMArg any]
                     completionHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        block();
        CR_CdbCompletionHandler handler;
        [invocation getArgument:&handler atIndex:8];
        handler(nil, cdbResponse, nil);
      });
}

- (void)givenApiHandlerRespondError:(NSError *)error doingBeforeResponding:(void (^)(void))block {
  OCMStub([self.apiHandlerMock callCdb:[OCMArg any]
                               consent:[OCMArg any]
                                config:[OCMArg any]
                            deviceInfo:[OCMArg any]
                               context:[OCMArg any]
                         beforeCdbCall:[OCMArg any]
                     completionHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        block();
        CR_CdbCompletionHandler handler;
        [invocation getArgument:&handler atIndex:8];
        handler(nil, nil, error);
      });
}

- (void)givenApiHandlerRespondError {
  [self givenApiHandlerRespondError:NSError.new
              doingBeforeResponding:^{
              }];
}

- (CR_CdbBid *)givenApiHandlerRespondBid:(CR_CdbBid *)bid
                   doingBeforeResponding:(void (^)(void))block {
  CR_CdbResponse *cdbResponseMock = OCMClassMock(CR_CdbResponse.class);
  OCMStub([cdbResponseMock cdbBids]).andReturn(@[ bid ]);
  [self givenApiHandlerRespond:cdbResponseMock doingBeforeResponding:block];
  return bid;
}

- (CR_CdbBid *)givenApiHandlerRespondBid:(CR_CdbBid *)bid withDelay:(NSTimeInterval)delay {
  return [self givenApiHandlerRespondBid:bid
                   doingBeforeResponding:^{
                     [NSThread sleepForTimeInterval:delay];
                   }];
}

- (CR_CdbBid *)givenApiHandlerRespondBid:(CR_CdbBid *)bid {
  return [self givenApiHandlerRespondBid:bid withDelay:0];
}

- (void)fetchLiveBidForAdUnit:(CR_CacheAdUnit *)adUnit {
  [self.bidManager fetchLiveBidForAdUnit:adUnit
                             withContext:self.contextData
                         responseHandler:^(CR_CdbBid *bid){
                         }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ adUnit ]);
}

- (XCTestExpectation *)bidExpectationWithDelay:(NSTimeInterval)delay {
  NSString *description = [NSString stringWithFormat:@"Bid expected after %2fs", delay];
  XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:description];
  CR_CdbBid *expectedBid = [self givenApiHandlerRespondValidBidWithDelay:delay];
  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                             withContext:self.contextData
                         responseHandler:^(CR_CdbBid *bid) {
                           [expectation fulfill];
                           XCTAssertEqualObjects(bid, expectedBid);
                           CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);
                         }];
  return expectation;
}

- (CR_CdbBid *)validCdbBidForAdUnit:(CR_CacheAdUnit *)adUnit {
  return CR_CdbBidBuilder.new.adUnit(adUnit).build;
}

- (CR_CdbBid *)validImmediateCdbBidForAdUnit:(CR_CacheAdUnit *)adUnit {
  return CR_CdbBidBuilder.new.adUnit(adUnit).immediate().build;
}

- (CRBid *)validBid {
  CRAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:self.adUnit1.adUnitId
                                                         size:self.adUnit1.size];
  CR_CdbBid *cdbBid = [self validCdbBidForAdUnit:self.adUnit1];
  return [[CRBid alloc] initWithCdbBid:cdbBid adUnit:adUnit];
}

- (CR_DataProtectionConsent *)consent {
  return self.dependencyProvider.consent;
}

@end
