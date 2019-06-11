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
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:testAdUnit.adUnitId cpm:@"2.0" currency:@"USD" width:@(testAdUnit.size.width) height:@(testAdUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];
    cache.bidCache[testAdUnit] = testBid;

    CR_CacheAdUnit *testAdUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:testAdUnit_2.adUnitId cpm:@"0.5" currency:@"USD" width:@(testAdUnit_2.size.width) height:@(testAdUnit_2.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl_2.com" insertTime:[NSDate date]];
    cache.bidCache[testAdUnit_2] = testBid_2;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo waitForUserAgent:[OCMArg invokeBlock]]);

    // if the caller asks for a bid for an un initialized slot
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    id mockApiHandler = OCMClassMock([CR_ApiHandler class]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:mockDeviceInfo
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    NSArray *slots = @[testAdUnit, testAdUnit_2, unInitializedSlot];

    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertEqualObjects(testBid, bids[testAdUnit]);
    XCTAssertEqualObjects(testBid_2, bids[testAdUnit_2]);
    XCTAssertTrue([bids[unInitializedSlot] isEmpty]);
    // Only call [CR_ApiHandler callCdb] for registered Ad Units
    OCMVerify([mockApiHandler callCdb:testAdUnit gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMVerify([mockApiHandler callCdb:testAdUnit_2 gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void) testGetBidForSlotThatHasntBeenFetchedFromCdb {
    // test cache
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slot that has no bid fetched for it
    CR_CdbBid *testEmptyBid = [CR_CdbBid emptyBid];
    CR_CacheAdUnit *testEmptyAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"thisShouldReturnEmptyBid" width:300 height:250];
    cache.bidCache[testEmptyAdUnit] = testEmptyBid;

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
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
    NSArray *slots = @[[[CR_CacheAdUnit alloc] initWithAdUnitId:@"thisShouldReturnEmptyBid" width:300 height:250]];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([bids[testEmptyAdUnit] isEmpty]);
}

- (void) testGetBidIfInitialPrefetchFromCdbFailsAndTimeElapsed {

    CR_CacheManager *cache = OCMStrictClassMock([CR_CacheManager class]);
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    OCMStub([cache getBidForAdUnit:unInitializedSlot]).andReturn(nil);

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo waitForUserAgent:[OCMArg invokeBlock]]);

    id mockApiHandler = OCMStrictClassMock([CR_ApiHandler class]);

    CR_BidManager *bidManagerNotElapsed = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:mockDeviceInfo
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:-2];

    //make sure CDB call was invoked
    OCMStub([mockApiHandler callCdb:unInitializedSlot gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    [bidManagerNotElapsed getBid:unInitializedSlot];
    OCMVerify([mockApiHandler callCdb:unInitializedSlot gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void)  testGetBidIfInitialPrefetchFromCdbFailsAndTimeNotElapsed {

    CR_CacheManager *cache = OCMStrictClassMock([CR_CacheManager class]);
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    OCMStub([cache getBidForAdUnit:unInitializedSlot]).andReturn(nil); // this implies initial prefetch failed

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo waitForUserAgent:[OCMArg invokeBlock]]);

    id mockApiHandler = OCMStrictClassMock([CR_ApiHandler class]);

    // time to next call is really large which would make sure time is not elapsed
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                                    cacheManager:cache
                                                                          config:mockConfig
                                                                   configManager:nil
                                                                      deviceInfo:mockDeviceInfo
                                                                 gdprUserConsent:mockUserConsent
                                                                  networkManager:nil
                                                                       appEvents:nil
                                                                  timeToNextCall:INFINITY];

    //make sure CDB call was not invoked
    OCMReject([mockApiHandler callCdb:unInitializedSlot gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    [bidManager getBid:unInitializedSlot];
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

    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CacheAdUnit *slot_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    CR_CacheAdUnit *slot_3 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_2" width:200 height:100];

    NSArray *slots = @[slot_1, slot_2, slot_3];

    [bidManager setSlots:slots];

    NSDictionary *bids = [bidManager getBids:slots];

    XCTAssertTrue([bids[slot_1] isEmpty]);
    XCTAssertTrue([bids[slot_2] isEmpty]);
    XCTAssertTrue([bids[slot_3] isEmpty]);
}

- (void) testAddCriteoBidToRequest {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1 forAdUnit:slot_1];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DummyDfpRequest *dfpBidRequest = [[DummyDfpRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;
    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];

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
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1 forAdUnit:slot_1];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DummyDfpRequest *dfpBidRequest = [[DummyDfpRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];
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
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:testAdUnit.adUnitId cpm:@"2.0" currency:@"USD" width:@(testAdUnit.size.width) height:@(testAdUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];
    cache.bidCache[testAdUnit] = testBid;

    CR_CacheAdUnit *testAdUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:testAdUnit_2.adUnitId cpm:@"0.5" currency:@"USD" width:@(testAdUnit_2.size.width) height:@(testAdUnit_2.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl_2.com" insertTime:[NSDate date]];
    cache.bidCache[testAdUnit_2] = testBid_2;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    // if the caller asks for a bid for an un initialized slot
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    id mockApiHandler = OCMClassMock([CR_ApiHandler class]);
    // NO calls should be made to [CR_ApiHandler callCdb]
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

- (void) testGetBidCpmIsZeroSlotIsSilenced {
    // cpm ==0 && ttl > 0 and ttl has NOT expired
    // test cache
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slots with fetched bids
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:testAdUnit.adUnitId cpm:@"0.0" currency:@"USD" width:@(testAdUnit.size.width) height:@(testAdUnit.size.height) ttl:600 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo waitForUserAgent:[OCMArg invokeBlock]]);

    id mockApiHandler = OCMClassMock([CR_ApiHandler class]);
    OCMReject([mockApiHandler callCdb:testAdUnit gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:mockDeviceInfo
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    NSArray *slots = @[testAdUnit];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([bids[testAdUnit] isEmpty]);
}

- (void) testGetBidCpmIsZeroSlotIsNotSilenced {
    // cpm ==0 && ttl > 0 and ttl has expired
    // test cache
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slots with fetched bids
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:testAdUnit.adUnitId cpm:@"0.0" currency:@"USD" width:@(testAdUnit.size.width) height:@(testAdUnit.size.height) ttl:10 creative:nil displayUrl:@"https://someUrl.com" insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-400]];
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo waitForUserAgent:[OCMArg invokeBlock]]);

    id mockApiHandler = OCMClassMock([CR_ApiHandler class]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:mockDeviceInfo
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    NSArray *slots = @[testAdUnit];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertEqualObjects(testBid, bids[testAdUnit]);

    // Only call [CR_ApiHandler callCdb] for registered Ad Units
    OCMVerify([mockApiHandler callCdb:testAdUnit gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void) testGetBidWhenNoBid {
    // cpm ==0 && ttl == 0
    // test cache
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slots with fetched bids
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:testAdUnit.adUnitId cpm:@"0.0" currency:@"USD" width:@(testAdUnit.size.width) height:@(testAdUnit.size.height) ttl:0 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date]];
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo waitForUserAgent:[OCMArg invokeBlock]]);

    id mockApiHandler = OCMClassMock([CR_ApiHandler class]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:mockDeviceInfo
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    NSArray *slots = @[testAdUnit];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([bids[testAdUnit] isEmpty]);

    // Only call [CR_ApiHandler callCdb] for registered Ad Units
    OCMVerify([mockApiHandler callCdb:testAdUnit gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

@end
