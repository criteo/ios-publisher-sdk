//
//  CR_HeaderBiddingTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <MoPub.h>
#import <XCTest/XCTest.h>

#import "DFPRequestClasses.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbBidBuilder.h"
#import "CR_CdbBid.h"
#import "CR_HeaderBidding.h"
#import "NSString+Testing.h"
#import "NSString+CR_Url.h"

static NSString * const kCpmKey = @"crt_cpm";
static NSString * const kDictionaryDisplayUrlKey = @"crt_displayUrl";
static NSString * const kDfpDisplayUrlKey = @"crt_displayurl";

#define CR_AssertEqualDfpString(notDfpStr, dfpStr) \
    XCTAssertEqualObjects([NSString dfpCompatibleString:notDfpStr], dfpStr);

@interface CR_HeaderBiddingTests : XCTestCase

@property (strong, nonatomic) CR_HeaderBidding *headerBidding;

@property (nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property (nonatomic, strong) CR_CdbBid *bid1;

@property (nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property (nonatomic, strong) CR_CdbBid *bid2;

@property (nonatomic, strong) NSMutableDictionary *mutableJsonDict;
@property (nonatomic, strong) DFPRequest *dfpRequest;

@end

@implementation CR_HeaderBiddingTests

- (void)setUp {
    self.headerBidding = [[CR_HeaderBidding alloc] init];

    self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1"
                                                      width:300
                                                     height:250];
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;

    self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit2"
                                                      width:200
                                                     height:100];
    self.bid2 = CR_CdbBidBuilder.new.adUnit(self.adUnit2)
                                    .cpm(@"0.5")
                                    .displayUrl(@"bid2.displayUrl")
                                    .build;

    self.dfpRequest = [[DFPRequest alloc] init];
    self.dfpRequest.customTargeting = @{ @"key_1": @"object 1", @"key_2": @"object_2" };

    self.mutableJsonDict = [self loadSlotDictionary];
}

#pragma mark - Dictionary

- (void)testMutableDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    [self.headerBidding enrichRequest:dictionary
                              withBid:self.bid1
                               adUnit:self.adUnit1];

    XCTAssert(dictionary.count == 2);
    XCTAssertEqualObjects(dictionary[kDictionaryDisplayUrlKey], self.bid1.displayUrl);
    XCTAssertEqualObjects(dictionary[kCpmKey], self.bid1.cpm);
}


#pragma mark - Google Ad

- (void)testGADRequest {
    GADRequest *request = [[GADRequest alloc] init];

    [self.headerBidding enrichRequest:request
                              withBid:self.bid1
                               adUnit:self.adUnit1];

    NSDictionary *targeting = request.customTargeting;
    XCTAssertTrue(request.customTargeting.count == 2);
    XCTAssertEqualObjects(self.bid1.dfpCompatibleDisplayUrl, targeting[kDfpDisplayUrlKey]);
    XCTAssertEqualObjects(self.bid1.cpm, targeting[kCpmKey]);
}

- (void)testDfpRequest {
    DFPRequest *request = [[DFPRequest alloc] init];

    [self.headerBidding enrichRequest:request
                              withBid:self.bid1
                               adUnit:self.adUnit1];

    NSDictionary *targeting = request.customTargeting;
    XCTAssertTrue(request.customTargeting.count == 2);
    XCTAssertEqualObjects(self.bid1.dfpCompatibleDisplayUrl, targeting[kDfpDisplayUrlKey]);
    XCTAssertEqualObjects(self.bid1.cpm, targeting[kCpmKey]);
}

- (void)testDfpRequestWithNativeBid {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict
                                                receivedAt:[NSDate date]];

    [self.headerBidding enrichRequest:self.dfpRequest
                              withBid:nativeBid
                               adUnit:adUnit];

    CR_NativeAssets *nativeAssets = nativeBid.nativeAssets;
    NSDictionary *dfpTargeting = self.dfpRequest.customTargeting;
    XCTAssertTrue(dfpTargeting.count > 2);
    XCTAssertNil([dfpTargeting objectForKey:kDfpDisplayUrlKey]);
    XCTAssertEqual(nativeBid.cpm, dfpTargeting[kCpmKey]);
    [self checkMandatoryNativeAssets:self.dfpRequest
                           nativeBid:nativeBid];
    CR_AssertEqualDfpString(nativeAssets.advertiser.description, dfpTargeting[@"crtn_advname"]);
    CR_AssertEqualDfpString(nativeAssets.advertiser.domain, dfpTargeting[@"crtn_advdomain"]);
    CR_AssertEqualDfpString(nativeAssets.advertiser.logoImage.url, dfpTargeting[@"crtn_advlogourl"]);
    CR_AssertEqualDfpString(nativeAssets.advertiser.logoClickUrl, dfpTargeting[@"crtn_advurl"]);
    CR_AssertEqualDfpString(nativeAssets.privacy.longLegalText, dfpTargeting[@"crtn_prtext"]);
}

