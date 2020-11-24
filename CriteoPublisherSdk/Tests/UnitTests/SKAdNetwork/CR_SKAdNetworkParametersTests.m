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

@interface CR_SKAdNetworkParametersTests : XCTestCase
@end

@implementation CR_SKAdNetworkParametersTests

#pragma mark - Load Product Parameters

- (void)testToLoadProductParameters API_AVAILABLE(ios(14.0)) {
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

@end
