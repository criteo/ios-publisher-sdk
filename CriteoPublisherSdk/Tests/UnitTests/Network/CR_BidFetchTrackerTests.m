//
//  CR_BidFetchTrackerTests.m
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
#import "CR_BidFetchTracker.h"

@interface CR_BidFetchTrackerTests : XCTestCase

@end

@implementation CR_BidFetchTrackerTests

- (void)testBidFetchTrackerCache {
  CR_CacheAdUnit *cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"" width:0 height:0];
  CR_BidFetchTracker *bidFetchTracker = [CR_BidFetchTracker new];
  XCTAssertTrue([bidFetchTracker trySetBidFetchInProgressForAdUnit:cacheAdUnit]);
  XCTAssertFalse([bidFetchTracker trySetBidFetchInProgressForAdUnit:cacheAdUnit]);
  [bidFetchTracker clearBidFetchInProgressForAdUnit:cacheAdUnit];
  XCTAssertTrue([bidFetchTracker trySetBidFetchInProgressForAdUnit:cacheAdUnit]);
}

@end
