//
//  CR_BidManagerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <MoPub.h>
#import <OCMock.h>
#import "DFPRequestClasses.h"
#import "NSString+CR_Url.h"
#import "NSString+Testing.h"
#import "CR_BidManager.h"
#import "CR_BidManagerBuilder.h"
#import "CR_BidManagerBuilder+Testing.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DeviceInfoMock.h"
#import "pubsdkTests-Swift.h"

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
                        beforeCdbCall:[OCMArg any] \
                    completionHandler:[OCMArg any]]);

#define CR_OCMockRejectCallCdb(apiHandlerMock, adUnits) \
    OCMReject([apiHandlerMock callCdb:adUnits \
                              consent:[OCMArg any] \
                               config:[OCMArg any] \
                           deviceInfo:[OCMArg any] \
                        beforeCdbCall:[OCMArg any] \
                    completionHandler:[OCMArg any]]);

@interface CR_BidManagerTests : XCTestCase

@property (nonatomic, strong) NSMutableDictionary *mutableJsonDict;

@property (nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property (nonatomic, strong) CR_CdbBid *bid1;

@property (nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property (nonatomic, strong) CR_CdbBid *bid2;

@property (nonatomic, strong) CR_CacheAdUnit *adUnitForEmptyBid;
@property (nonatomic, strong) CR_CacheAdUnit *adUnitUncached;

@property (nonatomic, strong) DFPRequest *dfpRequest;

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

    CR_BidManagerBuilder *builder = [CR_BidManagerBuilder testing_bidManagerBuilder];
    builder.configManager = self.configManagerMock;
    builder.cacheManager = self.cacheManager;
    builder.apiHandler = self.apiHandlerMock;
    builder.deviceInfo = self.deviceInfoMock;

    self.builder = builder;
    self.bidManager = [builder buildBidManager];
    self.tokenCache = builder.tokenCache;

    self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1" width:300 height:250];
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;
    self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit2" width:200 height:100];
    self.bid2 = CR_CdbBidBuilder.new.adUnit(self.adUnit2).cpm(@"0.5").displayUrl(@"bid2.displayUrl").build;
    self.adUnitForEmptyBid = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitForEmptyBid" width:300 height:250];
    self.adUnitUncached = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitUncached" width:200 height:100];

    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
    self.cacheManager.bidCache[self.adUnit2] = self.bid2;
    self.cacheManager.bidCache[self.adUnitForEmptyBid] = [CR_CdbBid emptyBid];

    self.dfpRequest = [[DFPRequest alloc] init];
    self.dfpRequest.customTargeting = @{ @"key_1": @"object 1", @"key_2": @"object_2" };

    [self.builder.feedbackStorage popMessagesToSend];
}

- (void)tearDown {
    [self.builder.feedbackStorage popMessagesToSend];
}

- (void)testGetBidForCachedAdUnits {
    NSDictionary *bids = [self.bidManager getBids:@[self.adUnit1, self.adUnit2]];

    XCTAssertEqualObjects(self.bid1, bids[self.adUnit1]);
    XCTAssertEqualObjects(self.bid2, bids[self.adUnit2]);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit1]);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit2]);
}

- (void)testGetBidForUncachedAdUnit {
    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitUncached];

    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnitUncached]);
    XCTAssert(bid.isEmpty);
}

- (void)testGetEmptyBid {
    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitForEmptyBid];

    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnitForEmptyBid]);
    XCTAssert(bid.isEmpty);
}

- (void)testGetBidUncachedAdUnitInSilentMode {
    self.builder.timeToNextCall = INFINITY; // in silent mode
    self.bidManager = [self.builder buildBidManager];

    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[self.adUnitUncached]);

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitUncached];

    XCTAssert(bid.isEmpty);
}

- (void)testGetEmptyBidForAdUnitInSilentMode {
    self.builder.timeToNextCall = INFINITY; // in silent mode
    self.bidManager = [self.builder buildBidManager];

    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[self.adUnitForEmptyBid]);

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitForEmptyBid];

    XCTAssert(bid.isEmpty);
}


- (void)testRegistrationSetEmptyBid {
    [self.bidManager registerWithSlots:@[self.adUnitUncached]];

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitUncached];

    XCTAssert(bid.isEmpty);
}

