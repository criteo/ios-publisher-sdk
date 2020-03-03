//
//  CR_CacheManagerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_CacheAdUnit.h"
#import "CR_CacheManager.h"
#import "CR_DeviceInfo.h"

@interface CR_CacheManagerTests : XCTestCase

@property (strong) NSDictionary *assetsDict;
@property (strong) NSDictionary *productDict1;
@property (strong) NSDictionary *productDict2;
@property (strong) NSDictionary *impressionPixelDict1;
@property (strong) NSDictionary *impressionPixelDict2;
@property (strong) NSDictionary *advertiserDict;
@property (strong) NSDictionary *privacyDict;

@end

@implementation CR_CacheManagerTests

- (void)setUp {
    self.productDict1 = @{ @"title": @"\"Stripe Pima Dress\" - $99",
                           @"description": @"We're All About Comfort.",
                           @"price": @"$99",
                           @"clickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn.php?",
                           @"callToAction": @"scipio",
                           @"image": @{
                                   @"url": @"https://pix.us.criteo.net/img/img?",
                                   @"height": @(501),
                                   @"width": @(502)
                                   }
                           };
    self.productDict2 = @{ @"title": @"\"Just a Dress\" - $9999",
                           @"description": @"We're NOT About Comfort.",
                           @"price": @"$9999",
                           @"clickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn2.php?",
                           @"callToAction": @"Buy this blinkin dress",
                           @"image": @{
                                   @"url": @"https://pix.us.criteo.net/img/img2?",
                                   @"height": @(401),
                                   @"width": @(402)
                                   }
                           };
    self.impressionPixelDict1 = @{ @"url": @"https://cat.sv.us.criteo.com/delivery/lgn.php?" };
    self.impressionPixelDict2 = @{ @"url": @"https://cat.sv.us.criteo.com/delivery2/lgn.php?" };
    self.advertiserDict = @{ @"description": @"The Company Store",
                             @"domain": @"thecompanystore.com",
                             @"logo": @{
                                     @"url": @"https://pix.us.criteo.net/img/img?",
                                     @"height": @(200),
                                     @"width":  @(300)
                                     },
                             @"logoClickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn.php?"
                             };
    self.privacyDict = @{
                         @"optoutClickUrl": @"https://privacy.us.criteo.com/adcenter?",
                         @"optoutImageUrl": @"https://static.criteo.net/flash/icon/nai_small.png",
                         @"longLegalText": @"Blah dee blah blah"
                         };

    self.assetsDict = @{ @"products": @[ self.productDict1, self.productDict2 ],
                         @"privacy": self.privacyDict,
                         @"advertiser": self.advertiserDict,
                         @"impressionPixels": @[ self.impressionPixelDict1, self.impressionPixelDict2]
                       };
}

- (void) testGetBidWithinTtl {
    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    CGSize adSize = CGSizeMake(200, 100);
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:adSize adUnitType:CRAdUnitTypeBanner];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date] nativeAssets:nil impressionId:nil];

    [cache setBid:testBid];
    CR_CdbBid *retreivedBid = [cache getBidForAdUnit:adUnit];
    XCTAssertNotNil(retreivedBid);
    XCTAssertEqualObjects(adUnit.adUnitId, retreivedBid.placementId);
}

- (void)testSetBidForBanner {
    CR_CacheManager *cacheManager = [CR_CacheManager new];
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:CGSizeMake(320, 50) adUnitType:CRAdUnitTypeBanner];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date] nativeAssets:nil impressionId:nil];
    [cacheManager setBid:testBid];
    XCTAssertTrue([[cacheManager getBidForAdUnit:adUnit] isEqual:testBid]);
}

- (void)testSetBidForInterstitial {
    CR_CacheManager *cacheManager = [CR_CacheManager new];
    id deviceInfoClassMock = OCMClassMock([CR_DeviceInfo class]);
    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(320, 50));

    CR_CacheAdUnit *adUnit_portrait = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement" size:CGSizeMake(320, 50) adUnitType:CRAdUnitTypeInterstitial];
    CR_CdbBid *testBid_portrait = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit_portrait.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit_portrait.size.width) height:@(adUnit_portrait.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date] nativeAssets:nil impressionId:nil];
    [cacheManager setBid:testBid_portrait];
    XCTAssertTrue([[cacheManager getBidForAdUnit:adUnit_portrait] isEqual:testBid_portrait]);

    OCMStub([deviceInfoClassMock getScreenSize]).andReturn(CGSizeMake(50, 320));
    [cacheManager setBid:testBid_portrait];
    XCTAssertTrue([[cacheManager getBidForAdUnit:adUnit_portrait] isEqual:testBid_portrait]);
}

- (void)testSetBidForNative {
    CR_CacheManager *cacheManager = [CR_CacheManager new];
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement"
                                                                 size:CGSizeMake(2, 2)
                                                             adUnitType:CRAdUnitTypeNative];
    CR_NativeAssets *nativeAssets = [[CR_NativeAssets alloc] initWithDict:self.assetsDict];
    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date] nativeAssets:nativeAssets impressionId:nil];
    [cacheManager setBid:testBid];
    CR_CdbBid *cachedTestBid = [cacheManager getBidForAdUnit:adUnit];
    XCTAssertEqualObjects(testBid, cachedTestBid);
}

- (void)testSetBidWithMissingImpressionPixels {
    NSDictionary *badAssetsDict = @{ @"products": @[ self.productDict1, self.productDict2 ],
                         @"privacy": self.privacyDict,
                         @"advertiser": self.advertiserDict,
                         @"impressionPixels": @[]
                         };
    CR_CacheManager *cacheManager = [CR_CacheManager new];
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement"
                                                                 size:CGSizeMake(320, 50)
                                                           adUnitType:CRAdUnitTypeNative];
   CR_NativeAssets *badNativeAssets = [[CR_NativeAssets alloc] initWithDict:badAssetsDict];
    CR_CdbBid *badTestBid = [[CR_CdbBid alloc] initWithZoneId:nil placementId:adUnit.adUnitId cpm:@"0.0312" currency:@"USD" width:@(adUnit.size.width) height:@(adUnit.size.height) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[NSDate date] nativeAssets:badNativeAssets impressionId:nil];
    [cacheManager setBid:badTestBid];
    XCTAssertNil([cacheManager getBidForAdUnit:adUnit]);
}

@end
