//
//  CR_CbdBidTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NSDictionary+Criteo.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbBid.h"
#import "CR_CdbBidBuilder.h"
#import "CR_NativeAssets.h"

@interface CR_CdbBidTests : XCTestCase

@property (strong) NSDictionary *nativeJDict;
@property (strong) NSDictionary *bannerJDict;
@property (strong) NSData *jsonData;
@property (strong, nonatomic) CR_CacheAdUnit *adUnit;
@property (strong) CR_CdbBid *nativeBid1;
@property (strong) CR_CdbBid *nativeBid2;
@property (strong) CR_CdbBid *bannerBid;
@property (strong) NSDate *now;

@end

@implementation CR_CdbBidTests

- (void)setUp {
    NSError *e = nil;
    self.now = [NSDate date];
    self.adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1"
                                                     width:300
                                                    height:250];

    NSURL *jsonURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"SampleBid" withExtension:@"json"];

    NSString *jsonText = [NSString stringWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&e];
    if (e) { XCTFail(@"%@", e); }

    self.jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    if (e) { XCTFail(@"%@", e); }

    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:self.jsonData options:0 error:&e];
    if (e) { XCTFail(@"%@", e); }
    self.nativeJDict = responseDict[@"slots"][0];
    self.bannerJDict = responseDict[@"slots"][2];
    XCTAssertNotNil(self.nativeJDict);
    XCTAssertNotNil(self.bannerJDict);

    NSArray<CR_CdbBid *> *bids = [CR_CdbBid getCdbResponsesForData:self.jsonData receivedAt:self.now];
    XCTAssertEqual(bids.count, 3);
    self.nativeBid1 = bids[0];
    XCTAssertNotNil(self.nativeBid1);
    self.nativeBid2 = bids[1];
    XCTAssertNotNil(self.nativeBid2);
    self.bannerBid = bids[2];
    XCTAssertNotNil(self.bannerBid);
}

- (BOOL)testHashAndIsEqualForUnequalObjects:(NSDictionary *)dict key:(id)key modValue:(id)modValue {
    NSDictionary *modDict      = [dict dictionaryWithNewValue:modValue forKey:key];
    NSDictionary *dictWithNil1 = [dict dictionaryWithNewValue:nil forKey:key];
    NSDictionary *dictWithNil2 = [dict dictionaryWithNewValue:nil forKey:key];

    CR_CdbBid *bid         = [[CR_CdbBid alloc] initWithDict:dict receivedAt:self.now];
    CR_CdbBid *modBid      = [[CR_CdbBid alloc] initWithDict:modDict receivedAt:self.now];
    CR_CdbBid *bidNewTime1 = [[CR_CdbBid alloc] initWithDict:dict
                                                      receivedAt:[self.now dateByAddingTimeInterval:50000]];
    CR_CdbBid *bidNewTime2 = [[CR_CdbBid alloc] initWithDict:dict
                                                      receivedAt:[self.now dateByAddingTimeInterval:50000]];
    CR_CdbBid *bidWithNil1 = [[CR_CdbBid alloc] initWithDict:dictWithNil1 receivedAt:self.now];
    CR_CdbBid *bidWithNil2 = [[CR_CdbBid alloc] initWithDict:dictWithNil2 receivedAt:self.now];

    XCTAssertNotEqual(bid.hash,         modBid.hash);
    XCTAssertNotEqual(bid.hash,         bidWithNil1.hash);
    XCTAssertEqual(   bidWithNil1.hash, bidWithNil2.hash);
    XCTAssertNotEqual(bid.hash,         bidNewTime1.hash);
    XCTAssertEqual(   bidNewTime1.hash, bidNewTime2.hash);

    XCTAssertFalse([bid         isEqual:modBid]);
    XCTAssertFalse([modBid      isEqual:bid]);
    XCTAssertFalse([bid         isEqual:bidWithNil1]);
    XCTAssertFalse([bidWithNil1 isEqual:bid]);
    XCTAssertTrue( [bidWithNil1 isEqual:bidWithNil2]);
    XCTAssertTrue( [bidWithNil2 isEqual:bidWithNil1]);
    XCTAssertFalse([bid         isEqual:bidNewTime1]);
    XCTAssertFalse([bidNewTime1 isEqual:bid]);
    XCTAssertTrue( [bidNewTime1 isEqual:bidNewTime2]);
    XCTAssertTrue( [bidNewTime2 isEqual:bidNewTime1]);

    XCTAssertNotEqualObjects(bid,         modBid);
    XCTAssertNotEqualObjects(modBid,      bid);
    XCTAssertNotEqualObjects(bid,         bidWithNil1);
    XCTAssertNotEqualObjects(bidWithNil1, bid);
    XCTAssertEqualObjects(   bidWithNil1, bidWithNil2);
    XCTAssertEqualObjects(   bidWithNil2, bidWithNil1);
    XCTAssertNotEqualObjects(bid,         bidNewTime1);
    XCTAssertNotEqualObjects(bidNewTime1, bid);
    XCTAssertEqualObjects(   bidNewTime1, bidNewTime2);
    XCTAssertEqualObjects(   bidNewTime2, bidNewTime1);

    XCTAssertNotEqualObjects(bid,         nil);
    XCTAssertNotEqualObjects(bid,         @"astring");
}

