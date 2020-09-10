//
//  CR_BidManagerFunctionalTests.m
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
#import <OCMock.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_DependencyProvider.h"
#import "CR_DeviceInfoMock.h"
#import "CR_HttpContent+AdUnit.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkManagerMock.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSURL+Testing.h"
#import "CRConstants.h"

@interface CR_BidManagerIntegrationTests : XCTestCase

@property(nonatomic, strong) Criteo *criteo;
@property(nonatomic, strong) CR_DependencyProvider *dependencyProvider;
@property(nonatomic, strong) CR_NetworkCaptor *networkCaptor;
@property(nonatomic, strong) CR_BidManager *bidManager;
@property(nonatomic, strong) CR_Config *config;

@property(nonatomic, strong) CRBannerAdUnit *adUnit1;
@property(nonatomic, strong) CR_CacheAdUnit *cacheAdUnit1;
@property(nonatomic, strong) CR_CacheAdUnit *cacheAdUnit2;

@end

@implementation CR_BidManagerIntegrationTests

- (void)setUp {
  self.criteo = [Criteo testing_criteoWithNetworkCaptor];

  self.dependencyProvider = self.criteo.dependencyProvider;
  self.bidManager = self.dependencyProvider.bidManager;
  self.networkCaptor = (CR_NetworkCaptor *)self.dependencyProvider.networkManager;
  self.config = self.dependencyProvider.config;

  self.adUnit1 = [CR_TestAdUnits preprodBanner320x50];
  self.cacheAdUnit1 = [CR_AdUnitHelper cacheAdUnitForAdUnit:[CR_TestAdUnits preprodBanner320x50]];
  self.cacheAdUnit2 = [CR_AdUnitHelper cacheAdUnitForAdUnit:[CR_TestAdUnits preprodInterstitial]];
}

- (void)tearDown {
  [self.criteo.dependencyProvider.threadManager waiter_waitIdle];
  [super tearDown];
}

// Prefetch should populate cache with given ad units
- (void)test_given2AdUnits_whenPrefetchBid_thenGet2Bids {
  [self.bidManager prefetchBids:@[ self.cacheAdUnit1, self.cacheAdUnit2 ]];

  [self _waitNetworkCallForBids:@[ self.cacheAdUnit1, self.cacheAdUnit2 ]];
  XCTAssertNotNil([self.bidManager getBid:self.cacheAdUnit1]);
  XCTAssertNotNil([self.bidManager getBid:self.cacheAdUnit2]);
}

// Initializing criteo object should call prefetch
- (void)test_givenCriteo_whenRegisterAdUnit_thenGetBid {
  [self.criteo testing_registerWithAdUnits:@[ self.adUnit1 ]];

  [self.criteo testing_waitForRegisterHTTPResponses];
  XCTAssertNotNil([self.bidManager getBid:self.cacheAdUnit1]);
}

// Getting bid should not populate cache if CDB call is pending
- (void)test_givenPrefetchingBid_whenGetBid_thenDontFetchBidAgain {
  CR_NetworkManagerMock *networkManager = [[CR_NetworkManagerMock alloc] init];
  networkManager.respondingToPost = NO;
  networkManager.postFilterUrl =
      [NSPredicate predicateWithBlock:^BOOL(NSURL *url, NSDictionary<NSString *, id> *bindings) {
        // Only consider bid queries, ignore others such as csm,
        // as we test later on the number of network calls
        return [url testing_isBidUrlWithConfig:self.config];
      }];
  self.dependencyProvider =
      [[CR_DependencyProvider alloc] init];  // create new *clean* dependency provider
  self.dependencyProvider.networkManager = networkManager;
  self.dependencyProvider.config = self.config;
  self.dependencyProvider.deviceInfo = [[CR_DeviceInfoMock alloc] init];
  self.bidManager = [self.dependencyProvider bidManager];
  [self.bidManager prefetchBid:self.cacheAdUnit1];
  [self.dependencyProvider.threadManager waiter_waitIdle];

  [self.bidManager getBid:self.cacheAdUnit1];
  [self.dependencyProvider.threadManager waiter_waitIdle];

  XCTAssertEqual(networkManager.numberOfPostCall, 1);
}

- (void)test_givenPrefetchingBid_whenGetImmediateBid_ShouldPopulateCacheWithTtlSetToDefaultOne {
  [self givenMockedCdbResponseBid:self.immediateBid];
  [self whenPrefetchingBid];
  CR_CdbBid *cachedBid = [self.bidManager getBid:self.cacheAdUnit1];
  XCTAssertEqual(cachedBid.ttl, CRITEO_DEFAULT_BID_TTL_IN_SECONDS);

  [self checkAnotherPrefetchPopulateCache];
}

