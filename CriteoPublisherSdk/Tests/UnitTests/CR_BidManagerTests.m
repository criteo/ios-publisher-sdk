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

#import <MoPub.h>
#import <OCMock.h>
#import "DFPRequestClasses.h"
#import "NSString+Testing.h"
#import "CR_BidManager.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DeviceInfoMock.h"
#import "CR_HeaderBidding.h"
#import "CR_SynchronousThreadManager.h"
#import "CriteoPublisherSdkTests-Swift.h"

static NSString *const CR_BidManagerTestsCpm = @"crt_cpm";
static NSString *const CR_BidManagerTestsDisplayUrl = @"crt_displayUrl";
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

@interface CR_BidManager (Testing)
@property(nonatomic) NSTimeInterval cdbTimeToNextCall;
@end

@interface CR_BidManagerTests : XCTestCase

@property(nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property(nonatomic, strong) CR_CdbBid *bid1;

@property(nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property(nonatomic, strong) CR_CdbBid *bid2;

@property(nonatomic, strong) CR_CacheAdUnit *adUnitForEmptyBid;
@property(nonatomic, strong) CR_CacheAdUnit *adUnitUncached;

@property(nonatomic, strong) DFPRequest *dfpRequest;

@property(nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property(nonatomic, strong) CR_TokenCache *tokenCache;
@property(nonatomic, strong) CR_CacheManager *cacheManager;
@property(nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property(nonatomic, strong) CR_ConfigManager *configManagerMock;
@property(nonatomic, strong) CR_HeaderBidding *headerBiddingMock;
@property(nonatomic, strong) CR_SynchronousThreadManager *threadManager;
@property(nonatomic, strong) CR_DependencyProvider *dependencyProvider;
@property(nonatomic, strong) CR_BidManager *bidManager;

@end

@implementation CR_BidManagerTests

- (void)setUp {
  self.deviceInfoMock = [[CR_DeviceInfoMock alloc] init];
  self.cacheManager = OCMPartialMock([[CR_CacheManager alloc] init]);
  self.configManagerMock = OCMClassMock([CR_ConfigManager class]);
  self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);
  self.headerBiddingMock = OCMPartialMock(CR_HeaderBidding.new);
  self.threadManager = [[CR_SynchronousThreadManager alloc] init];

  CR_DependencyProvider *dependencyProvider = [CR_DependencyProvider testing_dependencyProvider];
  dependencyProvider.threadManager = self.threadManager;
  dependencyProvider.configManager = self.configManagerMock;
  dependencyProvider.cacheManager = self.cacheManager;
  dependencyProvider.apiHandler = self.apiHandlerMock;
  dependencyProvider.deviceInfo = self.deviceInfoMock;
  dependencyProvider.headerBidding = self.headerBiddingMock;

  self.dependencyProvider = dependencyProvider;
  self.bidManager = [dependencyProvider bidManager];
  self.tokenCache = dependencyProvider.tokenCache;

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

- (void)tearDown {
  [self.dependencyProvider.feedbackStorage popMessagesToSend];
}

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

- (void)testRegistrationSetEmptyBid {
  [self.bidManager registerWithSlots:@[ self.adUnitUncached ]];

  CR_CdbBid *bid = [self.bidManager getBidThenFetch:self.adUnitUncached];

  XCTAssert(bid.isEmpty);
}

- (void)testGetBidWhenBeforeTtnc {  // TTNC -> Time to next call
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

- (void)testBidResponseForEmptyBid {
  self.adUnitUncached = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                            size:CGSizeMake(320, 50)
                                                      adUnitType:CRAdUnitTypeBanner];

  CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:self.adUnitUncached
                                                               adUnitType:CRAdUnitTypeBanner];

  XCTAssertEqualWithAccuracy(bidResponse.price, 0.0f, 0.1);
  XCTAssertNil(bidResponse.bidToken);
  XCTAssertFalse(bidResponse.bidSuccess);
}

- (void)testBidResponseForValidBid {
  self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                     size:CGSizeMake(320, 50)
                                               adUnitType:CRAdUnitTypeBanner];
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"4.2").build;
  self.cacheManager.bidCache[self.adUnit1] = self.bid1;

  CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:self.adUnit1
                                                               adUnitType:CRAdUnitTypeBanner];

  XCTAssertEqualWithAccuracy(bidResponse.price, 4.2, 0.1);
  XCTAssert(bidResponse.bidSuccess);
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

- (void)testSlotRegistrationRefreshConfiguration {
  [self.bidManager registerWithSlots:@[ self.adUnitUncached ]];

  OCMVerify([self.configManagerMock refreshConfig:[OCMArg any]]);
}

#pragma mark - Live Bidding

- (void)testLiveBid_GivenResponseBeforeTimeBudget_ThenBidFromResponseGiven {
  CR_CdbBid *liveBid = [self givenApiHandlerRespondBid];
  self.threadManager.isTimeout = NO;

  // Bid Manager returns bid from cdb call
  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                      bidResponseHandler:^(CR_CdbBid *bid) {
                        XCTAssertEqualObjects(bid, liveBid);
                      }];
  CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[ self.adUnit1 ]);

  // Bid from cdb call has not been cached
  OCMReject([self.cacheManager setBid:[OCMArg any]]);
  XCTAssertNotEqual(self.cacheManager.bidCache[self.adUnit1], liveBid);
}

