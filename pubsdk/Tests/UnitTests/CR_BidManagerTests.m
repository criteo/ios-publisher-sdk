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
#import "NSString+CR_UrlEncoder.h"
#import "CR_BidManager.h"
#import "CR_BidManagerBuilder.h"
#import "CR_CdbBid.h"
#import "CRBidToken+Internal.h"
#import "DFPRequestClasses.h"
#import <MoPub.h>
#import "CR_CdbBidBuilder.h"
#import "CR_DeviceInfoMock.h"

static NSString * const CR_BidManagerTestsCpm = @"crt_cpm";
static NSString * const CR_BidManagerTestsDisplayUrl = @"crt_displayUrl";
static NSString * const CR_BidManagerTestsDfpDisplayUrl = @"crt_displayurl";

@interface CR_BidManagerTests : XCTestCase

@property (nonatomic, strong) NSMutableDictionary *mutableJsonDict;

@property (nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property (nonatomic, strong) CR_CacheManager *cacheManager;
@property (nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property (nonatomic, strong) CR_ConfigManager *configManagerMock;
@property (nonatomic, strong) CR_BidManagerBuilder *builder;
@property (nonatomic, strong) CR_BidManager *bidManager;

@end

@implementation CR_BidManagerTests

- (void)setUp {
    self.mutableJsonDict = [self _loadSlotDictionary];
    self.deviceInfoMock = [[CR_DeviceInfoMock alloc] init];
    self.cacheManager = [[CR_CacheManager alloc] init];
    self.configManagerMock = OCMClassMock([CR_ConfigManager class]);
    self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);

    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    builder.configManager = self.configManagerMock;
    builder.cacheManager = self.cacheManager;
    builder.apiHandler = self.apiHandlerMock;
    builder.deviceInfo = self.deviceInfoMock;

    self.builder = builder;
    self.bidManager = [builder buildBidManager];
}

- (void)testGetBid {
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).build;
    self.cacheManager.bidCache[testAdUnit] = testBid;

    CR_CacheAdUnit *testAdUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    CR_CdbBid *testBid_2 = CR_CdbBidBuilder.new.adUnit(testAdUnit_2).cpm(@"0.5").build;
    self.cacheManager.bidCache[testAdUnit_2] = testBid_2;

    // if the caller asks for a bid for an un initialized slot
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];

    NSArray *slots = @[testAdUnit, testAdUnit_2, unInitializedSlot];

    NSDictionary *bids = [self.bidManager getBids:slots];
    XCTAssertEqualObjects(testBid, bids[testAdUnit]);
    XCTAssertEqualObjects(testBid_2, bids[testAdUnit_2]);
    XCTAssertTrue([bids[unInitializedSlot] isEmpty]);
    // Only call [CR_ApiHandler callCdb] for registered Ad Units
    OCMVerify([self.apiHandlerMock callCdb:@[testAdUnit] consent:[OCMArg any] config:[OCMArg any] deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
    OCMVerify([self.apiHandlerMock callCdb:@[testAdUnit_2] consent:[OCMArg any] config:[OCMArg any] deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void) testGetBidForSlotThatHasntBeenFetchedFromCdb {
    CR_CdbBid *testEmptyBid = [CR_CdbBid emptyBid];
    CR_CacheAdUnit *testEmptyAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"thisShouldReturnEmptyBid" width:300 height:250];
    self.cacheManager.bidCache[testEmptyAdUnit] = testEmptyBid;

    NSDictionary *bids = [self.bidManager getBids:@[ testEmptyAdUnit ]];

    XCTAssertTrue([bids[testEmptyAdUnit] isEmpty]);
}

- (void)testGetBidIfInitialPrefetchFromCdbFailsAndTimeElapsed {
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];
    self.builder.timeToNextCall = -2;
    self.bidManager = [self.builder buildBidManager];

    [self.bidManager getBid:unInitializedSlot];

    OCMVerify([self.apiHandlerMock callCdb:@[unInitializedSlot]
                                   consent:[OCMArg any]
                                    config:[OCMArg any]
                                deviceInfo:[OCMArg any]
                      ahCdbResponseHandler:[OCMArg any]]);
}

- (void)testGetBidIfInitialPrefetchFromCdbFailsAndTimeNotElapsed {
    self.builder.timeToNextCall = INFINITY;
    self.bidManager = [self.builder buildBidManager];
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];
    OCMReject([self.apiHandlerMock callCdb:@[unInitializedSlot]
                                   consent:[OCMArg any]
                                    config:[OCMArg any]
                                deviceInfo:[OCMArg any]
                      ahCdbResponseHandler:[OCMArg any]]);

    [self.bidManager getBid:unInitializedSlot];
}

