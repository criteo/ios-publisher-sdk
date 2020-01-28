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
#import "NSString+Testing.h"
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

#define CR_AssertEqualDfpString(notDfpStr, dfpStr) \
    XCTAssertEqualObjects([NSString dfpCompatibleString:notDfpStr], dfpStr);

#define CR_OCMockVerifyCallCdb(apiHandlerMock, adUnits) \
    OCMVerify([apiHandlerMock callCdb:adUnits \
                              consent:[OCMArg any] \
                               config:[OCMArg any] \
                           deviceInfo:[OCMArg any] \
                 ahCdbResponseHandler:[OCMArg any]]);

#define CR_OCMockRejectCallCdb(apiHandlerMock, adUnits) \
    OCMReject([apiHandlerMock callCdb:adUnits \
                              consent:[OCMArg any] \
                               config:[OCMArg any] \
                           deviceInfo:[OCMArg any] \
                 ahCdbResponseHandler:[OCMArg any]]);

@interface CR_BidManagerTests : XCTestCase

@property (nonatomic, strong) NSMutableDictionary *mutableJsonDict;

@property (nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property (nonatomic, strong) CR_TokenCache *tokenCache;
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
    self.tokenCache = builder.tokenCache;
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
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[testAdUnit]);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[testAdUnit_2]);
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

    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[unInitializedSlot]);
}

- (void)testGetBidIfInitialPrefetchFromCdbFailsAndTimeNotElapsed {
    self.builder.timeToNextCall = INFINITY;
    self.bidManager = [self.builder buildBidManager];
    CR_CacheAdUnit *unInitializedSlot = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"uninitializedAdunitid" width:200 height:100];
    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[unInitializedSlot]);

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

    NSUInteger displayUrlCount = [mopubBidRequest.keywords ocurrencesCountOfSubstring:testBid_2.mopubCompatibleDisplayUrl];
    NSUInteger cpmCount = [mopubBidRequest.keywords ocurrencesCountOfSubstring:testBid_2.cpm];
    NSUInteger crtCount = [mopubBidRequest.keywords ocurrencesCountOfSubstring:@"crt_"];
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
    CR_OCMockRejectCallCdb(self.apiHandlerMock, [OCMArg any]);

    NSDictionary *bids = [self.bidManager getBids:@[testAdUnit, testAdUnit_2, unInitializedSlot]];

    XCTAssertEqualObjects(testBid, bids[testAdUnit]);
    XCTAssertEqualObjects(testBid_2, bids[testAdUnit_2]);
    XCTAssertTrue([bids[unInitializedSlot] isEmpty]);
}

- (void) testGetBidCpmIsZeroSlotIsSilenced {
    // cpm ==0 && ttl > 0 and ttl has NOT expired
    // test cache
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).cpm(@"0.0").build;
    self.cacheManager.bidCache[testAdUnit] = testBid;
    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[testAdUnit]);

    NSDictionary *bids = [self.bidManager getBids:@[testAdUnit]];

    XCTAssertTrue([bids[testAdUnit] isEmpty]);
}

- (void) testGetBidCpmIsZeroSlotIsNotSilenced {
    // cpm ==0 && ttl > 0 and ttl has expired
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).cpm(@"0.0").expiredInsertTime().build;
    self.cacheManager.bidCache[testAdUnit] = testBid;

    NSDictionary *bids = [self.bidManager getBids:@[testAdUnit]];
    XCTAssertTrue([bids[testAdUnit] isEmpty]);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[testAdUnit]);
}

- (void)testBidResponseForEmptyBid {
    CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                         size:CGSizeMake(320, 50)
                                                                   adUnitType:CRAdUnitTypeBanner];
    CRBidResponse *expectedBidResponse = [[CRBidResponse alloc] initWithPrice:0.0
                                                                   bidSuccess:NO
                                                                     bidToken:nil];

    CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:expectedAdUnit
                                                                 adUnitType:CRAdUnitTypeBanner];

    XCTAssertEqualWithAccuracy(expectedBidResponse.price, bidResponse.price, 0.1);
    XCTAssertEqual(expectedBidResponse.bidToken, bidResponse.bidToken);
    XCTAssertEqual(expectedBidResponse.bidSuccess, bidResponse.bidSuccess);
}

- (void)testBidResponseForValidBid {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                 size:CGSizeMake(320, 50)
                                                           adUnitType:CRAdUnitTypeBanner];
    CR_CdbBid *bid = CR_CdbBidBuilder.new.adUnit(adUnit).cpm(@"4.2").build;
    self.cacheManager.bidCache[adUnit] = bid;

    CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:adUnit
                                                                 adUnitType:CRAdUnitTypeBanner];

    XCTAssertEqualWithAccuracy(bidResponse.price, 4.2, 0.1);
    XCTAssert(bidResponse.bidSuccess);
}

- (void)testGetBidWhenNoBid {
    // cpm ==0 && ttl == 0
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).cpm(@"0.0").ttl(0).build;
    self.cacheManager.bidCache[testAdUnit] = testBid;

    NSDictionary *bids = [self.bidManager getBids:@[testAdUnit]];

    XCTAssertTrue([bids[testAdUnit] isEmpty]);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[testAdUnit]);
}