- (void)testAddCriteoBidToMutableDictionary {
    NSMutableDictionary *biddableDictionary = [[NSMutableDictionary alloc] init];

    [self.bidManager addCriteoBidToRequest:biddableDictionary forAdUnit:self.adUnit1];

    XCTAssert(biddableDictionary.count == 2);
    XCTAssertEqualObjects(biddableDictionary[CR_BidManagerTestsDisplayUrl], self.bid1.displayUrl);
    XCTAssertEqualObjects(biddableDictionary[CR_BidManagerTestsCpm], self.bid1.cpm);
}

- (void)testAddCriteoBidToNonBiddableObjectsDoesNotCrash {
    [self.bidManager addCriteoBidToRequest:[NSDictionary new] forAdUnit:self.adUnit1];
    [self.bidManager addCriteoBidToRequest:[NSSet new] forAdUnit:self.adUnit1];
    [self.bidManager addCriteoBidToRequest:@"1234abcd" forAdUnit:self.adUnit1];
    [self.bidManager addCriteoBidToRequest:(NSMutableDictionary *)nil forAdUnit:self.adUnit1];
}

- (void)testAddCriteoBidToDifferentDfpRequestTypes {
#define CR_CheckRequest(requestType) \
{ \
    [self.cacheManager setBid:self.bid1]; \
    requestType *r = [requestType new]; \
    [self.bidManager addCriteoBidToRequest:r forAdUnit:self.adUnit1]; \
    XCTAssertTrue(r.customTargeting.count == 2); \
    XCTAssertEqualObjects(self.bid1.dfpCompatibleDisplayUrl, r.customTargeting[CR_BidManagerTestsDfpDisplayUrl]); \
    XCTAssertEqualObjects(self.bid1.cpm, r.customTargeting[CR_BidManagerTestsCpm]); \
}

    CR_CheckRequest(DFPRequest);
    CR_CheckRequest(DFPORequest);
    CR_CheckRequest(DFPNRequest);
    CR_CheckRequest(GADRequest);
    CR_CheckRequest(GADORequest);
    CR_CheckRequest(GADNRequest);

#undef CR_CheckRequest
}

- (void)testAddCriteoBidToMopubAdViewRequest {
    MPAdView *mopubBidRequest = [[MPAdView alloc] init];
    mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:self.adUnit1];

    XCTAssertTrue([mopubBidRequest.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:self.bid1.cpm]);
}

- (void)testLoadMopubInterstitial {
    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:self.adUnit1];
    [mopubBidRequest loadAd];

    XCTAssertFalse([mopubBidRequest.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:self.bid1.cpm]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:@"crt_"]);
}

- (void)testDuplicateEnrichment {
    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:self.adUnit1];
    XCTAssertTrue([mopubBidRequest.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:self.bid1.cpm]);

    [self.bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:self.adUnit2];
    XCTAssertFalse([mopubBidRequest.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:self.bid1.cpm]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:self.bid2.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:self.bid2.cpm]);

    NSUInteger displayUrlCount = [mopubBidRequest.keywords ocurrencesCountOfSubstring:self.bid2.mopubCompatibleDisplayUrl];
    NSUInteger cpmCount = [mopubBidRequest.keywords ocurrencesCountOfSubstring:self.bid2.cpm];
    NSUInteger crtCount = [mopubBidRequest.keywords ocurrencesCountOfSubstring:@"crt_"];
    XCTAssertEqual(displayUrlCount, 1);
    XCTAssertEqual(cpmCount, 1);
    XCTAssertEqual(crtCount, 2);
}

