//
//  CR_SKAdNetworkImpressionTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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
#import "CR_SKAdNetworkHandler.h"
#import <StoreKit/SKAdImpression.h>
#import <StoreKitTest/SKAdTestSession.h>
#import "CR_SKAdNetworkFidelityParameter.h"

@interface CR_SKAdNetworkHandler (Testing)
- (SKAdImpression *)skadImpressionForParameters:(CR_SKAdNetworkParameters *)parameters
                                  fidelityParam:(CR_SKAdNetworkFidelityParameter *)fidelity
    API_AVAILABLE(ios(14.5));
@end

API_AVAILABLE(ios(15.4))
@interface CR_SKAdNetworkImpressionTests : XCTestCase

@end

@implementation CR_SKAdNetworkImpressionTests

- (void)testImpression {
  NSString *networkId = @"cr.test.id";
  NSString *version = @"2.2";
  NSUUID *nonce = [[NSUUID alloc] initWithUUIDString:@"b7c9da2b-15c7-4f3b-9326-135f9630033d"];
  NSNumber *campaignId = @(42);
  NSNumber *iTunesItemId = @(12345678);
  NSNumber *timestamp = @(123457890);
  NSNumber *sourceAppId = @(87654321);
  NSString *signature =
      @"MEQCIAtBBiadCFlMOEOh3K43xyKaU1/sj/CtgDOB+Wm7J+29AiBDfreX67mm4X9ZoM4xkHHLtuMM2OXcS5kQ7UpVb69A/Q==";
  CR_SKAdNetworkFidelityParameter *fidelity =
      [[CR_SKAdNetworkFidelityParameter alloc] initWithFidelity:@(1)
                                                      timestamp:timestamp
                                                          nonce:nonce
                                                      signature:signature];

  CR_SKAdNetworkParameters *skAdNetworkParameters =
      [[CR_SKAdNetworkParameters alloc] initWithNetworkId:networkId
                                                  version:version
                                               campaignId:campaignId
                                             iTunesItemId:iTunesItemId
                                                    nonce:nonce
                                                timestamp:timestamp
                                              sourceAppId:sourceAppId
                                                signature:signature
                                               fidelities:[NSArray arrayWithObject:fidelity]];
  CR_SKAdNetworkHandler *handler =
      [[CR_SKAdNetworkHandler alloc] initWithParameters:skAdNetworkParameters];

  SKAdImpression *impression = [handler skadImpressionForParameters:skAdNetworkParameters
                                                      fidelityParam:fidelity];

  XCTAssertEqualObjects(impression.version, version);
  XCTAssertEqualObjects(impression.adNetworkIdentifier, networkId);
  XCTAssertEqualObjects(impression.sourceAppStoreItemIdentifier, sourceAppId);
  XCTAssertEqualObjects(impression.advertisedAppStoreItemIdentifier, iTunesItemId);
  XCTAssertEqualObjects(impression.adImpressionIdentifier, nonce.UUIDString);
  XCTAssertEqualObjects(impression.timestamp, timestamp);
  XCTAssertEqualObjects(impression.signature, signature);
}

@end
