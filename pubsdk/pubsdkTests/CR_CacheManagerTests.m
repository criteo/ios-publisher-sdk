//
//  CR_CacheManagerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CRAdUnit.h"
#import "CR_CacheManager.h"

@interface CR_CacheManagerTests : XCTestCase

@end

@implementation CR_CacheManagerTests

- (void) testGetBidWithinTtl {
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    CGSize adSize = CGSizeMake(200, 100);
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:adSize];
    CdbBid *testBid = [[CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];

    [cache setBid:testBid forAdUnit:adUnit];
    CdbBid *retreivedBid = [cache getBid:adUnit];
    XCTAssertNotNil(retreivedBid);
    XCTAssertEqualObjects(adUnit.adUnitId, retreivedBid.placementId);
}

- (void) testGetBidExpiredTtl {
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    CGSize adSize = CGSizeMake(200, 100);
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:adSize];
    CdbBid *testBid = [[CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-400]];
    [cache setBid:testBid forAdUnit:adUnit];
    CdbBid *retreivedBid = [cache getBid:adUnit];
    XCTAssertEqualObjects([CdbBid emptyBid], retreivedBid);
}
@end
