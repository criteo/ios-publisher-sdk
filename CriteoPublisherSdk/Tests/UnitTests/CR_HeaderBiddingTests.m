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

#import "XCTestCase+Criteo.h"
#import "DFPRequestClasses.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbBidBuilder.h"
#import "CR_CdbBid.h"
#import "CR_HeaderBidding.h"
#import "CR_Logging.h"
#import "CR_DeviceInfoMock.h"
#import "NSString+Testing.h"
#import "NSString+CriteoUrl.h"
#import "CR_DisplaySizeInjector.h"
#import "CR_IntegrationRegistry.h"
#import "CR_DependencyProvider+Testing.h"

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
    [self recordFailureForInterstitialCrtSize:_crtSize                     \
                               withDeviceType:_type                        \
                                  orientation:_orientation                 \
                                   screenSize:_size                        \
                                       atLine:__LINE__];                   \
  } while (0);

#define CR_AssertEqualDfpString(notDfpStr, dfpStr) \
  XCTAssertEqualObjects([NSString cr_dfpCompatibleString:notDfpStr], dfpStr);

@interface CR_HeaderBidding (Testing)

- (BOOL)isDfpRequest:(id)request;
- (BOOL)isMoPubRequest:(id)request;

@end

@interface MyGADRequest : GADRequest
@end

@implementation MyGADRequest
@end

@interface MyGAMRequest : GAMRequest
@end

@implementation MyGAMRequest
@end

@interface MyMPAdView : MPAdView
@end

@implementation MyMPAdView
@end

@interface MyMPInterstitialAdController : MPInterstitialAdController
@end

@implementation MyMPInterstitialAdController
@end

@interface CR_HeaderBiddingTests : XCTestCase

@property(strong, nonatomic) CR_DeviceInfoMock *device;
@property(strong, nonatomic) CR_DisplaySizeInjector *displaySizeInjector;
@property(strong, nonatomic) CR_IntegrationRegistry *integrationRegistry;
@property(strong, nonatomic) CR_HeaderBidding *headerBidding;

@property(nonatomic, strong) CR_CacheAdUnit *interstitialAdUnit;
@property(nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property(nonatomic, strong) CR_CdbBid *bid1;

@property(nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property(nonatomic, strong) CR_CdbBid *bid2;

@property(nonatomic, strong) NSMutableDictionary *mutableJsonDict;
@property(nonatomic, strong) GAMRequest *request;

@property(nonatomic, strong) id loggingMock;

@end

@implementation CR_HeaderBiddingTests

- (void)setUp {
  self.device = [[CR_DeviceInfoMock alloc] init];
  self.displaySizeInjector = OCMClassMock([CR_DisplaySizeInjector class]);

  CR_DependencyProvider *dependencyProvider =
      CR_DependencyProvider.new.withIsolatedIntegrationRegistry;
  dependencyProvider.deviceInfo = self.device;
  dependencyProvider.displaySizeInjector = self.displaySizeInjector;
  self.headerBidding = dependencyProvider.headerBidding;
  self.integrationRegistry = dependencyProvider.integrationRegistry;

  self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1" width:300 height:250];
  self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;

  self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit2" width:200 height:100];
  self.bid2 =
      CR_CdbBidBuilder.new.adUnit(self.adUnit2).cpm(@"0.5").displayUrl(@"bid2.displayUrl").build;

  self.interstitialAdUnit = [CR_CacheAdUnit.alloc initWithAdUnitId:@"interstitial"
                                                              size:CGSizeMake(1, 2)
                                                        adUnitType:CRAdUnitTypeInterstitial];

  self.request = [[GAMRequest alloc] init];
  self.request.customTargeting = @{@"key_1" : @"object 1", @"key_2" : @"object_2"};

  self.mutableJsonDict = [self loadSlotDictionary];

  self.loggingMock = OCMPartialMock(CR_Logging.sharedInstance);
}

- (void)tearDown {
  [self.loggingMock stopMocking];
}

#pragma mark - Empty Bid

- (void)testEmptyBidWithDictionary {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  [self.headerBidding detectIntegration:dictionary];
  [self.headerBidding enrichRequest:dictionary withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit1];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"AppBidding"] &&
                                       [logMessage.message containsString:@"No bid found"];
                              }]]);

  XCTAssertEqual(dictionary.count, 0);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationCustomAppBidding]);
}

- (void)testEmptyBidWithGadRequest {
  GADRequest *request = [[GADRequest alloc] init];
  [self.headerBidding detectIntegration:request];
  [self.headerBidding enrichRequest:request withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit1];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"AppBidding"] &&
                                       [logMessage.message containsString:@"No bid found"];
                              }]]);

  XCTAssertEqual(request.customTargeting.count, 0);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationGamAppBidding]);
}

