//
//  CR_CacheAdUnitTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_CacheAdUnit.h"
#import "Logging.h"

@interface CR_CacheAdUnitTests : XCTestCase

@end

@implementation CR_CacheAdUnitTests

- (void) testAdUnitHash {
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *third = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:NO];

    XCTAssertEqual(first.hash, second.hash);
    XCTAssertEqual(first.hash, third.hash);
    CLog(@"first.hash = %tu , second.hash = %tu, third.hash = %tu", first.hash, second.hash, third.hash);
}

- (void) testAdUnitHash_2 {
    CGSize sizeFirst = CGSizeMake(400.3f, 150.0f);
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeFirst];
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHashNotEqual {
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    CR_CacheAdUnit *third = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:YES];

    XCTAssertNotEqual(first.hash, second.hash);
    XCTAssertNotEqual(first.hash, third.hash);
    CLog(@"first.hash = %tu , second.hash = %tu, third.hash = %tu", first.hash, second.hash, third.hash);
}

- (void) testAdUnitHashNotEqual_2 {
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CGSize sizeSecond = CGSizeMake(500.8f, 150.0f);
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeSecond];
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitIsEqual {
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *third = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:NO];

    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
    XCTAssertTrue([first isEqual:third]);
    XCTAssertTrue([third isEqual:first]);
    XCTAssertFalse(third.isNative);
}

- (void) testAdUnitIsNotEqual {
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    CR_CacheAdUnit *third = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:YES];

    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);
    XCTAssertFalse([first isEqual:third]);
    XCTAssertFalse([third isEqual:first]);
    XCTAssertTrue(third.isNative);
}

- (void) testAdUnitIsNotEqualWhenSizeNotEqual {
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:800 height:150];

    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);

    CR_CacheAdUnit *third = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *fourth = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:160];

    XCTAssertFalse([third isEqual:fourth]);
    XCTAssertFalse([fourth isEqual:third]);
}

- (void)testNativeAdUnitAndHashIsEqual {
    CR_CacheAdUnit *native_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:YES];
    CR_CacheAdUnit *native_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:YES];

    XCTAssertTrue([native_1 isEqual:native_2]);
    XCTAssertTrue([native_2 isEqual:native_1]);
    XCTAssertEqual(native_1.hash, native_2.hash);
}

- (void)testCopyWithZone {
    CR_CacheAdUnit *adUnit_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:YES];
    CR_CacheAdUnit *adUnit_1Copy = [adUnit_1 copyWithZone:nil];
    XCTAssertTrue([adUnit_1 isEqual:adUnit_1Copy]);

    CR_CacheAdUnit *adUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150)];
    CR_CacheAdUnit *adUnit_2Copy = [adUnit_2 copyWithZone:nil];
    XCTAssertTrue([adUnit_2 isEqual:adUnit_2Copy]);

    CR_CacheAdUnit *adUnit_3 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:320 height:50];
    CR_CacheAdUnit *adUnit_3Copy = [adUnit_3 copyWithZone:nil];
    XCTAssertTrue([adUnit_3 isEqual:adUnit_3Copy]);

    CR_CacheAdUnit *adUnit_4 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(400, 150) isNative:NO];
    CR_CacheAdUnit *adUnit_4Copy = [adUnit_4 copyWithZone:nil];
    XCTAssertTrue([adUnit_4 isEqual:adUnit_4Copy]);
}

@end
