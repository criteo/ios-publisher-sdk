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
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
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
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
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
    
    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testAdUnitIsNotEqual {
    CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    
    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);
}

@end