- (void)testEmptyBidWithMoPubRequest {
  MPAdView *request = [[MPAdView alloc] init];
  request.keywords = @"k:v";
  [self.headerBidding detectIntegration:request];
  [self.headerBidding enrichRequest:request withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit1];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"AppBidding"] &&
                                       [logMessage.message containsString:@"No bid found"];
                              }]]);

  XCTAssertEqual(request.keywords.length, 3);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationMopubAppBidding]);
}

#pragma mark - Dictionary

- (void)testMutableDictionary {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  NSDictionary *expected = @{
    kDictionaryDisplayUrlKey : self.bid1.displayUrl,
    kCpmKey : self.bid1.cpm,
    kSizeKey : @"300x250"
  };

  [self.headerBidding detectIntegration:dictionary];
  [self.headerBidding enrichRequest:dictionary withBid:self.bid1 adUnit:self.adUnit1];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"AppBidding"] &&
                                       [logMessage.message containsString:@"Custom"] &&
                                       [logMessage.message containsString:expected.description];
                              }]]);

  XCTAssertEqualObjects(dictionary, expected);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationCustomAppBidding]);
}

- (void)testMutableDictionaryWithInterstitial {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  NSDictionary *expected = @{
    kDictionaryDisplayUrlKey : self.bid1.displayUrl,
    kCpmKey : self.bid1.cpm,
    kSizeKey : @"1x2"
  };
  [self.headerBidding detectIntegration:dictionary];
  [self.headerBidding enrichRequest:dictionary withBid:self.bid1 adUnit:self.interstitialAdUnit];

  XCTAssertEqualObjects(dictionary, expected);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationCustomAppBidding]);
}

#pragma mark - Unsupported

- (void)testUnsupportedAdRequest {
  NSArray *array = [[NSArray alloc] init];
  [self.headerBidding detectIntegration:array];
  [self.headerBidding enrichRequest:array withBid:self.bid1 adUnit:self.adUnit1];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return logMessage.severity == CR_LogSeverityError &&
                                       [logMessage.tag isEqualToString:@"AppBidding"] &&
                                       [logMessage.message containsString:@"unsupported"];
                              }]]);
}

#pragma mark - Google Ad

- (void)testIsDFPRequest_GivenGADRequest_ReturnTrue {
  id request = GADRequest.new;

  BOOL isDfpRequest = [self.headerBidding isDfpRequest:request];

  XCTAssertTrue(isDfpRequest);
}

- (void)testIsDFPRequest_GivenSubClassOfGADRequest_ReturnTrue {
  id request = MyGADRequest.new;

  BOOL isDfpRequest = [self.headerBidding isDfpRequest:request];

  XCTAssertTrue(isDfpRequest);
}

- (void)testIsDFPRequest_GivenGAMRequest_ReturnTrue {
  id request = GAMRequest.new;

  BOOL isDfpRequest = [self.headerBidding isDfpRequest:request];

  XCTAssertTrue(isDfpRequest);
}

- (void)testIsDFPRequest_GivenSubClassOfGAMRequest_ReturnTrue {
  id request = MyGAMRequest.new;

  BOOL isDfpRequest = [self.headerBidding isDfpRequest:request];

  XCTAssertTrue(isDfpRequest);
}

- (void)testIsDFPRequest_GivenUnrelatedObject_ReturnFalse {
  id request = NSObject.new;

  BOOL isDfpRequest = [self.headerBidding isDfpRequest:request];

  XCTAssertFalse(isDfpRequest);
}

- (void)testGADRequest {
  GADRequest *request = [[GADRequest alloc] init];
  self.device.mock_screenSize = (CGSize){300, 250};
  [self.headerBidding detectIntegration:request];
  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.adUnit1];

  NSDictionary *targeting = request.customTargeting;
  NSString *expectedDfpDisplayUrl = [NSString cr_dfpCompatibleString:self.bid1.displayUrl];
  XCTAssertEqual(targeting.count, 3);
  XCTAssertEqualObjects(targeting[kDfpDisplayUrlKey], expectedDfpDisplayUrl);
  XCTAssertEqualObjects(targeting[kCpmKey], self.bid1.cpm);
  XCTAssertEqualObjects(targeting[kSizeKey], @"300x250");
  OCMVerify([self.integrationRegistry declare:CR_IntegrationGamAppBidding]);
}