- (void)testInitialization {
    NSDate *now = [NSDate date];
    CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.nativeJDict receivedAt:now];

    XCTAssertEqualObjects(nativeBid.impressionId, @"5e5e5b205829c327e17bcce3c8b8f7fd");
    XCTAssertEqualObjects(nativeBid.placementId, @"/140800857/Endeavour_Native");
    XCTAssertEqualObjects(nativeBid.cpm, @"0.04");
    XCTAssertEqualObjects(nativeBid.currency, @"USD");
    XCTAssertEqualObjects(self.bannerBid.displayUrl, @"https://rdi.us.criteo.com/delivery/r/ajs");
    XCTAssertEqualObjects(nativeBid.width, @(2));
    XCTAssertEqualObjects(nativeBid.height, @(2));
    XCTAssertEqual(nativeBid.ttl, 3600);

    XCTAssertEqualObjects(nativeBid.nativeAssets.products[0].title, @"\"Stripe Pima Dress\" - $99");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[0].description, @"We're All About Comfort.");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[0].price, @"$99");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[0].clickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn.php?");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[0].callToAction, @"scipio");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[0].image.url, @"https://pix.us.criteo.net/img/img?");
    XCTAssertEqual(nativeBid.nativeAssets.products[0].image.width, 502);
    XCTAssertEqual(nativeBid.nativeAssets.products[0].image.height, 501);

    XCTAssertEqualObjects(nativeBid.nativeAssets.products[1].title, @"\"Just a Dress\" - $9999");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[1].description, @"We're NOT About Comfort.");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[1].price, @"$9999");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[1].clickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn2.php?");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[1].callToAction, @"Buy this blinkin dress");
    XCTAssertEqualObjects(nativeBid.nativeAssets.products[1].image.url, @"https://pix.us.criteo.net/img/img2?");
    XCTAssertEqual(nativeBid.nativeAssets.products[1].image.width, 402);
    XCTAssertEqual(nativeBid.nativeAssets.products[1].image.height, 401);

    XCTAssertEqualObjects(nativeBid.nativeAssets.advertiser.description, @"The Company Store");
    XCTAssertEqualObjects(nativeBid.nativeAssets.advertiser.domain, @"thecompanystore.com");
    XCTAssertEqualObjects(nativeBid.nativeAssets.advertiser.logoClickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn.php?");
    XCTAssertEqualObjects(nativeBid.nativeAssets.advertiser.logoImage.url, @"https://pix.us.criteo.net/img/img?");
    XCTAssertEqual(nativeBid.nativeAssets.advertiser.logoImage.width, 300);
    XCTAssertEqual(nativeBid.nativeAssets.advertiser.logoImage.height, 200);

    XCTAssertEqualObjects(nativeBid.nativeAssets.privacy.optoutClickUrl, @"https://privacy.us.criteo.com/adcenter?");
    XCTAssertEqualObjects(nativeBid.nativeAssets.privacy.optoutImageUrl, @"https://static.criteo.net/flash/icon/nai_small.png");
    XCTAssertEqualObjects(nativeBid.nativeAssets.privacy.longLegalText, @"Blah blah blah");

    XCTAssertEqualObjects(nativeBid.nativeAssets.impressionPixels[0], @"https://cat.sv.us.criteo.com/delivery/lgn.php?");
    XCTAssertEqualObjects(nativeBid.nativeAssets.impressionPixels[1], @"https://cat.sv.us.criteo.com/delivery2/lgn.php?");
}