- (void)testGetBidWhenBidExpired {
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid"
                                                                    width:300
                                                                   height:250];
    CR_CdbBid *testBid = CR_CdbBidBuilder.new.adUnit(testAdUnit).expiredInsertTime().build;
    self.cacheManager.bidCache[testAdUnit] = testBid;

    CR_CdbBid *expectedBid = [self.bidManager getBid:testAdUnit];
    XCTAssertTrue([expectedBid isEmpty]);
}

- (void)checkMandatoryNativeAssets:(DFPRequest *)dfpBidRequest nativeBid:(CR_CdbBid *)nativeBid {
    CR_NativeAssets *nativeAssets = nativeBid.nativeAssets;
    CR_NativeProduct *firstProduct = nativeAssets.products[0];
    NSDictionary *dfpTargeting = dfpBidRequest.customTargeting;
    XCTAssert(nativeBid.nativeAssets.products.count > 0);
    CR_AssertEqualDfpString(firstProduct.title, dfpTargeting[@"crtn_title"]);
    CR_AssertEqualDfpString(firstProduct.description, dfpTargeting[@"crtn_desc"]);
    CR_AssertEqualDfpString(firstProduct.price, dfpTargeting[@"crtn_price"]);
    CR_AssertEqualDfpString(firstProduct.clickUrl, dfpTargeting[@"crtn_clickurl"]);
    CR_AssertEqualDfpString(firstProduct.callToAction, dfpTargeting[@"crtn_cta"]);
    CR_AssertEqualDfpString(firstProduct.image.url, dfpTargeting[@"crtn_imageurl"]);
    CR_AssertEqualDfpString(nativeAssets.privacy.optoutClickUrl, dfpTargeting[@"crtn_prurl"]);
    CR_AssertEqualDfpString(nativeAssets.privacy.optoutImageUrl, dfpTargeting[@"crtn_primageurl"]);
    XCTAssertEqual(nativeAssets.impressionPixels.count, [dfpTargeting[@"crtn_pixcount"] integerValue]);
    for(int i = 0; i < nativeBid.nativeAssets.impressionPixels.count; i++) {
        NSString *key = [NSString stringWithFormat:@"%@%d", @"crtn_pixurl_", i];
       CR_AssertEqualDfpString(nativeBid.nativeAssets.impressionPixels[i], dfpTargeting[key]);
    }
}

- (void)testAddCriteoNativeBidToDfpRequest {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict receivedAt:[NSDate date]];
    [self.cacheManager setBid:nativeBid];
    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = @{ @"key_1": @"object 1", @"key_2": @"object_2" };

    [self.bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:adUnit];

    CR_NativeAssets *nativeAssets = nativeBid.nativeAssets;
    NSDictionary *dfpTargeting = dfpBidRequest.customTargeting;
    XCTAssertTrue(dfpTargeting.count > 2);
    XCTAssertNil([dfpTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertEqual(nativeBid.cpm, dfpTargeting[CR_BidManagerTestsCpm]);
    [self checkMandatoryNativeAssets:dfpBidRequest nativeBid:nativeBid];
    CR_AssertEqualDfpString(nativeAssets.advertiser.description, dfpTargeting[@"crtn_advname"]);
    CR_AssertEqualDfpString(nativeAssets.advertiser.domain, dfpTargeting[@"crtn_advdomain"]);
    CR_AssertEqualDfpString(nativeAssets.advertiser.logoImage.url, dfpTargeting[@"crtn_advlogourl"]);
    CR_AssertEqualDfpString(nativeAssets.advertiser.logoClickUrl, dfpTargeting[@"crtn_advurl"]);
    CR_AssertEqualDfpString(nativeAssets.privacy.longLegalText, dfpTargeting[@"crtn_prtext"]);
}

- (void) testAddCriteoToDfpRequestForInCompleteNativeBid {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    self.mutableJsonDict[@"native"][@"advertiser"][@"description"] = @"";
    self.mutableJsonDict[@"native"][@"advertiser"][@"domain"] = @"";
    self.mutableJsonDict[@"native"][@"advertiser"][@"logo"][@"url"] = nil;
    self.mutableJsonDict[@"native"][@"advertiser"][@"logoClickUrl"] = @"";
    self.mutableJsonDict[@"native"][@"privacy"][@"longLegalText"] = nil;
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict receivedAt:[NSDate date]];
    [self.cacheManager setBid:nativeBid];

    DFPRequest *dfpBidRequest = [[DFPRequest alloc] init];
    dfpBidRequest.customTargeting = @{ @"key_1": @"object 1", @"key_2": @"object_2" };

    [self.bidManager addCriteoBidToRequest:dfpBidRequest forAdUnit:adUnit];

    NSDictionary *dfpTargeting = dfpBidRequest.customTargeting;
    XCTAssertGreaterThan(dfpTargeting.count, 2);
    XCTAssertNil([dfpTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advname"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advdomain"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advlogourl"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advurl"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_prtext"]);
    XCTAssertEqual(nativeBid.cpm, [dfpTargeting objectForKey:CR_BidManagerTestsCpm]);
    [self checkMandatoryNativeAssets:dfpBidRequest nativeBid:nativeBid];

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