- (void)testGamRequest {
  GAMRequest *request = [[GAMRequest alloc] init];
  self.device.mock_screenSize = (CGSize){300, 250};
  [self.headerBidding detectIntegration:request];
  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.adUnit1];
  OCMVerify([self.loggingMock
      logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
        return [logMessage.tag isEqualToString:@"AppBidding"] &&
               [logMessage.message containsString:@"DFP"] &&
               [logMessage.message containsString:@"\"crt_cpm\" = \"2.0\""] &&
               [logMessage.message containsString:@"\"crt_displayurl\" = \"aHR0cHM6"] &&
               [logMessage.message containsString:@"\"crt_size\" = 300x250"];
      }]]);

  NSDictionary *targeting = request.customTargeting;
  NSString *expectedDfpDisplayUrl = [NSString cr_dfpCompatibleString:self.bid1.displayUrl];
  XCTAssertEqual(targeting.count, 3);
  XCTAssertEqualObjects(targeting[kDfpDisplayUrlKey], expectedDfpDisplayUrl);
  XCTAssertEqualObjects(targeting[kCpmKey], self.bid1.cpm);
  XCTAssertEqualObjects(targeting[kSizeKey], @"300x250");
  OCMVerify([self.integrationRegistry declare:CR_IntegrationGamAppBidding]);
}

- (void)testDfpRequestWithInterstitialHasItsDisplayUrlInjected {
  GAMRequest *request = [[GAMRequest alloc] init];
  self.device.mock_screenSize = (CGSize){42, 1337};

  OCMStub([self.displaySizeInjector injectFullScreenSizeInDisplayUrl:self.bid1.displayUrl])
      .andReturn(@"display.url");
  [self.headerBidding detectIntegration:request];
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
  [self.headerBidding detectIntegration:self.request];
  [self.headerBidding enrichRequest:self.request withBid:nativeBid adUnit:adUnit];

  CR_NativeAssets *nativeAssets = nativeBid.nativeAssets;
  NSDictionary *dfpTargeting = self.request.customTargeting;
  XCTAssertTrue(dfpTargeting.count > 2);
  XCTAssertNil(dfpTargeting[kDfpDisplayUrlKey]);
  XCTAssertEqual(nativeBid.cpm, dfpTargeting[kCpmKey]);
  [self checkMandatoryNativeAssets:self.request nativeBid:nativeBid];
  CR_AssertEqualDfpString(nativeAssets.advertiser.description, dfpTargeting[@"crtn_advname"]);
  CR_AssertEqualDfpString(nativeAssets.advertiser.domain, dfpTargeting[@"crtn_advdomain"]);
  CR_AssertEqualDfpString(nativeAssets.advertiser.logoImage.url, dfpTargeting[@"crtn_advlogourl"]);
  CR_AssertEqualDfpString(nativeAssets.advertiser.logoClickUrl, dfpTargeting[@"crtn_advurl"]);
  CR_AssertEqualDfpString(nativeAssets.privacy.longLegalText, dfpTargeting[@"crtn_prtext"]);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationGamAppBidding]);
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
  [self.headerBidding detectIntegration:self.request];
  [self.headerBidding enrichRequest:self.request withBid:nativeBid adUnit:adUnit];

  NSDictionary *dfpTargeting = self.request.customTargeting;
  XCTAssertGreaterThan(dfpTargeting.count, 2);
  XCTAssertNil(dfpTargeting[kDfpDisplayUrlKey]);
  XCTAssertNil(dfpTargeting[@"crtn_advname"]);
  XCTAssertNil(dfpTargeting[@"crtn_advdomain"]);
  XCTAssertNil(dfpTargeting[@"crtn_advlogourl"]);
  XCTAssertNil(dfpTargeting[@"crtn_advurl"]);
  XCTAssertNil(dfpTargeting[@"crtn_prtext"]);
  XCTAssertEqual(nativeBid.cpm, dfpTargeting[kCpmKey]);
  [self checkMandatoryNativeAssets:self.request nativeBid:nativeBid];
}

#pragma mark - Mopub

- (void)testIsMoPubRequest_GivenMoPubView_ReturnTrue {
  id request = MPAdView.new;

  BOOL isMoPubRequest = [self.headerBidding isMoPubRequest:request];

  XCTAssertTrue(isMoPubRequest);
}

- (void)testIsMoPubRequest_GivenSubClassOfMoPubView_ReturnTrue {
  id request = MyMPAdView.new;

  BOOL isMoPubRequest = [self.headerBidding isMoPubRequest:request];

  XCTAssertTrue(isMoPubRequest);
}

- (void)testIsMoPubRequest_GivenMoPubInterstitial_ReturnTrue {
  id request = MPInterstitialAdController.new;

  BOOL isMoPubRequest = [self.headerBidding isMoPubRequest:request];

  XCTAssertTrue(isMoPubRequest);
}

