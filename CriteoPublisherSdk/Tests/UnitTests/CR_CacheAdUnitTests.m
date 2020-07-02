//
//  CR_CacheAdUnitTests.m
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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_CacheAdUnit.h"
#import "Logging.h"

@interface CR_CacheAdUnitTests : XCTestCase

@end

@implementation CR_CacheAdUnitTests

- (void)testAdUnitHash {
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              size:CGSizeMake(400, 150)
                                                        adUnitType:CRAdUnitTypeBanner];
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                               size:CGSizeMake(400, 150)
                                                         adUnitType:CRAdUnitTypeBanner];

  XCTAssertEqual(first.hash, second.hash);
  CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void)testAdUnitHash_2 {
  CGSize sizeFirst = CGSizeMake(400.3f, 150.0f);
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              size:sizeFirst
                                                        adUnitType:CRAdUnitTypeBanner];
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              width:400
                                                             height:150];

  XCTAssertEqual(first.hash, second.hash);
  CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void)testAdUnitHashNotEqual {
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                             width:400
                                                            height:150];
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit_1"
                                                              width:400
                                                             height:150];
  CR_CacheAdUnit *third = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              size:CGSizeMake(400, 150)
                                                        adUnitType:CRAdUnitTypeNative];

  XCTAssertNotEqual(first.hash, second.hash);
  XCTAssertNotEqual(first.hash, third.hash);
  CLog(@"first.hash = %tu , second.hash = %tu, third.hash = %tu", first.hash, second.hash,
       third.hash);
}

- (void)testAdUnitHashNotEqual_2 {
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                             width:400
                                                            height:150];
  CGSize sizeSecond = CGSizeMake(500.8f, 150.0f);
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                               size:sizeSecond
                                                         adUnitType:CRAdUnitTypeBanner];

  XCTAssertNotEqual(first.hash, second.hash);
  CLog(@"first.hash = %tu , second.hash = %tu", first.hash, second.hash);
}

- (void)testAdUnitIsEqual {
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                             width:400
                                                            height:150];
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              width:400
                                                             height:150];

  XCTAssertTrue([first isEqual:second]);
  XCTAssertTrue([second isEqual:first]);
}

- (void)testAdUnitIsNotEqual {
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                             width:400
                                                            height:150];
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit_1"
                                                              width:400
                                                             height:150];

  XCTAssertFalse([first isEqual:second]);
  XCTAssertFalse([second isEqual:first]);
}

- (void)testAdUnitIsNotEqualWhenSizeNotEqual {
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                             width:400
                                                            height:150];
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              width:800
                                                             height:150];

  XCTAssertFalse([first isEqual:second]);
  XCTAssertFalse([second isEqual:first]);

  CR_CacheAdUnit *third = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                             width:400
                                                            height:150];
  CR_CacheAdUnit *fourth = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              width:400
                                                             height:160];

  XCTAssertFalse([third isEqual:fourth]);
  XCTAssertFalse([fourth isEqual:third]);
}

- (void)testAdUnitIsNotEqualWhenAdUnitTypeNotEqual {
  CGSize size = CGSizeMake(320, 50);
  CR_CacheAdUnit *first = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                              size:size
                                                        adUnitType:CRAdUnitTypeNative];
  CR_CacheAdUnit *second = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                               size:size
                                                         adUnitType:CRAdUnitTypeInterstitial];

  XCTAssertFalse([first isEqual:second]);
  XCTAssertFalse([second isEqual:first]);
}

- (void)testNativeAdUnitAndHashIsEqual {
  CR_CacheAdUnit *native_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                 size:CGSizeMake(400, 150)
                                                           adUnitType:CRAdUnitTypeNative];
  CR_CacheAdUnit *native_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                 size:CGSizeMake(400, 150)
                                                           adUnitType:CRAdUnitTypeNative];

  XCTAssertTrue([native_1 isEqual:native_2]);
  XCTAssertTrue([native_2 isEqual:native_1]);
  XCTAssertEqual(native_1.hash, native_2.hash);
}

- (void)testCopyWithZone {
  CR_CacheAdUnit *adUnit_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                 size:CGSizeMake(400, 150)
                                                           adUnitType:CRAdUnitTypeBanner];
  CR_CacheAdUnit *adUnit_1Copy = [adUnit_1 copyWithZone:nil];
  XCTAssertTrue([adUnit_1 isEqual:adUnit_1Copy]);

  CR_CacheAdUnit *adUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                 size:CGSizeMake(400, 150)
                                                           adUnitType:CRAdUnitTypeInterstitial];
  CR_CacheAdUnit *adUnit_2Copy = [adUnit_2 copyWithZone:nil];
  XCTAssertTrue([adUnit_2 isEqual:adUnit_2Copy]);

  CR_CacheAdUnit *adUnit_3 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                width:320
                                                               height:50];
  CR_CacheAdUnit *adUnit_3Copy = [adUnit_3 copyWithZone:nil];
  XCTAssertTrue([adUnit_3 isEqual:adUnit_3Copy]);

  CR_CacheAdUnit *adUnit_4 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                 size:CGSizeMake(400, 150)
                                                           adUnitType:CRAdUnitTypeNative];
  CR_CacheAdUnit *adUnit_4Copy = [adUnit_4 copyWithZone:nil];
  XCTAssertTrue([adUnit_4 isEqual:adUnit_4Copy]);
}

@end
