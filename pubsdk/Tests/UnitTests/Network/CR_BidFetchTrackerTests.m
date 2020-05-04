//
//  CR_BidFetchTrackerTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_BidFetchTracker.h"

@interface CR_BidFetchTrackerTests : XCTestCase

@end

@implementation CR_BidFetchTrackerTests

- (void) testBidFetchTrackerCache {
    CR_CacheAdUnit *cacheAdUnit = [CR_CacheAdUnit new];
    CR_BidFetchTracker *bidFetchTracker = [CR_BidFetchTracker new];
    XCTAssertTrue([bidFetchTracker trySetBidFetchInProgressForAdUnit:cacheAdUnit]);
    XCTAssertFalse([bidFetchTracker trySetBidFetchInProgressForAdUnit:cacheAdUnit]);
    [bidFetchTracker clearBidFetchInProgressForAdUnit:cacheAdUnit];
    XCTAssertTrue([bidFetchTracker trySetBidFetchInProgressForAdUnit:cacheAdUnit]);
}

@end
