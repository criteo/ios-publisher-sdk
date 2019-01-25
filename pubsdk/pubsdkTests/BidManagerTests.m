//
//  BidManagerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "../pubsdk/BidManager.h"
#import "../pubsdk/CdbBid.h"
#import "DummyDfpRequest.h"
#import <OCMock.h>

@interface BidManagerTests : XCTestCase

@end

@implementation BidManagerTests

- (void) testGetBid {
    BidManager *bidManager = [[BidManager alloc] init];
    // test cache
    CacheManager *cache = [[CacheManager alloc] init];

    // initialized slots with fetched bids
    CdbBid *testBid = [[CdbBid alloc] init];
    AdUnit *testAdUnit = [[AdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    [cache.bidCache setObject:testBid forKey:testAdUnit];

    CdbBid *testBid_2 = [[CdbBid alloc] init];
    AdUnit *testAdUnit_2 = [[AdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    [cache.bidCache setObject:testBid_2 forKey:testAdUnit_2];

    bidManager.cacheManager = cache;

    GdprUserConsent *mockUserConsent = OCMStrictClassMock([GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");
    bidManager.gdpr = mockUserConsent;

    // if the caller asks for a bid for an un initialized slot
    AdUnit *unInitializedSlot = [[AdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    NSArray *slots = @[testAdUnit, testAdUnit_2, unInitializedSlot];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([testBid isEqual:bids[testAdUnit]]);
    XCTAssertTrue([testBid_2 isEqual:bids[testAdUnit_2]]);
    XCTAssertTrue([bids[unInitializedSlot] isEmpty]);
    //NSLog(@"test bid creative is : %@ and cached creative is: %@", testBid.creative, bids[testAdUnit]);

}

- (void) testGetBidForSlotThatHasntBeenFetchedFromCdb {
    BidManager *bidManager = [[BidManager alloc] init];
    // test cache
    CacheManager *cache = [[CacheManager alloc] init];

    // initialized slot that has no bid fetched for it
    CdbBid *testEmptyBid = [CdbBid emptyBid];
    AdUnit *testEmptyAdUnit = [[AdUnit alloc] initWithAdUnitId:@"thisShouldReturnEmptyBid" width:300 height:250];
    [cache.bidCache setObject:testEmptyBid forKey:testEmptyAdUnit];

    bidManager.cacheManager = cache;

    GdprUserConsent *mockUserConsent = OCMStrictClassMock([GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");
    bidManager.gdpr = mockUserConsent;

    // an initialized slot that has no bid fetched for it
    NSArray *slots = @[[[AdUnit alloc] initWithAdUnitId:@"thisShouldReturnEmptyBid" width:300 height:250]];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([bids[testEmptyAdUnit] isEmpty]);
}

- (void) testSetSlots {
    BidManager *bidManager = [[BidManager alloc] init];

    AdUnit *slot_1 = [[AdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    AdUnit *slot_2 = [[AdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    AdUnit *slot_3 = [[AdUnit alloc] initWithAdUnitId:@"adunitid_2" width:200 height:100];

    NSArray *slots = @[slot_1, slot_2, slot_3];

    [bidManager setSlots:slots];

    NSDictionary *bids = [bidManager getBids:slots];

    XCTAssertTrue([bids[slot_1] isEmpty]);
    XCTAssertTrue([bids[slot_2] isEmpty]);
    XCTAssertTrue([bids[slot_3] isEmpty]);
}

- (void) testAddCriteoBidToRequest {
    AdUnit *slot_1 = [[AdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CdbBid *testBid_1 = [[CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:@(600) creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js"];

    CacheManager *cache = [[CacheManager alloc] init];
    [cache setBid:testBid_1 forAdUnit:slot_1];

    BidManager *bidManager = [[BidManager alloc] init];
    bidManager.cacheManager = cache;

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DummyDfpRequest *dfpBidRequest = [[DummyDfpRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    Config *config = [[Config alloc] initWithNetworkId:@(1234)];
    bidManager.config = config;

    [bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:slot_1];

    XCTAssertTrue(dfpBidRequest.customTargeting.count > 2);
    XCTAssertTrue([[testBid_1 displayUrl] isEqualToString:[dfpBidRequest.customTargeting objectForKey:@"crt_displayUrl"]]);
    // TODO : [testBid_1 cpm] == 1.12 when it should be == 1.1200000047683716
    XCTAssertTrue([[testBid_1 cpm].stringValue isEqualToString:[dfpBidRequest.customTargeting objectForKey:@"crt_cpm"]]);
}

- (void) testAddCriteoBidToRequestWhenKillSwitchIsEngaged {
    AdUnit *slot_1 = [[AdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CdbBid *testBid_1 = [[CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:@(600) creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js"];

    CacheManager *cache = [[CacheManager alloc] init];
    [cache setBid:testBid_1 forAdUnit:slot_1];

    BidManager *bidManager = [[BidManager alloc] init];
    bidManager.cacheManager = cache;

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DummyDfpRequest *dfpBidRequest = [[DummyDfpRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    Config *config = [[Config alloc] initWithNetworkId:@(1234)];
    config.killSwitch = YES;
    bidManager.config = config;

    [bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:slot_1];
    // there shouldn't be any enrichment
    XCTAssertTrue(dfpBidRequest.customTargeting.count == 2);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crt_displayUrl"]);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crt_cpm"]);
}

@end
