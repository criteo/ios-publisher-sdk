//
//  CR_HeaderBiddingTests.m
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

#import <MoPub.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "DFPRequestClasses.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbBidBuilder.h"
#import "CR_CdbBid.h"
#import "CR_HeaderBidding.h"
#import "CR_DeviceInfoMock.h"
#import "NSString+Testing.h"
#import "NSString+CriteoUrl.h"
#import "CR_DisplaySizeInjector.h"

static NSString *const kCpmKey = @"crt_cpm";
static NSString *const kDictionaryDisplayUrlKey = @"crt_displayUrl";
static NSString *const kDfpDisplayUrlKey = @"crt_displayurl";
static NSString *const kSizeKey = @"crt_size";

/** Represent the type of the device for getting more readable tests. */
typedef NS_ENUM(NSInteger, CR_DeviceType) {
  CR_DeviceTypeIphone,
  CR_DeviceTypeIpad,
  CR_DeviceTypeOther,
};

/** Represent the orientation of the device for getting more readable tests. */
typedef NS_ENUM(NSInteger, CR_DeviceOrientation) {
  CR_DeviceOrientationLandscape,
  CR_DeviceOrientationPortrait,
};

#define CR_AssertInterstitialCrtSize(_crtSize, _type, _orientation, _size) \
  do {                                                                     \
    [self recordFailureForIntertitialCrtSize:_crtSize                      \
                              withDeviceType:_type                         \
                                 orientation:_orientation                  \
                                  screenSize:_size                         \
                                      atLine:__LINE__];                    \
  } while (0);

#define CR_AssertEqualDfpString(notDfpStr, dfpStr) \
  XCTAssertEqualObjects([NSString cr_dfpCompatibleString:notDfpStr], dfpStr);

@interface CR_HeaderBiddingTests : XCTestCase

@property(strong, nonatomic) CR_DeviceInfoMock *device;
@property(strong, nonatomic) CR_DisplaySizeInjector *displaySizeInjector;
@property(strong, nonatomic) CR_HeaderBidding *headerBidding;

@property(nonatomic, strong) CR_CacheAdUnit *interstitialAdUnit;
@property(nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property(nonatomic, strong) CR_CdbBid *bid1;

@property(nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property(nonatomic, strong) CR_CdbBid *bid2;

@property(nonatomic, strong) NSMutableDictionary *mutableJsonDict;
@property(nonatomic, strong) DFPRequest *dfpRequest;

@end

@implementation CR_HeaderBiddingTests

- (void)setUp {
  self.device = [[CR_DeviceInfoMock alloc] init];
  self.displaySizeInjector = OCMClassMock([CR_DisplaySizeInjector class]);
  self.headerBidding = [[CR_HeaderBidding alloc] initWithDevice:self.device
                                            displaySizeInjector:self.displaySizeInjector];

  self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1" width:300 height:250];
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;

  self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit2" width:200 height:100];
  self.bid2 =
      CR_CdbBidBuilder.new.adUnit(self.adUnit2).cpm(@"0.5").displayUrl(@"bid2.displayUrl").build;

  self.interstitialAdUnit = [CR_CacheAdUnit.alloc initWithAdUnitId:@"interstitial"
                                                              size:CGSizeMake(1, 2)
                                                        adUnitType:CRAdUnitTypeInterstitial];

  self.dfpRequest = [[DFPRequest alloc] init];
  self.dfpRequest.customTargeting = @{@"key_1" : @"object 1", @"key_2" : @"object_2"};

  self.mutableJsonDict = [self loadSlotDictionary];
}

#pragma mark - Empty Bid

- (void)testEmptyBidWitDictionary {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

  [self.headerBidding enrichRequest:dictionary withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit1];

  XCTAssertEqual(dictionary.count, 0);
}

- (void)testEmptyBidWitDfpRequest {
  GADRequest *request = [[GADRequest alloc] init];

  [self.headerBidding enrichRequest:request withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit1];

  XCTAssertEqual(request.customTargeting.count, 0);
}

- (void)testEmptyBidWitMoPubRequest {
  MPAdView *request = [[MPAdView alloc] init];
  request.keywords = @"k:v";

  [self.headerBidding enrichRequest:request withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit1];

  XCTAssertEqual(request.keywords.length, 3);
}

#pragma mark - Dictionary

- (void)testMutableDictionary {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  NSDictionary *expected = @{
    kDictionaryDisplayUrlKey : self.bid1.displayUrl,
    kCpmKey : self.bid1.cpm,
    kSizeKey : @"300x250"
  };

  [self.headerBidding enrichRequest:dictionary withBid:self.bid1 adUnit:self.adUnit1];

  XCTAssertEqualObjects(dictionary, expected);
}

#pragma mark - Google Ad

- (void)testGADRequest {
  GADRequest *request = [[GADRequest alloc] init];
  self.device.mock_screenSize = (CGSize){300, 250};

  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.adUnit1];

  NSDictionary *targeting = request.customTargeting;
  NSString *expectedDfpDisplayUrl = [NSString cr_dfpCompatibleString:self.bid1.displayUrl];
  XCTAssertEqual(targeting.count, 3);
  XCTAssertEqualObjects(targeting[kDfpDisplayUrlKey], expectedDfpDisplayUrl);
  XCTAssertEqualObjects(targeting[kCpmKey], self.bid1.cpm);
  XCTAssertEqualObjects(targeting[kSizeKey], @"300x250");
}

- (void)testDfpRequest {
  DFPRequest *request = [[DFPRequest alloc] init];
  self.device.mock_screenSize = (CGSize){300, 250};

  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.adUnit1];

  NSDictionary *targeting = request.customTargeting;
  NSString *expectedDfpDisplayUrl = [NSString cr_dfpCompatibleString:self.bid1.displayUrl];
  XCTAssertEqual(targeting.count, 3);
  XCTAssertEqualObjects(targeting[kDfpDisplayUrlKey], expectedDfpDisplayUrl);
  XCTAssertEqualObjects(targeting[kCpmKey], self.bid1.cpm);
  XCTAssertEqualObjects(targeting[kSizeKey], @"300x250");
}

