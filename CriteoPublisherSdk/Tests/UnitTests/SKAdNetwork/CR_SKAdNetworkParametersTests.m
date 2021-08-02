//
//  CR_SKAdNetworkParametersTests.m
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

#import <StoreKit/StoreKit.h>
#import "CR_SKAdNetworkParameters.h"
#import "NSDictionary+Criteo.h"

@interface CR_SKAdNetworkParametersTests : XCTestCase
@end

@implementation CR_SKAdNetworkParametersTests

#pragma mark - Init

- (void)testInitWithDict_GivenExpectedTypes_ReturnParameters {
  NSString *networkId = @"networkId";
  NSString *version = @"2.0";
  NSUUID *nonce = [NSUUID UUID];
  NSNumber *campaignId = @(42);
  NSNumber *iTunesItemId = @(12345678);
  NSNumber *timestamp = @(123457890);
  NSNumber *sourceAppId = @(87654321);
  NSString *signature = @"signature";
  CR_SKAdNetworkParameters *parameters = [[CR_SKAdNetworkParameters alloc] initWithDict:@{
    @"version" : version,
    @"network" : networkId,
    @"campaign" : campaignId.stringValue,
    @"itunesItem" : iTunesItemId.stringValue,
    @"nonce" : nonce.UUIDString,
    @"sourceApp" : sourceAppId.stringValue,
    @"timestamp" : timestamp.stringValue,
    @"signature" : signature
  }];
  XCTAssertEqualObjects(parameters.version, version);
  XCTAssertEqualObjects(parameters.networkId, networkId);
  XCTAssertEqualObjects(parameters.campaignId, campaignId);
  XCTAssertEqualObjects(parameters.iTunesItemId, iTunesItemId);
  XCTAssertEqualObjects(parameters.nonce, nonce);
  XCTAssertEqualObjects(parameters.sourceAppId, sourceAppId);
  XCTAssertEqualObjects(parameters.timestamp, timestamp);
  XCTAssertEqualObjects(parameters.signature, signature);
}

- (void)testInitWithDict_GivenAlternateValidTypes_ReturnParameters {
  // JSON numbers should be as valid as strings
  NSString *networkId = @"networkId";
  NSString *version = @"2.0";
  NSUUID *nonce = [NSUUID UUID];
  NSNumber *campaignId = @(42);
  NSNumber *iTunesItemId = @(12345678);
  NSNumber *timestamp = @(123457890);
  NSNumber *sourceAppId = @(87654321);
  NSString *signature = @"signature";
  CR_SKAdNetworkParameters *parameters = [[CR_SKAdNetworkParameters alloc] initWithDict:@{
    @"version" : version,
    @"network" : networkId,
    @"campaign" : campaignId,
    @"itunesItem" : iTunesItemId,
    @"nonce" : nonce.UUIDString,
    @"sourceApp" : sourceAppId,
    @"timestamp" : timestamp,
    @"signature" : signature
  }];
  XCTAssertEqualObjects(parameters.version, version);
  XCTAssertEqualObjects(parameters.networkId, networkId);
  XCTAssertEqualObjects(parameters.campaignId, campaignId);
  XCTAssertEqualObjects(parameters.iTunesItemId, iTunesItemId);
  XCTAssertEqualObjects(parameters.nonce, nonce);
  XCTAssertEqualObjects(parameters.sourceAppId, sourceAppId);
  XCTAssertEqualObjects(parameters.timestamp, timestamp);
  XCTAssertEqualObjects(parameters.signature, signature);
}

- (void)testInitWithDict_GivenNil_ReturnNil {
  NSDictionary *dict = nil;
  XCTAssertNil([[CR_SKAdNetworkParameters alloc] initWithDict:dict]);
}

- (void)testInitWithDict_GivenWrongTypes_ReturnNil {
  XCTAssertNil([[CR_SKAdNetworkParameters alloc] initWithDict:@{@"version" : @1}]);
  XCTAssertNil([[CR_SKAdNetworkParameters alloc] initWithDict:@{@"network" : @2}]);
  XCTAssertNil([[CR_SKAdNetworkParameters alloc] initWithDict:@{@"campaign" : @"not an id"}]);
  XCTAssertNil([[CR_SKAdNetworkParameters alloc] initWithDict:@{@"itunesItem" : @"not an id"}]);
  XCTAssertNil(
      [[CR_SKAdNetworkParameters alloc] initWithDict:@{@"nonce" : @"this-is-not-an-uuid"}]);
  XCTAssertNil([[CR_SKAdNetworkParameters alloc] initWithDict:@{@"sourceApp" : @"not an id"}]);
  XCTAssertNil(
      [[CR_SKAdNetworkParameters alloc] initWithDict:@{@"timestamp" : @"this is not a timestamp"}]);
  XCTAssertNil([[CR_SKAdNetworkParameters alloc] initWithDict:@{@"signature" : @2}]);
}

#pragma mark - Load Product Parameters

- (void)testToLoadProductParameters {
  // API_AVAILABLE does not work for testing, the test fails to succeed under iOS < 14
  if (@available(iOS 14, *)) {
    NSString *networkId = @"networkId";
    NSString *version = @"2.0";
    NSUUID *nonce = [NSUUID UUID];
    NSNumber *campaignId = @(42);
    NSNumber *iTunesItemId = @(12345678);
    NSNumber *timestamp = @(123457890);
    NSNumber *sourceAppId = @(87654321);
    NSString *signature = @"signature";
    CR_SKAdNetworkParameters *skAdNetworkParameters =
        [[CR_SKAdNetworkParameters alloc] initWithNetworkId:networkId
                                                    version:version
                                                 campaignId:campaignId
                                               iTunesItemId:iTunesItemId
                                                      nonce:nonce
                                                  timestamp:timestamp
                                                sourceAppId:sourceAppId
                                                  signature:signature];
    NSDictionary *loadProductParameters = skAdNetworkParameters.toLoadProductParameters;
    NSDictionary *expected = @{
      SKStoreProductParameterAdNetworkVersion : version,
      SKStoreProductParameterAdNetworkIdentifier : networkId,
      SKStoreProductParameterAdNetworkCampaignIdentifier : campaignId,
      SKStoreProductParameterITunesItemIdentifier : iTunesItemId,
      SKStoreProductParameterAdNetworkNonce : nonce,
      SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : sourceAppId,
      SKStoreProductParameterAdNetworkTimestamp : timestamp,
      SKStoreProductParameterAdNetworkAttributionSignature : signature,
    };
    XCTAssertEqualObjects(loadProductParameters, expected);
  }
}

@end