- (void)testIsMoPubRequest_GivenSubClassOfMoPubInterstitialRequest_ReturnTrue {
  id request = MyMPInterstitialAdController.new;

  BOOL isMoPubRequest = [self.headerBidding isMoPubRequest:request];

  XCTAssertTrue(isMoPubRequest);
}

- (void)testIsMoPubRequest_GivenUnrelatedObject_ReturnFalse {
  id request = NSObject.new;

  BOOL isMoPubRequest = [self.headerBidding isMoPubRequest:request];

  XCTAssertFalse(isMoPubRequest);
}

- (void)testMPInterstitialAdController {
  MPInterstitialAdController *controller = [MPInterstitialAdController new];
  NSDictionary *expected = @{kCpmKey : self.bid1.cpm, kDictionaryDisplayUrlKey : @"display.url"};

  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:self.bid1.displayUrl])
      .andReturn(@"display.url");
  [self.headerBidding detectIntegration:controller];
  [self.headerBidding enrichRequest:controller withBid:self.bid1 adUnit:self.interstitialAdUnit];

  NSDictionary *keywords = [controller.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationMopubAppBidding]);
}

- (void)testMPAdView {
  MPAdView *request = [[MPAdView alloc] init];
  request.keywords = @"key_1:object_1,key_2:object_2";
  NSDictionary *expected = @{
    @"key_1" : @"object_1",
    @"key_2" : @"object_2",
    kCpmKey : self.bid1.cpm,
    kDictionaryDisplayUrlKey : self.bid1.displayUrl,
    kSizeKey : @"300x250"
  };
  [self.headerBidding detectIntegration:request];
  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.adUnit1];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"AppBidding"] &&
                                       [logMessage.message containsString:@"MoPub"] &&
                                       [logMessage.message containsString:@"crt_cpm:2.0"] &&
                                       [logMessage.message
                                           containsString:@"crt_displayUrl:https://publi"] &&
                                       [logMessage.message containsString:@"crt_size:300x250"];
                              }]]);

  NSDictionary *keywords = [request.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationMopubAppBidding]);
}

- (void)testLoadMopubInterstitial {
  MPInterstitialAdController *request = [[MPInterstitialAdController alloc] init];
  request.keywords = @"key_1:object_1,key_2:object_2";
  [self.headerBidding detectIntegration:request];
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

  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:self.bid1.displayUrl])
      .andReturn(@"display.url.1");
  OCMStub([self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:self.bid2.displayUrl])
      .andReturn(@"display.url.2");
  [self.headerBidding detectIntegration:request];

  [self.headerBidding enrichRequest:request withBid:self.bid1 adUnit:self.interstitialAdUnit];
  [self.headerBidding enrichRequest:request withBid:self.bid2 adUnit:self.interstitialAdUnit];

  NSDictionary *keywords = [request.keywords testing_moPubKeywordDictionary];
  XCTAssertEqualObjects(keywords, expected);
}

#pragma Remove Previous Keys

- (void)testRemoveCriteoBidForMoPub {
  MPAdView *request = [[MPAdView alloc] init];
  request.keywords = @"crt_k1:v1,k:v2,crt_k2:v3";
  [self.headerBidding detectIntegration:request];
  [self.headerBidding enrichRequest:request withBid:[CR_CdbBid emptyBid] adUnit:self.adUnit2];

  XCTAssertEqualObjects(request.keywords, @"k:v2");
}

#pragma mark - Sizes

#pragma mark DFP

- (void)testInterstitialSizeOniPhoneInLandscape {
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

- (void)recordFailureForInterstitialCrtSize:(NSString *)crtSize
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
  [self.headerBidding detectIntegration:self.request];
  [self.headerBidding enrichRequest:self.request withBid:bid adUnit:adUnit];

  NSDictionary *target = self.request.customTargeting;
  if (![crtSize isEqual:target[kSizeKey]]) {
    NSString *desc =
        [[NSString alloc] initWithFormat:@"The customTargeting doesn't contain \"%@ \": %@:%@",
                                         kSizeKey, crtSize, target];
    NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    [self cr_recordFailureWithDescription:desc inFile:file atLine:lineNumber expected:YES];
  }
}

- (void)checkMandatoryNativeAssets:(GAMRequest *)request nativeBid:(CR_CdbBid *)nativeBid {
  CR_NativeAssets *nativeAssets = nativeBid.nativeAssets;
  CR_NativeProduct *firstProduct = nativeAssets.products[0];
  NSDictionary *dfpTargeting = request.customTargeting;
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