- (void)testEmptyInitialization {
    CR_CdbBid *bid = [[CR_CdbBid alloc] initWithDict:[NSDictionary new] receivedAt:self.now];
    XCTAssertNil(bid.placementId);
    XCTAssertNil(bid.zoneId);
    XCTAssertNil(bid.cpm);
    XCTAssertNil(bid.currency);
    XCTAssertNil(bid.width);
    XCTAssertNil(bid.height);
    XCTAssertEqual(bid.ttl, 900);
    XCTAssertNil(bid.creative);
    XCTAssertNil(bid.displayUrl);
    XCTAssertNil(bid.dfpCompatibleDisplayUrl);
    XCTAssertNil(bid.mopubCompatibleDisplayUrl);
    XCTAssertNil(bid.nativeAssets);
    XCTAssertNil(bid.impressionId);
 }

- (void)testNilInitialization {
    CR_CdbBid *bid = [[CR_CdbBid alloc] initWithDict:nil receivedAt:self.now];
    XCTAssertNil(bid.placementId);
    XCTAssertNil(bid.zoneId);
    XCTAssertNil(bid.cpm);
    XCTAssertNil(bid.currency);
    XCTAssertNil(bid.width);
    XCTAssertNil(bid.height);
    XCTAssertEqual(bid.ttl, 900);
    XCTAssertNil(bid.creative);
    XCTAssertNil(bid.displayUrl);
    XCTAssertNil(bid.dfpCompatibleDisplayUrl);
    XCTAssertNil(bid.mopubCompatibleDisplayUrl);
    XCTAssertNil(bid.nativeAssets);
    XCTAssertNil(bid.impressionId);
}

- (void)testHashEquality {
    XCTAssertEqual(self.nativeBid1.hash, self.nativeBid2.hash);
}

- (void)testIsEqualTrue {
    XCTAssertEqualObjects(self.nativeBid1, self.nativeBid1);
    XCTAssertEqualObjects(self.nativeBid1, self.nativeBid2);
    XCTAssertEqualObjects(self.nativeBid2, self.nativeBid1);
}

- (void)testUnequalObjects {
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"impId" modValue:@"rndval"];
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"placementId" modValue:@"baerf"];
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"cpm" modValue:@"crud"];
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"currency" modValue:@"sdfgasdf"];
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"width" modValue:@(23455)];
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"height" modValue:@(111234)];
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"ttl" modValue:@(2346578)];
    [self testHashAndIsEqualForUnequalObjects:self.bannerJDict key:@"displayUrl" modValue:@"rfdcb54x"];
    NSMutableDictionary *modAssetsDict = [[NSMutableDictionary alloc] initWithDictionary:self.nativeJDict[@"native"]];
    modAssetsDict[@"privacy"] = nil;
    [self testHashAndIsEqualForUnequalObjects:self.nativeJDict key:@"native" modValue:modAssetsDict];
}