- (void)testDfpRequestWithInterstitialHasItsDisplayUrlInjected {
  DFPRequest *request = [[DFPRequest alloc] init];
  self.device.mock_screenSize = (CGSize){42, 1337};

  OCMStub([self.displaySizeInjector injectFullScreenSizeInDisplayUrl:self.bid1.displayUrl])
      .andReturn(@"display.url");

  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.interstitialAdUnit];

  NSDictionary *targeting = request.customTargeting;
  NSString *expectedDfpDisplayUrl = [NSString cr_dfpCompatibleString:@"display.url"];
  XCTAssertEqual(targeting.count, 3);
  XCTAssertEqualObjects(targeting[kDfpDisplayUrlKey], expectedDfpDisplayUrl);
  XCTAssertEqualObjects(targeting[kCpmKey], self.bid1.cpm);
  XCTAssertEqualObjects(targeting[kSizeKey], @"320x480");
}

- (void)testDfpRequestWithNativeBid {
  CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native"
                                                               size:CGSizeMake(2, 2)
                                                         adUnitType:CRAdUnitTypeNative];
  CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict
                                              receivedAt:[NSDate date]];

  [self.headerBidding enrichRequest:self.dfpRequest withBid:nativeBid adUnit:adUnit];

  CR_NativeAssets *nativeAssets = nativeBid.nativeAssets;
  NSDictionary *dfpTargeting = self.dfpRequest.customTargeting;
  XCTAssertTrue(dfpTargeting.count > 2);
  XCTAssertNil([dfpTargeting objectForKey:kDfpDisplayUrlKey]);
  XCTAssertEqual(nativeBid.cpm, dfpTargeting[kCpmKey]);
  [self checkMandatoryNativeAssets:self.dfpRequest nativeBid:nativeBid];
  CR_AssertEqualDfpString(nativeAssets.advertiser.description, dfpTargeting[@"crtn_advname"]);
  CR_AssertEqualDfpString(nativeAssets.advertiser.domain, dfpTargeting[@"crtn_advdomain"]);
  CR_AssertEqualDfpString(nativeAssets.advertiser.logoImage.url, dfpTargeting[@"crtn_advlogourl"]);
  CR_AssertEqualDfpString(nativeAssets.advertiser.logoClickUrl, dfpTargeting[@"crtn_advurl"]);
  CR_AssertEqualDfpString(nativeAssets.privacy.longLegalText, dfpTargeting[@"crtn_prtext"]);
}