- (void)testConditionAddCriteoBidToMopubInterstitialAdController {
    MPInterstitialAdController *mpInterstitialAdController = [MPInterstitialAdController new];

    [self.bidManager addCriteoBidToRequest:mpInterstitialAdController forAdUnit:self.adUnit1];

    XCTAssertTrue([mpInterstitialAdController.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([mpInterstitialAdController.keywords containsString:self.bid1.cpm]);
}

- (void)testAddCriteoBidToRequestWhenKillSwitchIsEngagedShouldNotEnrichRequest {
    self.builder.config.killSwitch = YES;

    [self.bidManager addCriteoBidToRequest:self.dfpRequest forAdUnit:self.adUnit1];

    XCTAssertTrue(self.dfpRequest.customTargeting.count == 2);
    XCTAssertNil([self.dfpRequest.customTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertNil([self.dfpRequest.customTargeting objectForKey:CR_BidManagerTestsCpm]);
}

- (void)testGetBidWhenBeforeTtnc { // TTNC -> Time to next call
    self.builder.timeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:360] timeIntervalSinceReferenceDate];
    self.bidManager = [self.builder buildBidManager];
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
    self.cacheManager.bidCache[self.adUnit2] = self.bid2;

    CR_OCMockRejectCallCdb(self.apiHandlerMock, [OCMArg any]);

    NSDictionary *bids = [self.bidManager getBids:@[self.adUnit1, self.adUnit2, self.adUnitUncached]];

    XCTAssertEqualObjects(self.bid1, bids[self.adUnit1]);
    XCTAssertEqualObjects(self.bid2, bids[self.adUnit2]);
    XCTAssertTrue([bids[self.adUnitUncached] isEmpty]);
}

- (void)testGetBidForAdUnitInSilenceMode { // Silence mode = cpm ==0 && ttl > 0
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"0.0").ttl(42.0).build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[self.adUnit1]);

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssert(bid.isEmpty);
}

- (void)testGetBidForBidWithSilencedModeElapsed { // Silence mode = cpm ==0 && ttl > 0 && insertTime + ttl expired
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"0.0").ttl(42.0).expiredInsertTime().build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssert(bid.isEmpty);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit1]);
}

- (void)testBidResponseForEmptyBid {
    self.adUnitUncached = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                              size:CGSizeMake(320, 50)
                                                        adUnitType:CRAdUnitTypeBanner];

    CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:self.adUnitUncached
                                                                 adUnitType:CRAdUnitTypeBanner];

    XCTAssertEqualWithAccuracy(bidResponse.price, 0.0f, 0.1);
    XCTAssertNil(bidResponse.bidToken);
    XCTAssertFalse(bidResponse.bidSuccess);
}

- (void)testBidResponseForValidBid {
    self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                       size:CGSizeMake(320, 50)
                                                 adUnitType:CRAdUnitTypeBanner];
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"4.2").build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:self.adUnit1
                                                                 adUnitType:CRAdUnitTypeBanner];

    XCTAssertEqualWithAccuracy(bidResponse.price, 4.2, 0.1);
    XCTAssert(bidResponse.bidSuccess);
}

- (void)testGetBidWhenNoBid { // No bid: cpm == 0 && ttl == 0
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"0.0").ttl(0).build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssertTrue(bid.isEmpty);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit1]);
}

- (void)testGetBidWhenBidExpired {
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expiredInsertTime().build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssertTrue(bid.isEmpty);
}

- (void)testAddCriteoNativeBidToDfpRequest {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict receivedAt:[NSDate date]];
    [self.cacheManager setBid:nativeBid];

    [self.bidManager addCriteoBidToRequest:self.dfpRequest forAdUnit:adUnit];

    CR_NativeAssets *nativeAssets = nativeBid.nativeAssets;
    NSDictionary *dfpTargeting = self.dfpRequest.customTargeting;
    XCTAssertTrue(dfpTargeting.count > 2);
    XCTAssertNil([dfpTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertEqual(nativeBid.cpm, dfpTargeting[CR_BidManagerTestsCpm]);
    [self _checkMandatoryNativeAssets:self.dfpRequest nativeBid:nativeBid];
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

    [self.bidManager addCriteoBidToRequest:self.dfpRequest forAdUnit:adUnit];

    NSDictionary *dfpTargeting = self.dfpRequest.customTargeting;
    XCTAssertGreaterThan(dfpTargeting.count, 2);
    XCTAssertNil([dfpTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advname"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advdomain"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advlogourl"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advurl"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_prtext"]);
    XCTAssertEqual(nativeBid.cpm, [dfpTargeting objectForKey:CR_BidManagerTestsCpm]);
    [self _checkMandatoryNativeAssets:self.dfpRequest nativeBid:nativeBid];

}

- (void)testInitDoNotRefreshConfiguration {
    OCMReject([self.configManagerMock refreshConfig:[OCMArg any]]);
}

- (void)testSlotRegistrationRefreshConfiguration {
    [self.bidManager registerWithSlots:@[self.adUnitUncached]];

    OCMVerify([self.configManagerMock refreshConfig:[OCMArg any]]);
}

#pragma mark - Private

- (void)_checkMandatoryNativeAssets:(DFPRequest *)dfpBidRequest nativeBid:(CR_CdbBid *)nativeBid {
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