- (void)testCopy {
    CR_CdbBid *bid1Copy = [self.nativeBid1 copy];
    XCTAssertNotNil(bid1Copy);
    XCTAssertFalse(self.nativeBid1 == bid1Copy);
    XCTAssertEqualObjects(self.nativeBid1, bid1Copy);

    CR_CdbBid *bid2Copy = [self.nativeBid2 copy];
    XCTAssertNotNil(bid2Copy);
    XCTAssertEqualObjects(bid1Copy, bid2Copy);

    CR_CdbBid *bid3Copy = [self.bannerBid copy];
    XCTAssertNotNil(bid3Copy);
    XCTAssertEqualObjects(self.bannerBid, bid3Copy);
}

- (void) testCdbResponsesForData {
    // Bid Objects
    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_2"
                                                         cpm:@"5.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];


    CR_CdbBid *testBid_3 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_3"
                                                         cpm:@"5.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];


    CR_CdbBid *testBid_4 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_4"
                                                         cpm:nil currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];


    // Json response from CDB
    // The cpm is a number
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":5.12,\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_3\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_4\",\"zoneId\": 497747,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";

    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *testBids = [CR_CdbBid getCdbResponsesForData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(testBids);
    XCTAssertEqual(4, [testBids count]);
    XCTAssertTrue([testBid_1 isEqual:testBids[0]]);
    // the json response is missing ttl
    XCTAssertFalse([testBid_2 isEqual:testBids[1]]);
    // the creative string is mismatched
    XCTAssertFalse([testBid_3 isEqual:testBids[2]]);
    // missing cpm
    XCTAssertFalse([testBid_4 isEqual:testBids[3]]);
}

- (void) testCdbResponsesForDataWhenCpmIsAString {
    // Bid Objects
    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];


    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_2"
                                                         cpm:@"5.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];


    CR_CdbBid *testBid_3 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_3"
                                                         cpm:@"5.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    CR_CdbBid *testBid_4 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_4"
                                                         cpm:nil currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    // Json response from CDB
    // The CPM is a string
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":\"1.12\",\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":\"5.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_3\",\"zoneId\": 497747,\"cpm\":\"1.12\",\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_4\",\"zoneId\": 497747,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *testBids = [CR_CdbBid getCdbResponsesForData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(testBids);
    XCTAssertEqual(4, [testBids count]);
    XCTAssertTrue([testBid_1 isEqual:testBids[0]]);
    // the json response is missing ttl
    XCTAssertFalse([testBid_2 isEqual:testBids[1]]);
    // the creative string is mismatched
    XCTAssertFalse([testBid_3 isEqual:testBids[2]]);
    // missing cpm
    XCTAssertFalse([testBid_4 isEqual:testBids[3]]);
}

- (CR_CdbBid*) testBidWithTTL:(NSTimeInterval)ttl insertTimeDiff:(NSTimeInterval)diff
{
    return [[CR_CdbBid alloc] initWithZoneId:nil
                                 placementId:@"a_test_placement"
                                         cpm:@"0.0312"
                                    currency:@"USD"
                                       width:@(300)
                                      height:@(200)
                                         ttl:ttl
                                    creative:nil
                                  displayUrl:@"https://someUrl.com"
                                  insertTime:[NSDate dateWithTimeIntervalSinceNow:diff]
                                nativeAssets:nil
                                impressionId:nil];

}


- (void) testBidIsExpired {
    CR_CdbBid *testBid = [self testBidWithTTL:200 insertTimeDiff:-400];
    XCTAssertTrue(testBid.isExpired);
}

- (void) testTtlLTEZeroIsAlwaysExpired {
    CR_CdbBid *testBid = [self testBidWithTTL:0 insertTimeDiff:0];
    XCTAssertTrue(testBid.isExpired);

    CR_CdbBid *testBid2 = [self testBidWithTTL:0 insertTimeDiff:-100];
    XCTAssertTrue(testBid2.isExpired);

    CR_CdbBid *testBid3 = [self testBidWithTTL:0 insertTimeDiff:100];
    XCTAssertTrue(testBid3.isExpired);

    CR_CdbBid *testBid4 = [self testBidWithTTL:-100 insertTimeDiff:0];
    XCTAssertTrue(testBid4.isExpired);

    CR_CdbBid *testBid5 = [self testBidWithTTL:-100 insertTimeDiff:-100];
    XCTAssertTrue(testBid5.isExpired);

    CR_CdbBid *testBid6 = [self testBidWithTTL:-100 insertTimeDiff:100];
    XCTAssertTrue(testBid6.isExpired);
}