- (void)testAddCriteoToDfpRequestForInCompleteNativeBid {
  CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"/140800857/Endeavour_Native"
                                                               size:CGSizeMake(2, 2)
                                                         adUnitType:CRAdUnitTypeNative];
  self.mutableJsonDict[@"native"][@"advertiser"][@"description"] = @"";
  self.mutableJsonDict[@"native"][@"advertiser"][@"domain"] = @"";
  self.mutableJsonDict[@"native"][@"advertiser"][@"logo"][@"url"] = nil;
  self.mutableJsonDict[@"native"][@"advertiser"][@"logoClickUrl"] = @"";
  self.mutableJsonDict[@"native"][@"privacy"][@"longLegalText"] = nil;
  CR_CdbBid *nativeBid = [[CR_CdbBid alloc] initWithDict:self.mutableJsonDict
                                              receivedAt:[NSDate date]];

  [self.headerBidding enrichRequest:self.dfpRequest withBid:nativeBid adUnit:adUnit];

  NSDictionary *dfpTargeting = self.dfpRequest.customTargeting;
  XCTAssertGreaterThan(dfpTargeting.count, 2);
  XCTAssertNil([dfpTargeting objectForKey:kDfpDisplayUrlKey]);
  XCTAssertNil([dfpTargeting objectForKey:@"crtn_advname"]);
  XCTAssertNil([dfpTargeting objectForKey:@"crtn_advdomain"]);
  XCTAssertNil([dfpTargeting objectForKey:@"crtn_advlogourl"]);
  XCTAssertNil([dfpTargeting objectForKey:@"crtn_advurl"]);
  XCTAssertNil([dfpTargeting objectForKey:@"crtn_prtext"]);
  XCTAssertEqual(nativeBid.cpm, [dfpTargeting objectForKey:kCpmKey]);
  [self checkMandatoryNativeAssets:self.dfpRequest nativeBid:nativeBid];
}

#pragma mark - Mopub

