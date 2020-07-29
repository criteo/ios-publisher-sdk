//
//  NSArray+CriteoTests.m
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
#import "CR_CacheAdUnit.h"
#import "NSError+Criteo.h"
#import "NSArray+Criteo.h"

@interface NSArray_CriteoTests : XCTestCase

@end

@implementation NSArray_CriteoTests

- (void)testSplitIntoChunks {
  MutableCR_CacheAdUnitArray *units = [MutableCR_CacheAdUnitArray new];
  int i;

  // Make a bunch of CR_CacheAdUnit
  for (i = 0; i < 10; i++) {
    [units addObject:[[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1" width:10 height:20 + i]];
  }
  for (int i = 0; i < 4; i++) {
    [units addObject:[[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:10 height:20]];
  }
  for (int i = 0; i < 2; i++) {
    [units addObject:[[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot3" width:10 height:21]];
  }
  for (int i = 4; i < 9; i++) {
    NSString *adUnitId = [NSString stringWithFormat:@"slot%d", i];
    [units addObject:[[CR_CacheAdUnit alloc] initWithAdUnitId:adUnitId width:10 height:21]];
  }

  // Split entire units array into chunks

  NSArray<CR_CacheAdUnitArray *> *batches1 = [units cr_splitIntoChunks:8];
  XCTAssertEqual(batches1.count, 3);
  MutableCR_CacheAdUnitArray *batch0_7 = [MutableCR_CacheAdUnitArray new];
  for (int i = 0; i < 8; i++) {
    [batch0_7 addObject:units[i]];
  }
  XCTAssertTrue([batches1[0] isEqualToArray:batch0_7]);

  MutableCR_CacheAdUnitArray *batch8_15 = [MutableCR_CacheAdUnitArray new];
  for (int i = 8; i < 16; i++) {
    [batch8_15 addObject:units[i]];
  }
  XCTAssertTrue([batches1[1] isEqualToArray:batch8_15]);

  MutableCR_CacheAdUnitArray *batch16_20 = [MutableCR_CacheAdUnitArray new];
  for (int i = 16; i < 21; i++) {
    [batch16_20 addObject:units[i]];
  }
  XCTAssertTrue([batches1[2] isEqualToArray:batch16_20]);

  // Split a group of 3 into batches

  CR_CacheAdUnitArray *units2 = @[ units[0], units[1], units[2] ];
  NSArray<CR_CacheAdUnitArray *> *batches2 = [units2 cr_splitIntoChunks:8];
  XCTAssertEqual(batches2.count, 1);
  XCTAssertTrue([batches2[0] isEqualToArray:units2]);

  // Empty array

  CR_CacheAdUnitArray *units3 = @[];
  NSArray<CR_CacheAdUnitArray *> *batches3 = [units3 cr_splitIntoChunks:8];
  XCTAssertEqual(batches3.count, 0);

  // Array of chunk size elements

  MutableCR_CacheAdUnitArray *units4 = [MutableCR_CacheAdUnitArray new];
  for (int i = 0; i < 8; i++) {
    [units4 addObject:units[i]];
  }
  NSArray<CR_CacheAdUnitArray *> *batches4 = [units4 cr_splitIntoChunks:8];
  XCTAssertEqual(batches4.count, 1);
  XCTAssertTrue([batches4[0] isEqualToArray:units4]);

  // Array of chunk size plus 1 elements

  MutableCR_CacheAdUnitArray *units5 = [MutableCR_CacheAdUnitArray new];
  for (int i = 0; i < 9; i++) {
    [units5 addObject:units[i]];
  }
  NSArray<CR_CacheAdUnitArray *> *batches5 = [units5 cr_splitIntoChunks:8];
  XCTAssertEqual(batches5.count, 2);
  XCTAssertTrue([batches5[0] isEqualToArray:units4]);
  XCTAssertTrue([batches5[1] isEqualToArray:@[ units[8] ]]);
}

- (void)testGroupByOnEmptyArray {
  XCTAssertNoThrow([NSArray.new cr_groupByKey:^id<NSCopying>(id item) {
    return nil;
  }]);
}

- (void)testGroupByOnBasicArray {
  NSArray *input = @[ @1, @2, @2 ];
  NSDictionary *expected = @{@1 : @[ @1 ], @2 : @[ @2, @2 ]};
  NSDictionary *grouped = [input cr_groupByKey:^id<NSCopying>(id item) {
    return item;
  }];
  XCTAssertEqualObjects(grouped, expected);
}

- (void)testGroupByOnArrayWithNilKey {
  XCTAssertThrows([@[ @"dummy" ] cr_groupByKey:^id<NSCopying>(id item) {
    return nil;
  }]);
}

@end
