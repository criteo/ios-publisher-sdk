//
//  CR_BidManagerFunctionalTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_DependencyProvider.h"
#import "CR_CdbBidBuilder.H"
#import "CR_Config.h"
#import "CR_DeviceInfoMock.h"
#import "CR_HttpContent+AdUnit.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkManagerMock.h"
#import "CR_ThreadManagerWaiter.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSURL+Testing.h"

@interface CR_BidManagerIntegrationTests : XCTestCase

@property (nonatomic, strong) Criteo *criteo;
@property (nonatomic, strong) CR_DependencyProvider *dependencyProvider;
@property (nonatomic, strong) CR_NetworkCaptor *networkCaptor;
@property (nonatomic, strong) CR_BidManager *bidManager;
@property (nonatomic, strong) CR_Config *config;

@property (nonatomic, strong) CRBannerAdUnit *adUnit1;
@property (nonatomic, strong) CR_CacheAdUnit *cacheAdUnit1;
@property (nonatomic, strong) CR_CacheAdUnit *cacheAdUnit2;

@end

@implementation CR_BidManagerIntegrationTests

- (void)setUp {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];

    self.dependencyProvider = self.criteo.dependencyProvider;
    self.bidManager = self.criteo.bidManager;
    self.networkCaptor = (CR_NetworkCaptor *)self.dependencyProvider.networkManager;
    self.config = self.criteo.dependencyProvider.config;

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
    [self.criteo testing_registerWithAdUnits:@[self.adUnit1]];

    [self.criteo testing_waitForRegisterHTTPResponses];
    XCTAssertNotNil([self.bidManager getBid:self.cacheAdUnit1]);
}

// Getting bid should not populate cache if CDB call is pending
- (void)test_givenPrefetchingBid_whenGetBid_thenDontFetchBidAgain {
    CR_NetworkManagerMock *networkManager = [[CR_NetworkManagerMock alloc] init];
    networkManager.respondingToPost = NO;
    networkManager.postFilterUrl = [NSPredicate predicateWithBlock:^BOOL(NSURL *url, NSDictionary<NSString *, id> *bindings) {
        // Only consider bid queries, ignore others such as csm,
        // as we test later on the number of network calls
        return [url testing_isBidUrlWithConfig:self.config];
    }];
    self.dependencyProvider = [[CR_DependencyProvider alloc] init]; // create new *clean* dependency provider
    self.dependencyProvider.networkManager = networkManager;
    self.dependencyProvider.config = self.config;
    self.dependencyProvider.deviceInfo = [[CR_DeviceInfoMock alloc] init];
    self.bidManager = [self.dependencyProvider buildBidManager];
    [self.bidManager prefetchBid:self.cacheAdUnit1];
    [self.dependencyProvider.threadManager waiter_waitIdle];

    [self.bidManager getBid:self.cacheAdUnit1];
    [self.dependencyProvider.threadManager waiter_waitIdle];

    XCTAssertEqual(networkManager.numberOfPostCall, 1);
}

- (void)_waitNetworkCallForBids:(CR_CacheAdUnitArray *)caches {
    NSArray *tests = @[^BOOL(CR_HttpContent *_Nonnull httpContent) {
        return  [httpContent.url testing_isBidUrlWithConfig:self.config] &&
                [httpContent isHTTPRequestForCacheAdUnits:caches];
    }];
    CR_NetworkWaiter *waiter = [[CR_NetworkWaiter alloc] initWithNetworkCaptor:self.networkCaptor
                                                                       testers:tests];
    waiter.finishedRequestsIncluded = YES;
    BOOL result = [waiter wait];
    XCTAssert(result, @"Fail to send bid request.");
}

@end