- (void)testMPInterstitialAdController {
  MPInterstitialAdController *controller = [MPInterstitialAdController new];
  NSDictionary *expected = @{kCpmKey : self.bid1.cpm, kDictionaryDisplayUrlKey : @"display.url"};

  OCMStub([self.displaySizeInjector
              injectSafeScreenSizeInDisplayUrl:self.bid1.mopubCompatibleDisplayUrl])
      .andReturn(@"display.url");

  [self.headerBidding enrichRequest:controller withBid:self.bid1 adUnit:self.interstitialAdUnit];

  NSDictionary *keywords = [controller.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
}

- (void)testMPAdView {
  MPAdView *request = [[MPAdView alloc] init];
  request.keywords = @"key_1:object_1,key_2:object_2";
  NSDictionary *expected = @{
    @"key_1" : @"object_1",
    @"key_2" : @"object_2",
    kCpmKey : self.bid1.cpm,
    kDictionaryDisplayUrlKey : self.bid1.mopubCompatibleDisplayUrl,
    kSizeKey : @"300x250"
  };

  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.adUnit1];

  NSDictionary *keywords = [request.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
}

- (void)testLoadMopubInterstitial {
  MPInterstitialAdController *request = [[MPInterstitialAdController alloc] init];
  request.keywords = @"key_1:object_1,key_2:object_2";
  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.adUnit1];
  NSDictionary *expected = @{
    @"key_1" : @"object_1",
    @"key_2" : @"object_2",
    // No criteo data because it is remove once the request is loaded.
  };

  [request loadAd];

  NSDictionary *keywords = [request.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
}

- (void)testDuplicateEnrichment {
  MPInterstitialAdController *request = [[MPInterstitialAdController alloc] init];
  request.keywords = @"key_1:object_1,key_2:object_2";
  NSDictionary *expected = @{
    @"key_1" : @"object_1",
    @"key_2" : @"object_2",
    kCpmKey : self.bid2.cpm,
    kDictionaryDisplayUrlKey : @"display.url.2"
  };

  OCMStub([self.displaySizeInjector
              injectSafeScreenSizeInDisplayUrl:self.bid1.mopubCompatibleDisplayUrl])
      .andReturn(@"display.url.1");
  OCMStub([self.displaySizeInjector
              injectSafeScreenSizeInDisplayUrl:self.bid2.mopubCompatibleDisplayUrl])
      .andReturn(@"display.url.2");

  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.interstitialAdUnit];
  [self.headerBidding enrichRequest:request withBid:self.bid2 adUnit:self.interstitialAdUnit];

  NSDictionary *keywords = [request.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
}

#pragma Remove Previous Keys

- (void)testRemoveCriteoBidForMoPub {
  MPAdView *request = [[MPAdView alloc] init];
  request.keywords = @"crt_k1:v1,k:v2,crt_k2:v3";

  [self.headerBidding enrichRequest:request withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit2];

  XCTAssertEqualObjects(request.keywords, @"k:v2");
}

#pragma mark - Sizes

#pragma mark DFP

- (void)testIntertitialSizeOniPhoneInLandscape {
  // Size of recent devices
  // https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Displays/Displays.html

  // iPhone SE => 320 x 568
  CR_AssertInterstitialCrtSize(@"320x480", CR_DeviceTypeIphone, CR_DeviceOrientationPortrait,
                               ((CGSize){320.f, 568.f}));
  CR_AssertInterstitialCrtSize(@"480x320", CR_DeviceTypeIphone, CR_DeviceOrientationLandscape,
                               ((CGSize){568.f, 320.f}));

  // iPhone 7 Plus => 414 x 736
  CR_AssertInterstitialCrtSize(@"320x480", CR_DeviceTypeIphone, CR_DeviceOrientationPortrait,
                               ((CGSize){414.f, 736.f}));
  CR_AssertInterstitialCrtSize(@"480x320", CR_DeviceTypeIphone, CR_DeviceOrientationLandscape,
                               ((CGSize){736.f, 414.f}));

  // iPad Air 2 => 768 x 1024
  CR_AssertInterstitialCrtSize(@"768x1024", CR_DeviceTypeIpad, CR_DeviceOrientationPortrait,
                               ((CGSize){768.f, 1024.f}));
  CR_AssertInterstitialCrtSize(@"1024x768", CR_DeviceTypeIpad, CR_DeviceOrientationLandscape,
                               ((CGSize){1024.f, 768.f}));

  // iPad Pro (12.9-inch) => 1024 x 1366
  CR_AssertInterstitialCrtSize(@"768x1024", CR_DeviceTypeIpad, CR_DeviceOrientationPortrait,
                               ((CGSize){1024.f, 1366.f}));
  CR_AssertInterstitialCrtSize(@"1024x768", CR_DeviceTypeIpad, CR_DeviceOrientationLandscape,
                               ((CGSize){1024.f, 1024.f}));

  // Fictive iPad with small size (so considered as a Phone)
  CR_AssertInterstitialCrtSize(@"320x480", CR_DeviceTypeIpad, CR_DeviceOrientationPortrait,
                               ((CGSize){640.f, 1024.f}));
  CR_AssertInterstitialCrtSize(@"480x320", CR_DeviceTypeIpad, CR_DeviceOrientationLandscape,
                               ((CGSize){1024.f, 640.f}));

  // Fictive TV
  CR_AssertInterstitialCrtSize(@"768x1024", CR_DeviceTypeOther, CR_DeviceOrientationPortrait,
                               ((CGSize){1024.f, 2048.f}));
  CR_AssertInterstitialCrtSize(@"1024x768", CR_DeviceTypeOther, CR_DeviceOrientationLandscape,
                               ((CGSize){2048.f, 1024.f}));
}

#pragma mark - Private

- (void)recordFailureForIntertitialCrtSize:(NSString *)crtSize
                            withDeviceType:(CR_DeviceType)deviceType
                               orientation:(CR_DeviceOrientation)orientation
                                screenSize:(CGSize)screenSize
                                    atLine:(NSUInteger)lineNumber {
  // Clean up because this method can be reused in the same test
  [self tearDown];
  [self setUp];

  CR_CacheAdUnit *adUnit = [CR_CacheAdUnit cacheAdUnitForInterstialWithAdUnitId:@"interstitial"
                                                                           size:(CGSize){400, 400}];
  CR_CdbBid *bid = CR_CdbBidBuilder.new.adUnit(adUnit).build;
  self.device.mock_isPhone = deviceType == CR_DeviceTypeIphone;
  self.device.mock_isInPortrait = orientation == CR_DeviceOrientationPortrait;
  self.device.mock_screenSize = screenSize;

  [self.headerBidding enrichRequest:self.dfpRequest withBid:bid adUnit:adUnit];

  NSDictionary *target = self.dfpRequest.customTargeting;
  if (![crtSize isEqual:target[kSizeKey]]) {
    NSString *desc =
        [[NSString alloc] initWithFormat:@"The customTargeting doesn't contain \"%@ \": %@:%@",
                                         kSizeKey, crtSize, target];
    NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    [self recordFailureWithDescription:desc inFile:file atLine:lineNumber expected:YES];
  }
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
  XCTAssertEqual(nativeAssets.impressionPixels.count,
                 [dfpTargeting[@"crtn_pixcount"] integerValue]);
  for (int i = 0; i < nativeBid.nativeAssets.impressionPixels.count; i++) {
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
  NSURL *jsonURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"SampleBid"
                                                            withExtension:@"json"];
  NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:0 error:&e];
  XCTAssert(e == nil);

  NSMutableDictionary *responseDict =
      [NSJSONSerialization JSONObjectWithData:jsonData
                                      options:NSJSONReadingMutableContainers
                                        error:&e];
  XCTAssert(e == nil);
  return responseDict;
}

@end