- (void)testAddCriteoToDfpRequestForInCompleteNativeBid {
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    self.mutableJsonDict[@"native"][@"advertiser"][@"description"] = @"";
    self.mutableJsonDict[@"native"][@"advertiser"][@"domain"] = @"";
    self.mutableJsonDict[@"native"][@"advertiser"][@"logo"][@"url"] = nil;
    self.mutableJsonDict[@"native"][@"advertiser"][@"logoClickUrl"] = @"";
    self.mutableJsonDict[@"native"][@"privacy"][@"longLegalText"] = nil;
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict
                                                receivedAt:[NSDate date]];

    [self.headerBidding enrichRequest:self.dfpRequest
                              withBid:nativeBid
                               adUnit:adUnit];

    NSDictionary *dfpTargeting = self.dfpRequest.customTargeting;
    XCTAssertGreaterThan(dfpTargeting.count, 2);
    XCTAssertNil([dfpTargeting objectForKey:kDfpDisplayUrlKey]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advname"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advdomain"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advlogourl"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_advurl"]);
    XCTAssertNil([dfpTargeting objectForKey:@"crtn_prtext"]);
    XCTAssertEqual(nativeBid.cpm, [dfpTargeting objectForKey:kCpmKey]);
    [self checkMandatoryNativeAssets:self.dfpRequest
                           nativeBid:nativeBid];
}

#pragma mark - Mopub

- (void)testMPInterstitialAdController {
    MPInterstitialAdController *controller = [MPInterstitialAdController new];

    [self.headerBidding enrichRequest:controller
                              withBid:self.bid1
                               adUnit:self.adUnit1];

    XCTAssertTrue([controller.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([controller.keywords containsString:self.bid1.cpm]);
}


- (void)testMPAdView {
    MPAdView *request = [[MPAdView alloc] init];
    request.keywords = @"key1:object_1,key_2:object_2";

    [self.headerBidding enrichRequest:request
                              withBid:self.bid1
                               adUnit:self.adUnit1];

    XCTAssertTrue([request.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([request.keywords containsString:self.bid1.cpm]);
}

- (void)testLoadMopubInterstitial {
    MPInterstitialAdController *request = [[MPInterstitialAdController alloc] init];
    request.keywords = @"key1:object_1,key_2:object_2";

    [self.headerBidding enrichRequest:request
                              withBid:self.bid1
                               adUnit:self.adUnit1];
    [request loadAd];

    XCTAssertFalse([request.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertFalse([request.keywords containsString:self.bid1.cpm]);
    XCTAssertFalse([request.keywords containsString:@"crt_"]);
}

- (void)testDuplicateEnrichment {
    MPInterstitialAdController *request = [[MPInterstitialAdController alloc] init];
    request.keywords = @"key1:object_1,key_2:object_2";

    [self.headerBidding enrichRequest:request
                              withBid:self.bid1
                               adUnit:self.adUnit1];
    XCTAssertTrue([request.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([request.keywords containsString:self.bid1.cpm]);

    [self.headerBidding enrichRequest:request
                              withBid:self.bid2
                               adUnit:self.adUnit2];
    XCTAssertFalse([request.keywords containsString:self.bid1.mopubCompatibleDisplayUrl]);
    XCTAssertFalse([request.keywords containsString:self.bid1.cpm]);
    XCTAssertTrue([request.keywords containsString:self.bid2.mopubCompatibleDisplayUrl]);
    XCTAssertTrue([request.keywords containsString:self.bid2.cpm]);

    NSUInteger displayUrlCount = [request.keywords ocurrencesCountOfSubstring:self.bid2.mopubCompatibleDisplayUrl];
    NSUInteger cpmCount = [request.keywords ocurrencesCountOfSubstring:self.bid2.cpm];
    NSUInteger crtCount = [request.keywords ocurrencesCountOfSubstring:@"crt_"];
    XCTAssertEqual(displayUrlCount, 1);
    XCTAssertEqual(cpmCount, 1);
    XCTAssertEqual(crtCount, 2);
}

#pragma mark - Private

- (void)checkMandatoryNativeAssets:(DFPRequest *)dfpBidRequest
                         nativeBid:(CR_CdbBid *)nativeBid {
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

- (NSMutableDictionary *)loadSlotDictionary {
    NSMutableDictionary *responseDict = [self loadSampleBidJson][@"slots"][0];
    XCTAssert(responseDict);
    return responseDict;
}

- (NSMutableDictionary *)loadSampleBidJson {
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

@end
