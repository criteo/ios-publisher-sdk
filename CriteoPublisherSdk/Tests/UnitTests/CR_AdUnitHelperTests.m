//
//  CR_AdUnitHelperTests.m
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

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRBannerAdUnit.h"
#import "CRInterstitialAdUnit.h"
#import "CRNativeAdUnit.h"
#import "CR_DeviceInfo.h"
#import "CR_AdUnitHelper.h"
#import "CR_DependencyProvider.h"

@interface CR_AdUnitHelperTests : XCTestCase

@end

@implementation CR_AdUnitHelperTests

- (void)testBannerAdUnitsToCacheAdUnits {
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234"
                                                               size:CGSizeMake(320.0, 50.0)];
  CR_CacheAdUnit *expectedCacheAdUnit =
      [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                          size:CGSizeMake(320.0, 50.0)
                                    adUnitType:CRAdUnitTypeBanner];
  XCTAssertEqualObjects(expectedCacheAdUnit, [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]);
}

- (void)testInterstitialAdUnitsToCacheAdUnits {
  CRInterstitialAdUnit *adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"1234"];
  CR_CacheAdUnit *expectedCacheAdUnit =
      [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                          size:CGSizeMake(400.0, 480.0)
                                    adUnitType:CRAdUnitTypeInterstitial];
  CR_DeviceInfo *deviceInfo = [self mockDeviceInfo];
  OCMStub([deviceInfo screenSize]).andReturn(CGSizeMake(400.0, 480.0));

  XCTAssertEqualObjects(expectedCacheAdUnit, [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]);
}

- (void)testAdUnitToCacheAdUnit {
  CRInterstitialAdUnit *interstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"1234"];
  CR_CacheAdUnit *expectedInterstitialCacheAdUnit =
      [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                          size:CGSizeMake(400.0, 700.0)
                                    adUnitType:CRAdUnitTypeInterstitial];
  CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"1234"
                                                                     size:CGSizeMake(320.0, 50.0)];
  CR_CacheAdUnit *expectedBannerCacheAdUnit =
      [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                          size:CGSizeMake(320.0, 50.0)
                                    adUnitType:CRAdUnitTypeBanner];
  CRNativeAdUnit *nativeAdUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"1234"];
  CR_CacheAdUnit *expectedNativeCacheAdUnit =
      [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                          size:CGSizeMake(2.0, 2.0)
                                    adUnitType:CRAdUnitTypeNative];

  CR_DeviceInfo *deviceInfo = [self mockDeviceInfo];
  OCMStub(deviceInfo.screenSize).andReturn(CGSizeMake(400.0, 700.0));

  // for banner, interstitial and native
  XCTAssertEqualObjects(expectedBannerCacheAdUnit,
                        [CR_AdUnitHelper cacheAdUnitForAdUnit:bannerAdUnit]);
  XCTAssertEqualObjects(expectedInterstitialCacheAdUnit,
                        [CR_AdUnitHelper cacheAdUnitForAdUnit:interstitialAdUnit]);
  XCTAssertEqualObjects(expectedNativeCacheAdUnit,
                        [CR_AdUnitHelper cacheAdUnitForAdUnit:nativeAdUnit]);
}

- (void)testNativeAdUnitToCacheAdUnit {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"1234"];
  CR_CacheAdUnit *expectedCacheAdUnit =
      [[CR_CacheAdUnit alloc] initWithAdUnitId:@"1234"
                                          size:CGSizeMake(2.0, 2.0)
                                    adUnitType:CRAdUnitTypeNative];
  XCTAssertEqualObjects(expectedCacheAdUnit, [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]);
}

- (CR_DeviceInfo *)mockDeviceInfo {
  CR_DeviceInfo *deviceInfo = OCMClassMock([CR_DeviceInfo class]);
  Criteo.sharedCriteo.dependencyProvider.deviceInfo = deviceInfo;
  return deviceInfo;
}

@end
