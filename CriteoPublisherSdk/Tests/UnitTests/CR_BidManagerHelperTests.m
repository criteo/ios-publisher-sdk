//
//  CR_BidManagerHelperTests.m
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
#import <MoPub.h>
#import <OCMock.h>
#import "CR_BidmanagerHelper.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbBid.h"
#import "CR_HeaderBidding.h"
#import "CR_DeviceInfoMock.h"
#import "CR_DisplaySizeInjector.h"
#import "CR_DependencyProvider.h"

@interface CR_BidManagerHelperTests : XCTestCase

@end

@implementation CR_BidManagerHelperTests

- (void)testRemoveCriteoBidFromMopubAdRequest {
  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.new;
  dependencyProvider.displaySizeInjector = OCMClassMock([CR_DisplaySizeInjector class]);
  dependencyProvider.deviceInfo = [[CR_DeviceInfoMock alloc] init];
  CR_HeaderBidding *headerBidding = dependencyProvider.headerBidding;
  CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid"
                                                              width:300
                                                             height:250];
  CR_CdbBid *testBid_1 = [[CR_CdbBid alloc]
      initWithZoneId:nil
         placementId:@"adunitid"
                 cpm:@"1.1200000047683716"
            currency:@"EUR"
               width:@(300)
              height:@(250)
                 ttl:600
            creative:nil
          displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js"
          insertTime:[NSDate date]
        nativeAssets:nil
        impressionId:nil];

  OCMStub([dependencyProvider.displaySizeInjector
              injectSafeScreenSizeInDisplayUrl:testBid_1.displayUrl])
      .andReturn(testBid_1.displayUrl);

  MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
  mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

  [headerBidding enrichRequest:mopubBidRequest withBid:testBid_1 adUnit:slot_1];

  XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 displayUrl]]);
  XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);

  [CR_BidManagerHelper removeCriteoBidsFromMoPubRequest:mopubBidRequest];

  XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 displayUrl]]);
  XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);
  XCTAssertFalse([mopubBidRequest.keywords containsString:@"crt_"]);
}

- (void)testInterstitialAdControllerAdRemoveCriteoBid {
  MPInterstitialAdController *controller = [[MPInterstitialAdController alloc] init];

  id CR_BidManagerHelperClass = OCMClassMock([CR_BidManagerHelper class]);

  [controller loadAd];

  OCMVerify([CR_BidManagerHelperClass removeCriteoBidsFromMoPubRequest:controller]);
  [CR_BidManagerHelperClass stopMocking];
}

@end
