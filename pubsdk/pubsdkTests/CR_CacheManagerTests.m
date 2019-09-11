//
//  CR_CacheManagerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_CacheAdUnit.h"
#import "CR_CacheManager.h"

@interface CR_CacheManagerTests : XCTestCase

@end

@implementation CR_CacheManagerTests

- (void) testGetBidWithinTtl {
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    CGSize adSize = CGSizeMake(200, 100);
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:adSize];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];

    [cache setBid:testBid];
    CR_CdbBid *retreivedBid = [cache getBidForAdUnit:adUnit];
    XCTAssertNotNil(retreivedBid);
    XCTAssertEqualObjects(adUnit.adUnitId, retreivedBid.placementId);
}

- (void)testSetBidForNonNative {
    CR_CacheManager *cacheManager = [CR_CacheManager new];
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:CGSizeMake(320, 50)];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];
    [cacheManager setBid:testBid];
    XCTAssertTrue([[cacheManager getBidForAdUnit:adUnit] isEqual:testBid]);
}

// this test needs change when EE-492 is complete
- (void)testSetBidForNative {
    CR_CacheManager *cacheManager = [CR_CacheManager new];
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:CGSizeMake(320, 50) isNative:YES];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];
    testBid.nativeAssets = @"";
    [cacheManager setBid:testBid];
    XCTAssertTrue([[cacheManager getBidForAdUnit:adUnit] isEqual:testBid]);
}

@end
