//
//  CR_BidManagerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <OCMock.h>

#import "CR_BidManager.h"
#import "CR_CdbBid.h"
#import "DummyDfpRequest.h"

@interface CR_BidManagerTests : XCTestCase

@end

@implementation CR_BidManagerTests

- (void) testGetBid {
    // test cache
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slots with fetched bids
    CR_CdbBid *testBid = [[CR_CdbBid alloc] init];
    CRAdUnit *testAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    cache.bidCache[testAdUnit] = testBid;

    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] init];
    CRAdUnit *testAdUnit_2 = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    cache.bidCache[testAdUnit_2] = testBid_2;

    Config *mockConfig = OCMStrictClassMock([Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    GdprUserConsent *mockUserConsent = OCMStrictClassMock([GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    // if the caller asks for a bid for an un initialized slot
    CRAdUnit *unInitializedSlot = [[CRAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    id mockApiHandler = OCMClassMock([ApiHandler class]);
    // Do not call CDB for unregistered ad units
    OCMReject([mockApiHandler callCdb:unInitializedSlot gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    NSArray *slots = @[testAdUnit, testAdUnit_2, unInitializedSlot];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertEqualObjects(testBid, bids[testAdUnit]);
    XCTAssertEqualObjects(testBid_2, bids[testAdUnit_2]);
    XCTAssertTrue([bids[unInitializedSlot] isEmpty]);
    // Only call [ApiHandler callCdb] for registered Ad Units
    OCMVerify([mockApiHandler callCdb:testAdUnit gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMVerify([mockApiHandler callCdb:testAdUnit_2 gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void) testGetBidForSlotThatHasntBeenFetchedFromCdb {
    // test cache
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slot that has no bid fetched for it
    CR_CdbBid *testEmptyBid = [CR_CdbBid emptyBid];
    CRAdUnit *testEmptyAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"thisShouldReturnEmptyBid" width:300 height:250];
    cache.bidCache[testEmptyAdUnit] = testEmptyBid;

    GdprUserConsent *mockUserConsent = OCMStrictClassMock([GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                                   config:nil
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    // an initialized slot that has no bid fetched for it
    NSArray *slots = @[[[CRAdUnit alloc] initWithAdUnitId:@"thisShouldReturnEmptyBid" width:300 height:250]];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([bids[testEmptyAdUnit] isEmpty]);
}

- (void) testSetSlots {
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:[[CR_CacheManager alloc] init]
                                                                   config:nil
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    CRAdUnit *slot_1 = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CRAdUnit *slot_2 = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    CRAdUnit *slot_3 = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid_2" width:200 height:100];

    NSArray *slots = @[slot_1, slot_2, slot_3];

    [bidManager setSlots:slots];

    NSDictionary *bids = [bidManager getBids:slots];

    XCTAssertTrue([bids[slot_1] isEmpty]);
    XCTAssertTrue([bids[slot_2] isEmpty]);
    XCTAssertTrue([bids[slot_3] isEmpty]);
}

- (void) testAddCriteoBidToRequest {
    CRAdUnit *slot_1 = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1 forAdUnit:slot_1];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DummyDfpRequest *dfpBidRequest = [[DummyDfpRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    Config *config = [[Config alloc] initWithNetworkId:@(1234)];

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                                   config:config
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    [bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:slot_1];

    XCTAssertTrue(dfpBidRequest.customTargeting.count > 2);
    XCTAssertEqualObjects([testBid_1 dfpCompatibleDisplayUrl],[dfpBidRequest.customTargeting objectForKey:@"crt_displayUrl"]);
    XCTAssertEqualObjects([testBid_1 cpm], [dfpBidRequest.customTargeting objectForKey:@"crt_cpm"]);
}

- (void) testAddCriteoBidToRequestWhenKillSwitchIsEngaged {
    CRAdUnit *slot_1 = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1 forAdUnit:slot_1];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DummyDfpRequest *dfpBidRequest = [[DummyDfpRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    Config *config = [[Config alloc] initWithNetworkId:@(1234)];
    config.killSwitch = YES;

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                                   config:config
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    [bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:slot_1];
    // there shouldn't be any enrichment
    XCTAssertTrue(dfpBidRequest.customTargeting.count == 2);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crt_displayUrl"]);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crt_cpm"]);
}

// TTNC -> Time to next call
- (void) testGetBidTtncNotExpired {
    // test cache
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slots with fetched bids
    CR_CdbBid *testBid = [[CR_CdbBid alloc] init];
    CRAdUnit *testAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    cache.bidCache[testAdUnit] = testBid;

    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] init];
    CRAdUnit *testAdUnit_2 = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    cache.bidCache[testAdUnit_2] = testBid_2;

    Config *mockConfig = OCMStrictClassMock([Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    GdprUserConsent *mockUserConsent = OCMStrictClassMock([GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    // if the caller asks for a bid for an un initialized slot
    CRAdUnit *unInitializedSlot = [[CRAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    id mockApiHandler = OCMClassMock([ApiHandler class]);
    // NO calls should be made to [ApiHandler callCdb]
    OCMReject([mockApiHandler callCdb:testAdUnit gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMReject([mockApiHandler callCdb:testAdUnit_2 gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMReject([mockApiHandler callCdb:unInitializedSlot gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:[[NSDate dateWithTimeIntervalSinceNow:360] timeIntervalSinceReferenceDate]];

    NSArray *slots = @[testAdUnit, testAdUnit_2, unInitializedSlot];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertEqualObjects(testBid, bids[testAdUnit]);
    XCTAssertEqualObjects(testBid_2, bids[testAdUnit_2]);
    XCTAssertTrue([bids[unInitializedSlot] isEmpty]);
}

@end
