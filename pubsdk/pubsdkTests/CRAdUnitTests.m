//
//  CRAdUnitTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CRAdUnit.h"
#import "Logging.h"

@interface CRAdUnitTests : XCTestCase

@end

@implementation CRAdUnitTests

- (void) testAdUnitHash {
    CRAdUnit *first = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRAdUnit *second = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHash_2 {
    CGSize sizeFirst = CGSizeMake(400.3f, 150.0f);
    CRAdUnit *first = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeFirst];
    CRAdUnit *second = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHashNotEqual {
    CRAdUnit *first = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRAdUnit *second = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHashNotEqual_2 {
    CRAdUnit *first = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CGSize sizeSecond = CGSizeMake(500.8f, 150.0f);
    CRAdUnit *second = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeSecond];
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitIsEqual {
    CRAdUnit *first = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRAdUnit *second = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testAdUnitIsNotEqual {
    CRAdUnit *first = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CRAdUnit *second = [[CRAdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    
    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);
}

@end
