//
//  CR_CacheManagerTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_CacheAdUnit.h"
#import "CR_CacheManager.h"
#import "CR_DeviceInfo.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DependencyProvider.h"

@interface CR_CacheManagerTests : XCTestCase

@property(strong) CR_CacheManager *cacheManager;
@property(strong) CR_CacheAdUnit *adUnit;
@property(strong) CR_CdbBid *testBid;
@property(strong) NSDictionary *assetsDict;
@property(strong) NSDictionary *productDict1;
@property(strong) NSDictionary *productDict2;
@property(strong) NSDictionary *impressionPixelDict1;
@property(strong) NSDictionary *impressionPixelDict2;
@property(strong) NSDictionary *advertiserDict;
@property(strong) NSDictionary *privacyDict;
@property(strong) CR_DeviceInfo *originDeviceInfo;

@end

@implementation CR_CacheManagerTests

- (void)setUp {
  self.cacheManager = [[CR_CacheManager alloc] init];
  self.productDict1 = @{
    @"title" : @"\"Stripe Pima Dress\" - $99",
    @"description" : @"We're All About Comfort.",
    @"price" : @"$99",
    @"clickUrl" : @"https://cat.sv.us.criteo.com/delivery/ckn.php?",
    @"callToAction" : @"scipio",
    @"image" :
        @{@"url" : @"https://pix.us.criteo.net/img/img?", @"height" : @(501), @"width" : @(502)}
  };
  self.productDict2 = @{
    @"title" : @"\"Just a Dress\" - $9999",
    @"description" : @"We're NOT About Comfort.",
    @"price" : @"$9999",
    @"clickUrl" : @"https://cat.sv.us.criteo.com/delivery/ckn2.php?",
    @"callToAction" : @"Buy this blinkin dress",
    @"image" :
        @{@"url" : @"https://pix.us.criteo.net/img/img2?", @"height" : @(401), @"width" : @(402)}
  };
  self.impressionPixelDict1 = @{@"url" : @"https://cat.sv.us.criteo.com/delivery/lgn.php?"};
  self.impressionPixelDict2 = @{@"url" : @"https://cat.sv.us.criteo.com/delivery2/lgn.php?"};
  self.advertiserDict = @{
    @"description" : @"The Company Store",
    @"domain" : @"thecompanystore.com",
    @"logo" :
        @{@"url" : @"https://pix.us.criteo.net/img/img?", @"height" : @(200), @"width" : @(300)},
    @"logoClickUrl" : @"https://cat.sv.us.criteo.com/delivery/ckn.php?"
  };
  self.privacyDict = @{
    @"optoutClickUrl" : @"https://privacy.us.criteo.com/adcenter?",
    @"optoutImageUrl" : @"https://static.criteo.net/flash/icon/nai_small.png",
    @"longLegalText" : @"Blah dee blah blah"
  };
  self.assetsDict = @{
    @"products" : @[ self.productDict1, self.productDict2 ],
    @"privacy" : self.privacyDict,
    @"advertiser" : self.advertiserDict,
    @"impressionPixels" : @[ self.impressionPixelDict1, self.impressionPixelDict2 ]
  };
}

- (void)testGetBidWithinTtl {
  [self createAdUnitAndTestBidWithSize:CGSizeMake(200, 100)
                            adUnitType:CRAdUnitTypeBanner
                          nativeAssets:nil];

  [self.cacheManager setBid:self.testBid];
  CR_CdbBid *retrievedBid = [self.cacheManager getBidForAdUnit:self.adUnit];

  XCTAssertNotNil(retrievedBid);
  XCTAssertEqualObjects(self.adUnit.adUnitId, retrievedBid.placementId);
}

- (void)testSetBidForBanner {
  [self createAdUnitAndTestBidWithSize:CGSizeMake(320, 50)
                            adUnitType:CRAdUnitTypeBanner
                          nativeAssets:nil];

  CR_CacheAdUnit *newAdUnit = [self.cacheManager setBid:self.testBid];
  XCTAssertEqualObjects(self.adUnit, newAdUnit);
  XCTAssertTrue([[self.cacheManager getBidForAdUnit:self.adUnit] isEqual:self.testBid]);
}

- (void)testSetBidForInterstitial {
  CR_DeviceInfo *deviceInfo = [self mockDeviceInfo];
  OCMStub(deviceInfo.screenSize).andReturn(CGSizeMake(320, 50));

  [self createAdUnitAndTestBidWithSize:CGSizeMake(320, 50)
                            adUnitType:CRAdUnitTypeInterstitial
                          nativeAssets:nil];

  [self.cacheManager setBid:self.testBid];
  XCTAssertTrue([[self.cacheManager getBidForAdUnit:self.adUnit] isEqual:self.testBid]);

  OCMStub(deviceInfo.screenSize).andReturn(CGSizeMake(50, 320));
  [self.cacheManager setBid:self.testBid];
  XCTAssertTrue([[self.cacheManager getBidForAdUnit:self.adUnit] isEqual:self.testBid]);
  Criteo.sharedCriteo.dependencyProvider.deviceInfo = _originDeviceInfo;
}