- (void) testBidIsNotExpired {
    CR_CdbBid *testBid = [self testBidWithTTL:200 insertTimeDiff:-100];
    XCTAssertFalse(testBid.isExpired);
}

- (void) testDfpCompatibleUrlIsDoubleUrlEncodedBase64
{
    NSString *displayUrl = @"https://ads.us.criteo.com/delivery/r/ajs.php?did=5c560a19383b7ad93bb37508deb03a00&u=%7CHX1eM0zpPitVbf0xT24vaM6U4AiY1TeYgfjDUVVbdu4%3D%7C&c1=eG9IAZIK2MKnlif_A3VZ1-8PEx5_bFVofQVrPPiKhda8JkCsKWBsD2zYvC_F9owWsiKQANPjzJs2iM3m5bCHei3w1zNKxtB3Cx_TBleNKtL5VK1aqyK68XTa0A43qlwLNaStT5NXB3Mz7kx6fDZ20Rh6eAGAW2F9SXVN_7xiLgP288-4OqtK-R7pziZDS04LRUhkL7ohLmAFFyVuwQTREHbpx-4NoonsiQRHKn7ZkuIqZR_rqEewHQ2YowxbI3EOowxo6OV50faWCc7QO5M388FHv8NxeOgOH03LHZT_a2PEKF1xh0-G_qdu5wiyGjJYyPEoNVxB0OaEnDaFVtM7cVaHDm4jrjKlfFhtIGuJb8mg2EeHN0mhUL_0eyv9xWUUQ6osYh3B-jiawHq4592kDDCpS2kYYeqR073IOoRNFNRCR7Fnl0yhIA";

    NSString *doubleUrlEncodedBase64DisplayUrl = @"aHR0cHM6Ly9hZHMudXMuY3JpdGVvLmNvbS9kZWxpdmVyeS9yL2Fqcy5waHA%252FZGlkPTVjNTYwYTE5MzgzYjdhZDkzYmIzNzUwOGRlYjAzYTAwJnU9JTdDSFgxZU0wenBQaXRWYmYweFQyNHZhTTZVNEFpWTFUZVlnZmpEVVZWYmR1NCUzRCU3QyZjMT1lRzlJQVpJSzJNS25saWZfQTNWWjEtOFBFeDVfYkZWb2ZRVnJQUGlLaGRhOEprQ3NLV0JzRDJ6WXZDX0Y5b3dXc2lLUUFOUGp6SnMyaU0zbTViQ0hlaTN3MXpOS3h0QjNDeF9UQmxlTkt0TDVWSzFhcXlLNjhYVGEwQTQzcWx3TE5hU3RUNU5YQjNNejdreDZmRFoyMFJoNmVBR0FXMkY5U1hWTl83eGlMZ1AyODgtNE9xdEstUjdwemlaRFMwNExSVWhrTDdvaExtQUZGeVZ1d1FUUkVIYnB4LTROb29uc2lRUkhLbjdaa3VJcVpSX3JxRWV3SFEyWW93eGJJM0VPb3d4bzZPVjUwZmFXQ2M3UU81TTM4OEZIdjhOeGVPZ09IMDNMSFpUX2EyUEVLRjF4aDAtR19xZHU1d2l5R2pKWXlQRW9OVnhCME9hRW5EYUZWdE03Y1ZhSERtNGpyaktsZkZodElHdUpiOG1nMkVlSE4wbWhVTF8wZXl2OXhXVVVRNm9zWWgzQi1qaWF3SHE0NTkya0REQ3BTMmtZWWVxUjA3M0lPb1JORk5SQ1I3Rm5sMHloSUE%253D";

    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil
                                               placementId:nil
                                                       cpm:nil
                                                  currency:nil
                                                     width:nil
                                                    height:nil
                                                       ttl:0.0
                                                  creative:nil
                                                displayUrl:displayUrl
                                                insertTime:nil
                                              nativeAssets:nil
                                              impressionId:nil];

    XCTAssertEqualObjects(displayUrl, testBid.displayUrl, @"displayUrl property should not alter displayUrl");
    XCTAssertEqualObjects(doubleUrlEncodedBase64DisplayUrl, testBid.dfpCompatibleDisplayUrl, @"dfpCompatibleDisplayUrl property is not a properly encoded version of displayUrl");
}

