//
//  CRBidTests.m
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
#import "CRBid+Internal.h"
#import "CRBannerAdUnit.h"
#import "CR_AdUnitHelper.h"
#import "CR_CdbBid.h"
#import "CR_CdbBidBuilder.h"
#import "CR_NativeAssets+Testing.h"

@interface CRBidTests : XCTestCase
@property(nonatomic, strong) CRBid *bid;
@property(nonatomic, strong) CRBannerAdUnit *adUnit;
@property(nonatomic, strong) CR_CdbBid *cdbBid;
@property(nonatomic, strong) CR_CacheAdUnit *cacheAdUnit;
@property(nonatomic, strong) CR_NativeAssets *nativeAssets;
@end

@implementation CRBidTests

#pragma mark - Lifecycle

- (void)setUp {
  self.nativeAssets = [CR_NativeAssets nativeAssetsFromCdb];
  self.adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"" size:CGSizeZero];
  self.cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:self.adUnit];

  CR_CdbBid *validBid =
      CR_CdbBidBuilder.new.adUnit(self.cacheAdUnit).nativeAssets(self.nativeAssets).build;
  [self givenCdbBid:validBid];
}

#pragma mark - Tests

- (void)testPrice_GivenValidBid_ReturnPrice {
  XCTAssertEqual(self.bid.price, self.cdbBid.cpm.doubleValue);
}

- (void)testPrice_GivenConsumedBid_ReturnPrice {
  [self.bid consume];
  XCTAssertEqual(self.bid.price, self.cdbBid.cpm.doubleValue);
}

#pragma mark Consume

- (void)testConsume_GivenValidBid_ReturnBid {
  XCTAssertEqualObjects([self.bid consume], self.cdbBid);
}

- (void)testConsume_AfterConsumingOnce_ReturnNil {
  [self.bid consume];
  XCTAssertNil([self.bid consume]);
}

- (void)testConsume_GivenExpiredBid_ReturnNil {
  CR_CdbBid *expiredBid = CR_CdbBidBuilder.new.adUnit(self.cacheAdUnit).expired().build;
  [self givenCdbBid:expiredBid];
  XCTAssertNil([self.bid consume]);
}

#pragma mark - Private

- (void)givenCdbBid:(CR_CdbBid *)cdbBid {
  self.cdbBid = cdbBid;
  self.bid = [[CRBid alloc] initWithCdbBid:cdbBid adUnit:self.adUnit];
}

@end