- (void)testSetBidForNative {
  CR_NativeAssets *nativeAssets = [[CR_NativeAssets alloc] initWithDict:self.assetsDict];
  [self createAdUnitAndTestBidWithSize:CGSizeMake(2, 2)
                            adUnitType:CRAdUnitTypeNative
                          nativeAssets:nativeAssets];

  [self.cacheManager setBid:self.testBid];

  CR_CdbBid *cachedTestBid = [self.cacheManager getBidForAdUnit:self.adUnit];
  XCTAssertEqualObjects(self.testBid, cachedTestBid);
}

- (void)testSetNullBid_ShouldNotSetBid {
  CR_CacheAdUnit *adUnit = [self.cacheManager setBid:nil];

  XCTAssertNil([self.cacheManager getBidForAdUnit:adUnit]);
  XCTAssertNil(adUnit);
}

- (void)testSetBidForRewarded {
  CR_DeviceInfo *deviceInfo = [self mockDeviceInfo];
  OCMStub(deviceInfo.screenSize).andReturn(CGSizeMake(320, 50));

  [self createAdUnitAndTestBidWithSize:CGSizeMake(320, 50)
                            adUnitType:CRAdUnitTypeRewarded
                          nativeAssets:nil];

  [self.cacheManager setBid:self.testBid];
  XCTAssertTrue([[self.cacheManager getBidForAdUnit:self.adUnit] isEqual:self.testBid]);

  OCMStub(deviceInfo.screenSize).andReturn(CGSizeMake(50, 320));
  [self.cacheManager setBid:self.testBid];
  XCTAssertTrue([[self.cacheManager getBidForAdUnit:self.adUnit] isEqual:self.testBid]);
  Criteo.sharedCriteo.dependencyProvider.deviceInfo = _originDeviceInfo;
}

- (void)testSetInvalidBid_ShouldNotSetBid {
  NSDictionary *badAssetsDict = @{
    @"products" : @[ self.productDict1, self.productDict2 ],
    @"privacy" : self.privacyDict,
    @"advertiser" : self.advertiserDict,
    @"impressionPixels" : @[]
  };
  CR_NativeAssets *badNativeAssets = [[CR_NativeAssets alloc] initWithDict:badAssetsDict];
  [self createAdUnitAndTestBidWithSize:CGSizeMake(320, 50)
                            adUnitType:CRAdUnitTypeNative
                          nativeAssets:badNativeAssets];

  CR_CacheAdUnit *newAdUnit = [self.cacheManager setBid:self.testBid];

  XCTAssertNil([self.cacheManager getBidForAdUnit:self.adUnit]);
  XCTAssertNil(newAdUnit);
}

- (void)testSetBidWithInvalidAdUnit_ShouldNotSetBid {
  [self createAdUnitAndTestBidWithSize:CGSizeMake(0, 0)
                            adUnitType:CRAdUnitTypeBanner
                          nativeAssets:nil];

  CR_CacheAdUnit *newAdUnit = [self.cacheManager setBid:self.testBid];

  XCTAssertNil([self.cacheManager getBidForAdUnit:self.adUnit]);
  XCTAssertNil(newAdUnit);
}

#pragma mark - Private methods

- (void)createAdUnitAndTestBidWithSize:(CGSize)size
                            adUnitType:(CRAdUnitType)adUnitType
                          nativeAssets:(CR_NativeAssets *)nativeAssets {
  self.adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"a_test_placement"
                                                    size:size
                                              adUnitType:adUnitType];

  self.testBid = CR_CdbBidBuilder.new.zoneId(1)
                     .adUnit(self.adUnit)
                     .cpm(@"0.0312")
                     .currency(@"USD")
                     .ttl(200)
                     .creative(nil)
                     .displayUrl(@"https://someUrl.com")
                     .insertTime([NSDate date])
                     .nativeAssets(nativeAssets)
                     .impressionId(nil)
                     .build;
}

- (CR_DeviceInfo *)mockDeviceInfo {
  _originDeviceInfo = Criteo.sharedCriteo.dependencyProvider.deviceInfo;
  CR_DeviceInfo *deviceInfo = OCMPartialMock(_originDeviceInfo);
  Criteo.sharedCriteo.dependencyProvider.deviceInfo = deviceInfo;
  return deviceInfo;
}

@end
