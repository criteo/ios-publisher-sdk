//
//  CRCacheAdUnitTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CRCacheAdUnit.h"
#import "Logging.h"

@interface CRCacheAdUnitTests : XCTestCase

@end

@implementation CRCacheAdUnitTests

- (void) testAdUnitHash {
    CRCacheAdUnit *first = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRCacheAdUnit *second = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHash_2 {
    CGSize sizeFirst = CGSizeMake(400.3f, 150.0f);
    CRCacheAdUnit *first = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeFirst];
    CRCacheAdUnit *second = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHashNotEqual {
    CRCacheAdUnit *first = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRCacheAdUnit *second = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHashNotEqual_2 {
    CRCacheAdUnit *first = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CGSize sizeSecond = CGSizeMake(500.8f, 150.0f);
    CRCacheAdUnit *second = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeSecond];
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitIsEqual {
    CRCacheAdUnit *first = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRCacheAdUnit *second = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testAdUnitIsNotEqual {
    CRCacheAdUnit *first = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRCacheAdUnit *second = [[CRCacheAdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    
    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);
}

@end
