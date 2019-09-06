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
#import "CRBidToken+Internal.h"
#import "DFPRequestClasses.h"
#import "MPClasses.h"

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
                                                               tokenCache:nil
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
    OCMVerify([mockApiHandler callCdb:@[testAdUnit] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMVerify([mockApiHandler callCdb:@[testAdUnit_2] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
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
                                                               tokenCache:nil
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
                                                                         tokenCache:nil
                                                                             config:mockConfig
                                                                      configManager:nil
                                                                         deviceInfo:mockDeviceInfo
                                                                    gdprUserConsent:mockUserConsent
                                                                     networkManager:nil
                                                                          appEvents:nil
                                                                     timeToNextCall:-2];

    //make sure CDB call was invoked
    OCMStub([mockApiHandler callCdb:@[unInitializedSlot] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    [bidManagerNotElapsed getBid:unInitializedSlot];
    OCMVerify([mockApiHandler callCdb:@[unInitializedSlot] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
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
                                                               tokenCache:nil
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:mockDeviceInfo
                                                          gdprUserConsent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:INFINITY];

    //make sure CDB call was not invoked
    OCMReject([mockApiHandler callCdb:@[unInitializedSlot] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    [bidManager getBid:unInitializedSlot];
}

- (void) testSetSlots {
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:[[CR_CacheManager alloc] init] tokenCache:nil
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

- (void) testAddCriteoBidToDfpRequest {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;
    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
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

- (void) testConditionAddCriteoBidToDifferentDfpRequestTypes {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];

    // DFPRequest test
    CR_BidManager *bidManagerDFP = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    id mockDfpRequest = OCMClassMock([DFPRequest class]);
    SEL dfpCustomTargeting = NSSelectorFromString(@"customTargeting");
    OCMStub([mockDfpRequest performSelector:dfpCustomTargeting]).andReturn(nil);
    [bidManagerDFP addCriteoBidToRequest:mockDfpRequest forAdUnit:slot_1];
    OCMVerify([mockDfpRequest performSelector:dfpCustomTargeting]);

    // DFPORequest test
    CR_CacheManager *cacheDFPO = [[CR_CacheManager alloc] init];
    [cacheDFPO setBid:testBid_1];
    CR_BidManager *bidManagerDFPO = [[CR_BidManager alloc] initWithApiHandler:nil
                                                                cacheManager:cacheDFPO
                                                                  tokenCache:nil
                                                                      config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                               configManager:nil
                                                                  deviceInfo:nil
                                                             gdprUserConsent:nil
                                                              networkManager:nil
                                                                   appEvents:nil
                                                              timeToNextCall:0];

    id mockDfpoRequest = OCMClassMock([DFPORequest class]);
    OCMStub([mockDfpoRequest performSelector:dfpCustomTargeting]).andReturn(nil);
    [bidManagerDFPO addCriteoBidToRequest:mockDfpoRequest forAdUnit:slot_1];
    OCMVerify([mockDfpoRequest performSelector:dfpCustomTargeting]);

    // DFPNRequest test
    CR_CacheManager *cacheDFPN = [[CR_CacheManager alloc] init];
    [cacheDFPN setBid:testBid_1];
    CR_BidManager *bidManagerDFPN = [[CR_BidManager alloc] initWithApiHandler:nil
                                                                 cacheManager:cacheDFPN
                                                                   tokenCache:nil
                                                                       config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                                configManager:nil
                                                                   deviceInfo:nil
                                                              gdprUserConsent:nil
                                                               networkManager:nil
                                                                    appEvents:nil
                                                               timeToNextCall:0];

    id mockDfpnRequest = OCMClassMock([DFPNRequest class]);
    OCMStub([mockDfpnRequest performSelector:dfpCustomTargeting]).andReturn(nil);
    [bidManagerDFPN addCriteoBidToRequest:mockDfpnRequest forAdUnit:slot_1];
    OCMVerify([mockDfpnRequest performSelector:dfpCustomTargeting]);

    // GADRequest test
    CR_CacheManager *cacheGAD = [[CR_CacheManager alloc] init];
    [cacheGAD setBid:testBid_1];
    CR_BidManager *bidManagerGAD = [[CR_BidManager alloc] initWithApiHandler:nil
                                                                 cacheManager:cacheGAD
                                                                   tokenCache:nil
                                                                       config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                                configManager:nil
                                                                   deviceInfo:nil
                                                              gdprUserConsent:nil
                                                               networkManager:nil
                                                                    appEvents:nil
                                                               timeToNextCall:0];

    id mockGadRequest = OCMClassMock([GADRequest class]);
    OCMStub([mockGadRequest performSelector:dfpCustomTargeting]).andReturn(nil);
    [bidManagerGAD addCriteoBidToRequest:mockGadRequest forAdUnit:slot_1];
    OCMVerify([mockGadRequest performSelector:dfpCustomTargeting]);

    // GADORequest test
    CR_CacheManager *cacheGADO = [[CR_CacheManager alloc] init];
    [cacheGADO setBid:testBid_1];
    CR_BidManager *bidManagerGADO = [[CR_BidManager alloc] initWithApiHandler:nil
                                                                cacheManager:cacheGADO
                                                                  tokenCache:nil
                                                                      config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                               configManager:nil
                                                                  deviceInfo:nil
                                                             gdprUserConsent:nil
                                                              networkManager:nil
                                                                   appEvents:nil
                                                              timeToNextCall:0];

    id mockGadoRequest = OCMClassMock([GADORequest class]);
    OCMStub([mockGadoRequest performSelector:dfpCustomTargeting]).andReturn(nil);
    [bidManagerGADO addCriteoBidToRequest:mockGadoRequest forAdUnit:slot_1];
    OCMVerify([mockGadoRequest performSelector:dfpCustomTargeting]);

    // GADNRequest test
    CR_CacheManager *cacheGADN = [[CR_CacheManager alloc] init];
    [cacheGADN setBid:testBid_1];
    CR_BidManager *bidManagerGADN = [[CR_BidManager alloc] initWithApiHandler:nil
                                                                 cacheManager:cacheGADN
                                                                   tokenCache:nil
                                                                       config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                                configManager:nil
                                                                   deviceInfo:nil
                                                              gdprUserConsent:nil
                                                               networkManager:nil
                                                                    appEvents:nil
                                                               timeToNextCall:0];

    id mockGadnRequest = OCMClassMock([GADNRequest class]);
    OCMStub([mockGadnRequest performSelector:dfpCustomTargeting]).andReturn(nil);
    [bidManagerGADN addCriteoBidToRequest:mockGadnRequest forAdUnit:slot_1];
    OCMVerify([mockGadnRequest performSelector:dfpCustomTargeting]);
}

- (void) testAddCriteoBidToMopubAdViewRequest {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];

    NSString *testMopubCustomTargeting = @"key1:object_1,key_2:object_2";

    MPAdView *mopubBidRequest = [[MPAdView alloc] init];
    mopubBidRequest.keywords = testMopubCustomTargeting;

    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:config
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    [bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_1];

    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);
}

- (void) testLoadMopubInterstitial {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];

    NSString *testMopubCustomTargeting = @"key1:object_1,key_2:object_2";

    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = testMopubCustomTargeting;

    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:config
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    [bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_1];
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);

    [mopubBidRequest loadAd];
    XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:@"crt_"]);
}

- (void)testDuplicateEnrichment {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CacheAdUnit *slot_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid2" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.237293459023" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"url_1" insertTime:[NSDate date]];
    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid2" cpm:@"2.29357205730" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"url_2" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];
    [cache setBid:testBid_2];

    NSString *testMopubCustomTargeting = @"key1:object_1,key_2:object_2";

    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = testMopubCustomTargeting;

    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:config
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    [bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_1];
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);

    [bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_2];
    XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_2 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_2 cpm]]);

    NSUInteger displayUrlCount = [CR_BidManagerTests checkNumOcurrencesOf:[testBid_2 mopubCompatibleDisplayUrl] inString:mopubBidRequest.keywords];
    NSUInteger cpmCount = [CR_BidManagerTests checkNumOcurrencesOf:[testBid_2 cpm] inString:mopubBidRequest.keywords];
    NSUInteger crtCount = [CR_BidManagerTests checkNumOcurrencesOf:@"crt_" inString:mopubBidRequest.keywords];
    XCTAssertEqual(displayUrlCount, 1);
    XCTAssertEqual(cpmCount, 1);
    XCTAssertEqual(crtCount, 2);
}