- (void) testCdbResponsesForDataForBidCachingCases {
    // Bid Objects
    NSDate *testDate = [NSDate date];
    //case when no bid : cpm = 0 and ttl = 0
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_1"
                                                         cpm:@"0"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:0
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    //case when silent mode : cpm = 0 and ttl > 0
    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_2"
                                                         cpm:@"0"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:900
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    //case when bid : cpm > 0 and ttl = 0, but ttl set to 900
    CR_CdbBid *testBid_3 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_3"
                                                         cpm:@"1.2"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:900
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    //case when bid caching : cpm > 0 and ttl > 0
    CR_CdbBid *testBid_4 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_4"
                                                         cpm:@"1.2"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:700
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    // Json response from CDB
    // The cpm is a number
    NSString *rawJsonCdbResponse =
    @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":0,\"currency\":\"EUR\", \"ttl\":0, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 497747,\"cpm\":0,\"currency\":\"EUR\", \"ttl\":900, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"},\
    {\"placementId\": \"adunitid_3\",\"zoneId\": 497747,\"cpm\":1.2,\"currency\":\"EUR\", \"ttl\":0, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"},\
    {\"placementId\": \"adunitid_4\",\"zoneId\": 497747,\"cpm\":1.2,\"currency\":\"EUR\", \"ttl\":700, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"}]}";

    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *testBids = [CR_CdbBid getCdbResponsesForData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(testBids);
    XCTAssertEqual(4, [testBids count]);
    XCTAssertTrue([testBid_1 isEqual:testBids[0]]);
    // the json response is missing ttl
    XCTAssertTrue([testBid_2 isEqual:testBids[1]]);
    // the creative string is mismatched
    XCTAssertTrue([testBid_3 isEqual:testBids[2]]);
    // missing cpm
    XCTAssertTrue([testBid_4 isEqual:testBids[3]]);
}

- (void)testValidBid {
    XCTAssertTrue(self.nativeBid1.isValid);
    XCTAssertTrue(self.nativeBid2.isValid);
    XCTAssertTrue(self.bannerBid.isValid);
}

- (NSMutableDictionary *)createMutableDictionaryFromJSONFileWithNative:(BOOL)isNative {
    NSError *e = nil;
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:self.jsonData options:NSJSONReadingMutableContainers error:&e];
    return isNative ? responseDict[@"slots"][0] : responseDict[@"slots"][2];
}

- (void)testBidWithInvalidValue:(id)value forKey:(NSString *)key {
    NSMutableDictionary *mutableDict = [self createMutableDictionaryFromJSONFileWithNative:NO];
    mutableDict[key] = value;
    CR_CdbBid *bid = [[CR_CdbBid alloc] initWithDict:mutableDict receivedAt:self.now];
    XCTAssertFalse(bid.isValid, @"Test failed for key: %@ value:%@", key, value);
}

- (void)testInvalidBidForCpmAndDisplayUrl {
    [self testBidWithInvalidValue:@"-0.3" forKey:@"cpm"];
    [self testBidWithInvalidValue:@"" forKey:@"displayUrl"];
    [self testBidWithInvalidValue:nil forKey:@"cpm"];
    [self testBidWithInvalidValue:nil forKey:@"displayUrl"];
    [self testBidWithInvalidValue:@(1) forKey:@"displayUrl"];
    [self testBidWithInvalidValue:@"hey" forKey:@"cpm"];
    [self testBidWithInvalidValue:@"test###$" forKey:@"cpm"];
    [self testBidWithInvalidValue:@"" forKey:@"cpm"];
}

