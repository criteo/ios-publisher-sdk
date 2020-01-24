//
//  CR_BidManagerFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 1/23/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_BidManagerBuilder.h"
#import "CR_Config.h"
#import "CR_HttpContent+AdUnit.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkWaiter.h"
#import "CR_TestAdUnits.h"
#import "NSURL+Testing.h"

@interface CR_BidManagerIntegrationTests : XCTestCase

@property (nonatomic, strong) Criteo *criteo;
@property (nonatomic, strong) CR_NetworkCaptor *networkCaptor;
@property (nonatomic, strong) CR_BidManager *bidManager;
@property (nonatomic, strong) CR_Config *config;

@end

@implementation CR_BidManagerIntegrationTests

- (void)setUp {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    self.bidManager = self.criteo.bidManager;
    self.networkCaptor = (CR_NetworkCaptor *)self.criteo.bidManagerBuilder.networkManager;
    self.config = self.criteo.bidManagerBuilder.config;
}

// Prefetch should populate cache with given ad units
- (void)test_given2AdUnits_whenPrefetchBid_thenGet2Bids {
    CR_CacheAdUnit *cacheAdUnit1 = [CR_AdUnitHelper cacheAdUnitForAdUnit:[CR_TestAdUnits preprodBanner320x50]];
    CR_CacheAdUnit *cacheAdUnit2 = [CR_AdUnitHelper cacheAdUnitForAdUnit:[CR_TestAdUnits preprodInterstitial]];
    CR_CacheAdUnitArray *caches = @[ cacheAdUnit1, cacheAdUnit2 ];

    [self.bidManager prefetchBids:caches];

    [self _waitNetworkCallForBids:caches];
    XCTAssertNotNil([self.bidManager getBid:cacheAdUnit1]);
    XCTAssertNotNil([self.bidManager getBid:cacheAdUnit2]);
}

// Initializing criteo object should call prefetch
- (void)test_givenCriteo_whenRegisterAdUnit_thenGetBid {
    CRBannerAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
    CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];

    [self.criteo testing_registerWithAdUnits:@[adUnit]];

    [self.criteo testing_waitForRegisterHTTPResponses];
    XCTAssertNotNil([self.bidManager getBid:cacheAdUnit]);
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