- (void)test_givenPrefetchingBid_whenMissingBid_ShouldNotPopulateCache {
  [self givenMockedCdbResponseBids:@[]];
  [self whenPrefetchingBid];
  [self shouldNotPopulateCache];

  [self checkAnotherPrefetchPopulateCache];
}

- (void)test_givenPrefetchingBid_whenNoContent_ShouldNotPopulateCache {
  [self givenMockedCdbEmptyResponse];
  [self whenPrefetchingBid];
  [self shouldNotPopulateCache];

  [self checkAnotherPrefetchPopulateCache];
}

#pragma mark - Private
#pragma mark Response mocks

- (void)givenMockedCdbResponseBids:(NSArray<CR_CdbBid *> *)bids {
  CR_ApiHandler *apiHandler = OCMPartialMock(_dependencyProvider.apiHandler);
  CR_CdbResponse *response = OCMClassMock([CR_CdbResponse class]);
  OCMStub(response.cdbBids).andReturn(bids);
  OCMStub([apiHandler cdbResponseWithData:[OCMArg any]]).andReturn(response);
  _dependencyProvider.apiHandler = apiHandler;
}

- (void)givenMockedCdbResponseBid:(CR_CdbBid *)bid {
  return [self givenMockedCdbResponseBids:@[ bid ]];
}

- (void)givenMockedCdbEmptyResponse {
  CR_ApiHandler *apiHandler = _dependencyProvider.apiHandler;
  CR_ApiHandler *apiHandlerMock = OCMPartialMock(_dependencyProvider.apiHandler);
  OCMStub([apiHandlerMock cdbResponseWithData:[OCMArg any]])
      .andReturn([apiHandler cdbResponseWithData:nil]);
  _dependencyProvider.apiHandler = apiHandlerMock;
}

- (void)givenUnmockedCdbResponse {
  [(id)_dependencyProvider.apiHandler stopMocking];
}

#pragma mark Prefetch actions

- (void)whenPrefetchingBid {
  [self.criteo testing_registerWithAdUnits:@[ self.adUnit1 ]];
  [self.criteo testing_waitForRegisterHTTPResponses];
}

- (void)whenPrefetchingAnotherBid {
  [self.bidManager prefetchBid:self.cacheAdUnit1];
  [self.dependencyProvider.threadManager waiter_waitIdle];
}

#pragma mark Cache validation

- (void)shouldNotPopulateCache {
  CR_CdbBid *cachedBid = [self.bidManager getBid:self.cacheAdUnit1];
  XCTAssertEqualObjects(cachedBid, CR_CdbBid.emptyBid);
}

- (void)shouldPopulateCache {
  CR_CdbBid *cachedBid = [self.bidManager getBid:self.cacheAdUnit1];
  XCTAssertNotEqualObjects(cachedBid, CR_CdbBid.emptyBid);
}
- (void)_waitNetworkCallForBids:(CR_CacheAdUnitArray *)caches {
  NSArray *tests = @[ ^BOOL(CR_HttpContent *_Nonnull httpContent) {
    return [httpContent.url testing_isBidUrlWithConfig:self.config] &&
           [httpContent isHTTPRequestForCacheAdUnits:caches];
  } ];
  CR_NetworkWaiter *waiter = [[CR_NetworkWaiter alloc] initWithNetworkCaptor:self.networkCaptor
                                                                     testers:tests];
  waiter.finishedRequestsIncluded = YES;
  BOOL result = [waiter wait];
  XCTAssert(result, @"Fail to send bid request.");
}

#pragma mark Checks

- (void)checkAnotherPrefetchPopulateCache {
  [self givenUnmockedCdbResponse];
  [self whenPrefetchingAnotherBid];
  [self shouldPopulateCache];
}

#pragma mark Model helpers

- (CR_CdbBid *)immediateBid {
  CR_CdbBid *bid = [[CR_CdbBid alloc] initWithZoneId:@123
                                         placementId:self.adUnit1.adUnitId
                                                 cpm:@"1.2"
                                            currency:@"EUR"
                                               width:@320
                                              height:@50
                                                 ttl:0
                                            creative:nil
                                          displayUrl:@"https://display.url"
                                          insertTime:nil
                                        nativeAssets:nil
                                        impressionId:nil];
  XCTAssertTrue(bid.isImmediate);
  return bid;
}
@end