- (void)testBidWithValidValue:(id)value forKey:(NSString *)key {
    NSMutableDictionary *mutableDict = [self createMutableDictionaryFromJSONFileWithNative:NO];
    mutableDict[key] = value;
    CR_CdbBid *bid = [[CR_CdbBid alloc] initWithDict:mutableDict receivedAt:self.now];
    XCTAssertTrue(bid.isValid, @"Test failed for key: %@ value:%@", key, value);
}

- (void)testValidBidForCpmAndDisplayURL {
    [self testBidWithValidValue:@"0.0001" forKey:@"cpm"];
    [self testBidWithValidValue:@"0.000" forKey:@"cpm"];
    [self testBidWithValidValue:@"3.200" forKey:@"cpm"];
    [self testBidWithValidValue:@(3.2) forKey:@"cpm"];
    [self testBidWithValidValue:@(3) forKey:@"cpm"];
    [self testBidWithValidValue:@"3" forKey:@"cpm"];
    [self testBidWithValidValue:@"TestDisplayUrl" forKey:@"displayUrl"];
}

- (void)testInvalidBidForNative {
    NSMutableArray <NSMutableDictionary *> *mutableDict = [NSMutableArray new];
    for(int i = 0; i < 11; i++) {
        [mutableDict addObject:[self createMutableDictionaryFromJSONFileWithNative:YES]];
    }

    mutableDict[0][@"native"][@"products"] = nil;
    mutableDict[1][@"native"][@"privacy"] = nil;
    mutableDict[2][@"native"][@"impressionPixels"] = nil;
    mutableDict[3][@"native"][@"privacy"][@"optoutClickUrl"] = nil;
    mutableDict[4][@"native"][@"privacy"][@"optoutImageUrl"] = nil;
    mutableDict[5][@"native"][@"products"] = @[];
    mutableDict[6][@"native"][@"impressionPixels"] = @[];
    mutableDict[7][@"native"][@"privacy"][@"optoutClickUrl"] = @"";
    mutableDict[8][@"native"][@"privacy"][@"optoutImageUrl"] = @"";
    mutableDict[9][@"native"][@"privacy"][@"optoutImageUrl"] = @(2);
    mutableDict[10][@"native"][@"impressionPixels"] = @[@"", @""];

    NSMutableArray <CR_CdbBid *> *bids = [NSMutableArray new];
    for(int i = 0; i < 11; i++) {
        [bids addObject:[[CR_CdbBid alloc] initWithDict:mutableDict[i] receivedAt:self.now]];
        XCTAssertFalse(bids[i].isValid, @"Case %d failed", i);
    }
}

#pragma mark isRenewable

- (void)testIsRenewableWithNoExpiration {
    CR_CdbBid *bid = CR_CdbBidBuilder.new.ttl(0).build;
    XCTAssertTrue(bid.isRenewable, @"Bid: %@", bid);
}

- (void)testIsRenewableWithNotExpired {
    CR_CdbBid *bid = CR_CdbBidBuilder.new.build;
    XCTAssertTrue(bid.isRenewable, @"Bid: %@", bid);
}

- (void)testIsRenewableWithExpired {
    CR_CdbBid *bid = CR_CdbBidBuilder.new.expiredInsertTime().build;
    XCTAssertTrue(bid.isRenewable);
}

- (void)testIsRenewableWithSilenceMode {
    CR_CdbBid *bid = CR_CdbBidBuilder.new.cpm(@"0.0").ttl(42.0).build;
    XCTAssertFalse(bid.isRenewable);
}

- (void)testIsRenewableWithSilenceModeExpired {
    CR_CdbBid *bid = CR_CdbBidBuilder.new.cpm(@"0.0").ttl(42.0).expiredInsertTime().build;
    XCTAssertTrue(bid.isRenewable);
}

@end