- (void)testLiveBid_GivenResponseAfterTimeBudget_ThenBidFromCacheGiven {
  CR_CdbBid *liveBid = [self givenApiHandlerRespondBid];
  self.threadManager.isTimeout = YES;

  // Bid Manager returns bid from cache
  [self.bidManager fetchLiveBidForAdUnit:self.adUnit1
                      bidResponseHandler:^(CR_CdbBid *bid) {
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
                      bidResponseHandler:^(CR_CdbBid *bid) {
                        XCTAssertNil(bid);
                      }];
}

#pragma mark - Header Bidding

- (void)testAddCriteoBidToNonBiddableObjectsDoesNotCrash {
  [self.bidManager addCriteoBidToRequest:[NSDictionary new] forAdUnit:self.adUnit1];
  [self.bidManager addCriteoBidToRequest:[NSSet new] forAdUnit:self.adUnit1];
  [self.bidManager addCriteoBidToRequest:@"1234abcd" forAdUnit:self.adUnit1];
  [self.bidManager addCriteoBidToRequest:(NSMutableDictionary *)nil forAdUnit:self.adUnit1];
}

- (void)testAddCriteoBidToRequestCallHeaderBidding {
  [self.bidManager addCriteoBidToRequest:self.dfpRequest forAdUnit:self.adUnit1];

  OCMVerify([self.headerBiddingMock enrichRequest:self.dfpRequest
                                          withBid:self.bid1
                                           adUnit:self.adUnit1]);
}

- (void)testAddCriteoBidToRequestWhenKillSwitchIsEngagedShouldNotEnrichRequest {
  self.dependencyProvider.config.killSwitch = YES;

  [self.bidManager addCriteoBidToRequest:self.dfpRequest forAdUnit:self.adUnit1];

  OCMReject([self.headerBiddingMock enrichRequest:[OCMArg any]
                                          withBid:[OCMArg any]
                                           adUnit:[OCMArg any]]);
  XCTAssertTrue(self.dfpRequest.customTargeting.count == 2);
  XCTAssertNil([self.dfpRequest.customTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
  XCTAssertNil([self.dfpRequest.customTargeting objectForKey:CR_BidManagerTestsCpm]);
}

#pragma mark - Private

- (CR_CdbBid *)givenApiHandlerRespondBid {
  CR_CdbBid *bid = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;
  CR_CdbResponse *cdbResponseMock = OCMClassMock(CR_CdbResponse.class);
  OCMStub([cdbResponseMock cdbBids]).andReturn(@[ bid ]);
  OCMStub([self.apiHandlerMock callCdb:[OCMArg any]
                               consent:[OCMArg any]
                                config:[OCMArg any]
                            deviceInfo:[OCMArg any]
                         beforeCdbCall:[OCMArg any]
                     completionHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        CR_CdbCompletionHandler handler;
        [invocation getArgument:&handler atIndex:7];
        handler(nil, cdbResponseMock, nil);
      });
  return bid;
}

@end