- (void)testConditionAddCriteoBidToMopubInterstitialAdController {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];
    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];

    // DFPRequest test
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                                cacheManager:cache
                                                                  tokenCache:nil
                                                                      config:config
                                                               configManager:nil
                                                                  deviceInfo:nil
                                                             gdprUserConsent:nil
                                                              networkManager:nil
                                                                   appEvents:nil
                                                              timeToNextCall:0];

    id mockMPInterstitialAdController = OCMClassMock([MPInterstitialAdController class]);
    SEL mopubKeywords = NSSelectorFromString(@"keywords");
    OCMStub([mockMPInterstitialAdController performSelector:mopubKeywords]).andReturn(nil);
    [bidManager addCriteoBidToRequest:mockMPInterstitialAdController forAdUnit:slot_1];
    OCMVerify([mockMPInterstitialAdController performSelector:mopubKeywords]);
}

- (void) testAddCriteoBidToRequestWhenKillSwitchIsEngaged {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date]];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];
    config.killSwitch = YES;

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
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
    OCMReject([mockApiHandler callCdb:@[testAdUnit] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMReject([mockApiHandler callCdb:@[testAdUnit_2] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMReject([mockApiHandler callCdb:@[unInitializedSlot] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                               tokenCache:nil
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
    OCMReject([mockApiHandler callCdb:@[testAdUnit] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                               tokenCache:nil
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
                                                               tokenCache:nil
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
    OCMVerify([mockApiHandler callCdb:@[testAdUnit] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void)testBidResponseForEmptyBid {
    CR_TokenCache *mockTokenCache = OCMStrictClassMock([CR_TokenCache class]);
    CR_CacheManager *mockCacheManager = OCMStrictClassMock([CR_CacheManager class]);
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:mockCacheManager
                                                               tokenCache:mockTokenCache
                                                                   config:nil
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                         size:CGSizeMake(320, 50)];

    CRBidResponse *expectedBidResponse = [[CRBidResponse alloc] initWithPrice:0.0
                                                                   bidSuccess:NO
                                                                     bidToken:nil];
    OCMStub([mockCacheManager getBidForAdUnit:expectedAdUnit]).andReturn(nil);
    CRBidResponse *bidResponse = [bidManager bidResponseForCacheAdUnit:expectedAdUnit
                               adUnitType:CRAdUnitTypeBanner];
    XCTAssertEqualWithAccuracy(expectedBidResponse.price, bidResponse.price, 0.1);
    XCTAssertEqual(expectedBidResponse.bidToken, bidResponse.bidToken);
    XCTAssertEqual(expectedBidResponse.bidSuccess, bidResponse.bidSuccess);
}

- (void)testBidResponseForValidBid {
    CR_TokenCache *mockTokenCache = OCMStrictClassMock([CR_TokenCache class]);
    CR_CacheManager *mockCacheManager = OCMStrictClassMock([CR_CacheManager class]);
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:mockCacheManager
                                                               tokenCache:mockTokenCache
                                                                   config:nil
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                         size:CGSizeMake(320, 50)];
    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];

    CRBidResponse *expectedBidResponse = [[CRBidResponse alloc] initWithPrice:4.2
                                                                   bidSuccess:YES
                                                                     bidToken:bidToken];
    CR_CdbBid *expectedBid = [[CR_CdbBid alloc] initWithZoneId:@123
                                                   placementId:@"placementId"
                                                           cpm:@"4.2"
                                                      currency:@"₹😀"
                                                         width:@47.0f
                                                        height:[NSNumber numberWithFloat:57.0f]
                                                           ttl:26
                                                      creative:@"THIS IS USELESS LEGACY"
                                                    displayUrl:@"123"
                                                    insertTime:[NSDate date]];

    OCMStub([mockCacheManager getBidForAdUnit:expectedAdUnit]).andReturn(expectedBid);
    OCMStub([mockCacheManager removeBidForAdUnit:expectedAdUnit]);
    OCMStub([mockTokenCache getTokenForBid:expectedBid adUnitType:CRAdUnitTypeBanner]).andReturn(bidToken);
    CRBidResponse *bidResponse = [bidManager bidResponseForCacheAdUnit:expectedAdUnit
                                                            adUnitType:CRAdUnitTypeBanner];
    XCTAssertEqualWithAccuracy(expectedBidResponse.price, bidResponse.price, 0.1);
    XCTAssertEqual(expectedBidResponse.bidToken, bidResponse.bidToken);
    XCTAssertEqual(expectedBidResponse.bidSuccess, bidResponse.bidSuccess);
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
                                                               tokenCache:nil
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
    OCMVerify([mockApiHandler callCdb:@[testAdUnit] gdprConsent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void)testGetBidWhenBidExpired {
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slots with fetched bids
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid"
                                                                    width:300
                                                                   height:250];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil
                                               placementId:testAdUnit.adUnitId
                                                       cpm:@"0.04"
                                                  currency:@"USD"
                                                     width:@(testAdUnit.size.width)
                                                    height:@(testAdUnit.size.height)
                                                       ttl:10
                                                  creative:nil
                                                displayUrl:@"https://someUrl.com"
                                                insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-400]];
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:nil
                                                          gdprUserConsent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    CR_CdbBid *expectedBid = [bidManager getBid:testAdUnit];
    XCTAssertTrue([expectedBid isEmpty]);
}

+ (NSUInteger)checkNumOcurrencesOf:(NSString *)substring
                          inString:(NSString *)string {
    NSUInteger count = 0, length = [string length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [string rangeOfString: substring options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
    return count;
}

@end