- (void)testSetSlots {
    NSArray<CR_CacheAdUnit *> *slots = [self _buildSlots];
    [self.bidManager registerWithSlots:slots];

    NSDictionary *bids = [self.bidManager getBids:slots];

    XCTAssertTrue([bids[slots[0]] isEmpty]);
    XCTAssertTrue([bids[slots[1]] isEmpty]);
    XCTAssertTrue([bids[slots[2]] isEmpty]);
}

- (void)testAddCriteoBidToMutableDictionary {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).cpm(@"1.1200000047683716").currency(@"EUR").build;
    [self.cacheManager setBid:testBid_1];

    NSMutableDictionary<NSString*,NSString*> *biddableDictionary = [NSMutableDictionary new];

    [self.bidManager addCriteoBidToRequest:biddableDictionary forAdUnit:slot_1];

    XCTAssert(biddableDictionary.count == 2);
    XCTAssertEqualObjects(biddableDictionary[CR_BidManagerTestsDisplayUrl], testBid_1.displayUrl);
    XCTAssertEqualObjects(biddableDictionary[CR_BidManagerTestsCpm], testBid_1.cpm);
}

- (void)testAddCriteoBidToNonBiddableObjectsDoesNotCrash {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    NSDictionary *nonBiddableDictionary = [NSDictionary new];
    [self.bidManager addCriteoBidToRequest:nonBiddableDictionary forAdUnit:slot_1];

    NSSet *nonBiddableSet = [NSSet new];
    [self.bidManager addCriteoBidToRequest:nonBiddableSet forAdUnit:slot_1];

    NSString *aString = @"1234abcd";
    [self.bidManager addCriteoBidToRequest:aString forAdUnit:slot_1];

    NSMutableDictionary *nilDictionary = nil;
    [self.bidManager addCriteoBidToRequest:nilDictionary forAdUnit:slot_1];
}

- (void)testAddCriteoBidToDfpRequest {
    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = @{ @"key_1": @"object 1", @"key_2": @"object_2" };
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).build;
    [self.cacheManager setBid:testBid_1];

    [self.bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:slot_1];

    XCTAssertTrue(dfpBidRequest.customTargeting.count > 2);
    XCTAssertEqualObjects([testBid_1 dfpCompatibleDisplayUrl], dfpBidRequest.customTargeting[CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertEqualObjects([testBid_1 cpm], dfpBidRequest.customTargeting[CR_BidManagerTestsCpm]);
}

- (void)testAddCriteoBidToDifferentDfpRequestTypes {
#define CR_CheckRequest(requestType) \
{ \
    [self.cacheManager setBid:testBid_1]; \
    requestType *r = [requestType new]; \
    [self.bidManager addCriteoBidToRequest:r forAdUnit:slot_1]; \
    XCTAssertTrue(r.customTargeting.count == 2); \
    XCTAssertEqualObjects([testBid_1 dfpCompatibleDisplayUrl], r.customTargeting[CR_BidManagerTestsDfpDisplayUrl]); \
    XCTAssertEqualObjects([testBid_1 cpm], r.customTargeting[CR_BidManagerTestsCpm]); \
}
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).build;

    CR_CheckRequest(DFPORequest);
    CR_CheckRequest(DFPNRequest);
    CR_CheckRequest(GADRequest);
    CR_CheckRequest(GADORequest);
    CR_CheckRequest(GADNRequest);
}

- (void)testAddCriteoBidToMopubAdViewRequest {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).build;
    [self.cacheManager setBid:testBid_1];
    MPAdView *mopubBidRequest = [[MPAdView alloc] init];
    mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_1];

    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);
}

- (void)testLoadMopubInterstitial {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).build;;
    [self.cacheManager setBid:testBid_1];
    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_1];
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
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).displayUrl(@"url_1").cpm(@"1.1").build;
    CR_CdbBid *testBid_2 = CR_CdbBidBuilder.new.adUnit(slot_2).build;
    [self.cacheManager setBid:testBid_1];
    [self.cacheManager setBid:testBid_2];

    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_1];
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_2];
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
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).build;;
    [self.cacheManager setBid:testBid_1];
    MPInterstitialAdController *mpInterstitialAdController = [MPInterstitialAdController new];

    [self.bidManager addCriteoBidToRequest:mpInterstitialAdController forAdUnit:slot_1];

    XCTAssertTrue([mpInterstitialAdController.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mpInterstitialAdController.keywords containsString:[testBid_1 cpm]]);
}

- (void)testAddCriteoBidToRequestWhenKillSwitchIsEngaged {
    self.builder.config.killSwitch = YES;
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).build;
    [self.cacheManager setBid:testBid_1];
    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = @{ @"key_1": @"object_1", @"key_2": @"object_2" };

    [self.bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:slot_1];

    // there shouldn't be any enrichment
    XCTAssertTrue(dfpBidRequest.customTargeting.count == 2);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:CR_BidManagerTestsCpm]);
}

