//
//  NSArray+CriteoTests.m
//  pubsdkTests
//
//  Created by Richard Clark on 9/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_CacheAdUnit.h"
#import "NSError+CRErrors.h"
#import "NSArray+Criteo.h"

@interface NSArray_AdditionsTests : XCTestCase

@end

@implementation NSArray_AdditionsTests

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

    NSArray<CR_CacheAdUnitArray *> *batches1 = [units splitIntoChunks:8];
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

    CR_CacheAdUnitArray *units2 = @[units[0], units[1], units[2]];
    NSArray<CR_CacheAdUnitArray *> *batches2 = [units2 splitIntoChunks:8];
    XCTAssertEqual(batches2.count, 1);
    XCTAssertTrue([batches2[0] isEqualToArray:units2]);

    // Empty array

    CR_CacheAdUnitArray *units3 = @[];
    NSArray<CR_CacheAdUnitArray *> *batches3 = [units3 splitIntoChunks:8];
    XCTAssertEqual(batches3.count, 0);

    // Array of chunk size elements

    MutableCR_CacheAdUnitArray *units4 = [MutableCR_CacheAdUnitArray new];
    for (int i = 0; i < 8; i++) {
        [units4 addObject:units[i]];
    }
    NSArray<CR_CacheAdUnitArray *> *batches4 = [units4 splitIntoChunks:8];
    XCTAssertEqual(batches4.count, 1);
    XCTAssertTrue([batches4[0] isEqualToArray:units4]);

    // Array of chunk size plus 1 elements

    MutableCR_CacheAdUnitArray *units5 = [MutableCR_CacheAdUnitArray new];
    for (int i = 0; i < 9; i++) {
        [units5 addObject:units[i]];
    }
    NSArray<CR_CacheAdUnitArray *> *batches5 = [units5 splitIntoChunks:8];
    XCTAssertEqual(batches5.count, 2);
    XCTAssertTrue([batches5[0] isEqualToArray:units4]);
    XCTAssertTrue([batches5[1] isEqualToArray:@[units[8]]]);
}

@end
