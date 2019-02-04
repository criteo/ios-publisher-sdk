//
//  adUnitTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "AdUnit.h"
#import "Logging.h"

@interface AdUnitTests : XCTestCase

@end

@implementation AdUnitTests

- (void) testAdUnitHash {
    AdUnit *first = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    AdUnit *second = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHash_2 {
    CGSize sizeFirst = CGSizeMake(400.3f, 150.0f);
    AdUnit *first = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeFirst];
    AdUnit *second = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHashNotEqual {
    AdUnit *first = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    AdUnit *second = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitHashNotEqual_2 {
    AdUnit *first = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    CGSize sizeSecond = CGSizeMake(500.8f, 150.0f);
    AdUnit *second = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" size:sizeSecond];
    
    XCTAssertNotEqual(first.hash, second.hash);
    CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void) testAdUnitIsEqual {
    AdUnit *first = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    AdUnit *second = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    
    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testAdUnitIsNotEqual {
    AdUnit *first = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit" width:400 height:150];
    AdUnit *second = [[AdUnit alloc] initWithAdUnitId:@"testAdUnit_1" width:400 height:150];
    
    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);
}

@end