- (void)testGetBidTtncNotExpired { // TTNC -> Time to next call
    self.builder.timeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:360] timeIntervalSinceReferenceDate];
    self.bidManager = [self.builder buildBidManager];
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).build;;
    self.cacheManager.bidCache[testAdUnit] = testBid;
    CR_CacheAdUnit *testAdUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    CR_CdbBid *testBid_2 = CR_CdbBidBuilder.new.adUnit(testAdUnit_2).build;
    self.cacheManager.bidCache[testAdUnit_2] = testBid_2;
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];
    OCMReject([self.apiHandlerMock callCdb:[OCMArg any]
                                   consent:[OCMArg any]
                                    config:[OCMArg any]
                                deviceInfo:[OCMArg any]
                      ahCdbResponseHandler:[OCMArg any]]);

    NSDictionary *bids = [self.bidManager getBids:@[testAdUnit, testAdUnit_2, unInitializedSlot]];

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
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).cpm(@"0.0").build;
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_DataProtectionConsent *mockUserConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo waitForUserAgent:[OCMArg invokeBlock]]);

    id mockApiHandler = OCMClassMock([CR_ApiHandler class]);
    OCMReject([mockApiHandler callCdb:@[testAdUnit] consent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:mockApiHandler
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:mockDeviceInfo
                                                                  consent:mockUserConsent
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
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).expiredInsertTime().build;
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_DataProtectionConsent *mockUserConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
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
                                                                  consent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    NSArray *slots = @[testAdUnit];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([bids[testAdUnit] isEmpty]);

    // Only call [CR_ApiHandler callCdb] for registered Ad Units
    OCMVerify([mockApiHandler callCdb:@[testAdUnit] consent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
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
                                                                  consent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                         size:CGSizeMake(320, 50)
                                                                   adUnitType:CRAdUnitTypeBanner];

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
                                                                  consent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                         size:CGSizeMake(320, 50)
                                                                   adUnitType:CRAdUnitTypeBanner];
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
                                                    insertTime:[NSDate date]
                                                  nativeAssets:nil];

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
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).ttl(0).build;
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_DataProtectionConsent *mockUserConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
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
                                                                  consent:mockUserConsent
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    NSArray *slots = @[testAdUnit];
    NSDictionary *bids = [bidManager getBids:slots];
    XCTAssertTrue([bids[testAdUnit] isEmpty]);

    // Only call [CR_ApiHandler callCdb] for registered Ad Units
    OCMVerify([mockApiHandler callCdb:@[testAdUnit] consent:mockUserConsent config:mockConfig deviceInfo:[OCMArg any] ahCdbResponseHandler:[OCMArg any]]);
}

- (void)testGetBidWhenBidExpired {
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];

    // initialized slots with fetched bids
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid"
                                                                    width:300
                                                                   height:250];
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).expiredInsertTime().build;
    cache.bidCache[testAdUnit] = testBid;

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig killSwitch]).andReturn(NO);

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:mockConfig
                                                            configManager:nil
                                                               deviceInfo:nil
                                                                  consent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    CR_CdbBid *expectedBid = [bidManager getBid:testAdUnit];
    XCTAssertTrue([expectedBid isEmpty]);
}

- (void)testAddCriteoBidToRequestWhenConfigIsNil {
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = CR_CdbBidBuilder.new.adUnit(slot_1).build;
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:nil
                                                            configManager:nil
                                                               deviceInfo:nil
                                                                  consent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];
    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DFPRequest *dfpRequest = [[DFPRequest alloc] init];
    dfpRequest.customTargeting = testDfpCustomTargeting;
    [bidManager addCriteoBidToRequest:dfpRequest forAdUnit:slot_1];
    XCTAssertTrue(dfpRequest.customTargeting.count == 2);
    XCTAssertNil([dfpRequest.customTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertNil([dfpRequest.customTargeting objectForKey:CR_BidManagerTestsCpm]);
}

- (void)checkMandatoryNativeAssets:(DFPRequest *)dfpBidRequest nativeBid:(CR_CdbBid *)nativeBid {
    XCTAssert(nativeBid.nativeAssets.products.count > 0);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.products[0].title],[dfpBidRequest.customTargeting objectForKey:@"crtn_title"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.products[0].description],[dfpBidRequest.customTargeting objectForKey:@"crtn_desc"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.products[0].price],[dfpBidRequest.customTargeting objectForKey:@"crtn_price"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.products[0].clickUrl],[dfpBidRequest.customTargeting objectForKey:@"crtn_clickurl"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.products[0].callToAction],[dfpBidRequest.customTargeting objectForKey:@"crtn_cta"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.products[0].image.url],[dfpBidRequest.customTargeting objectForKey:@"crtn_imageurl"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.privacy.optoutClickUrl],[dfpBidRequest.customTargeting objectForKey:@"crtn_prurl"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.privacy.optoutImageUrl],[dfpBidRequest.customTargeting objectForKey:@"crtn_primageurl"]);
    XCTAssertEqual(nativeBid.nativeAssets.impressionPixels.count,[[dfpBidRequest.customTargeting objectForKey:@"crtn_pixcount"] integerValue]);
    for(int i = 0; i < nativeBid.nativeAssets.impressionPixels.count; i++) {
        NSString *key = [NSString stringWithFormat:@"%@%d", @"crtn_pixurl_", i];
       XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.impressionPixels[i]],[dfpBidRequest.customTargeting objectForKey:key]);
    }
}

- (void) testAddCriteoNativeBidToDfpRequest {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict receivedAt:[NSDate date]];
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:nativeBid];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                            configManager:nil
                                                               deviceInfo:nil
                                                                  consent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    [bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:adUnit];

    XCTAssertTrue(dfpBidRequest.customTargeting.count > 2);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertEqual(nativeBid.cpm, [dfpBidRequest.customTargeting objectForKey:CR_BidManagerTestsCpm]);
    [self checkMandatoryNativeAssets:dfpBidRequest nativeBid:nativeBid];
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.advertiser.description],[dfpBidRequest.customTargeting objectForKey:@"crtn_advname"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.advertiser.domain],[dfpBidRequest.customTargeting objectForKey:@"crtn_advdomain"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.advertiser.logoImage.url],[dfpBidRequest.customTargeting objectForKey:@"crtn_advlogourl"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.advertiser.logoClickUrl],[dfpBidRequest.customTargeting objectForKey:@"crtn_advurl"]);
    XCTAssertEqualObjects([NSString dfpCompatibleString:nativeBid.nativeAssets.privacy.longLegalText],[dfpBidRequest.customTargeting objectForKey:@"crtn_prtext"]);

}

- (void) testAddCriteoToDfpRequestForInCompleteNativeBid {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    self.mutableJsonDict[@"native"][@"advertiser"][@"description"] = @"";
    self.mutableJsonDict[@"native"][@"advertiser"][@"domain"] = @"";
    self.mutableJsonDict[@"native"][@"advertiser"][@"logo"][@"url"] = nil;
    self.mutableJsonDict[@"native"][@"advertiser"][@"logoClickUrl"] = @"";
    self.mutableJsonDict[@"native"][@"privacy"][@"longLegalText"] = nil;
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict receivedAt:[NSDate date]];
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:nativeBid];

    NSDictionary *testDfpCustomTargeting = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key_1", @"object_2", @"key_2", nil];

    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = testDfpCustomTargeting;

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:[[CR_Config alloc] initWithCriteoPublisherId:@("1234")]
                                                            configManager:nil
                                                               deviceInfo:nil
                                                                  consent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0];

    [bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:adUnit];

    XCTAssertTrue(dfpBidRequest.customTargeting.count > 2);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertEqual(nativeBid.cpm, [dfpBidRequest.customTargeting objectForKey:CR_BidManagerTestsCpm]);
    [self checkMandatoryNativeAssets:dfpBidRequest nativeBid:nativeBid];
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crtn_advname"]);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crtn_advdomain"]);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crtn_advlogourl"]);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crtn_advurl"]);
    XCTAssertNil([dfpBidRequest.customTargeting objectForKey:@"crtn_prtext"]);

}

- (void)testInitDoNotRefreshConfiguration
{
    OCMReject([self.configManagerMock refreshConfig:[OCMArg any]]);
}

- (void)testSlotRegistrationRefreshConfiguration
{
    [self.bidManager registerWithSlots:[self _buildSlots]];

    OCMVerify([self.configManagerMock refreshConfig:[OCMArg any]]);
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

- (NSArray<CR_CacheAdUnit *> *)_buildSlots
{
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CacheAdUnit *slot_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:200 height:100];
    CR_CacheAdUnit *slot_3 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_2" width:200 height:100];

    NSArray *slots = @[slot_1, slot_2, slot_3];
    return slots;
}

- (NSMutableDictionary *)_loadSampleBidJson {
    NSError *e = NULL;
    NSURL *jsonURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"SampleBid" withExtension:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:0 error:&e];
    XCTAssert(e == nil);

    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&e];
    XCTAssert(e == nil);
    return responseDict;
}

- (NSMutableDictionary *)_loadSlotDictionary {
    NSMutableDictionary *responseDict = [self _loadSampleBidJson][@"slots"][0];
    XCTAssert(responseDict);
    return responseDict;
}

@end
