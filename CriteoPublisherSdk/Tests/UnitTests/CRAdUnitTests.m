//
//  CRAdUnitTests.m
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
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"

@interface CRAdUnitTests : XCTestCase

@end

@implementation CRAdUnitTests

- (void)testAdUnitInitialization {
  NSString *expectedAdUnitId = @"expected";
  CRAdUnitType expectedType = CRAdUnitTypeBanner;
  CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:expectedAdUnitId adUnitType:expectedType];
  XCTAssertTrue([[adUnit adUnitId] isEqual:expectedAdUnitId]);
  XCTAssertEqual([adUnit adUnitType], expectedType);
}

- (void)testInvalidAdUnitTypeInInitialization {
  NSString *expectedAdUnitId = @"expected";
  CRAdUnitType invalidType = 3;
  // TODO: have an exception after passing an invalid adunit type
  CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:expectedAdUnitId adUnitType:invalidType];
  XCTAssertTrue([[adUnit adUnitId] isEqual:expectedAdUnitId]);
  XCTAssertEqual([adUnit adUnitType], invalidType);
}

- (void)testSameAdUnitsHaveSameHash {
  CRAdUnit *adUnit1 = [[CRAdUnit alloc] initWithAdUnitId:@"String1" adUnitType:CRAdUnitTypeBanner];
  CRAdUnit *adUnit2 = [[CRAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"]
                                              adUnitType:CRAdUnitTypeBanner];

  XCTAssertEqual(adUnit1.hash, adUnit2.hash);
}

- (void)testSameAdUnitsAreEqual {
  CRAdUnit *adUnit1 = [[CRAdUnit alloc] initWithAdUnitId:@"String1" adUnitType:CRAdUnitTypeBanner];
  CRAdUnit *adUnit2 = [[CRAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"]
                                              adUnitType:CRAdUnitTypeBanner];

  XCTAssert([adUnit1 isEqual:adUnit2]);
  XCTAssert([adUnit2 isEqual:adUnit1]);

  XCTAssert([adUnit1 isEqualToAdUnit:adUnit2]);
  XCTAssert([adUnit2 isEqualToAdUnit:adUnit1]);

  XCTAssertEqualObjects(adUnit1, adUnit2);
}

- (void)testDifferentAdUnitsHaveDifferentHash {
  CRAdUnit *adUnit1 = [[CRAdUnit alloc] initWithAdUnitId:@"String1"
                                              adUnitType:CRAdUnitTypeInterstitial];
  CRAdUnit *adUnit2 = [[CRAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"]
                                              adUnitType:CRAdUnitTypeBanner];
  XCTAssertNotEqual(adUnit1.hash, adUnit2.hash);

  CRAdUnit *adUnit3 = [[CRAdUnit alloc] initWithAdUnitId:@"String1" adUnitType:CRAdUnitTypeBanner];
  CRAdUnit *adUnit4 = [[CRAdUnit alloc] initWithAdUnitId:@"Changed" adUnitType:CRAdUnitTypeBanner];
  XCTAssertNotEqual(adUnit3.hash, adUnit4.hash);
}

- (void)testAdUnitsDifferById {
  CRAdUnit *adUnit1 = [[CRAdUnit alloc] initWithAdUnitId:@"String1" adUnitType:CRAdUnitTypeBanner];
  CRAdUnit *adUnit2 = [[CRAdUnit alloc] initWithAdUnitId:@"Changed" adUnitType:CRAdUnitTypeBanner];

  XCTAssertFalse([adUnit1 isEqual:adUnit2]);
  XCTAssertFalse([adUnit2 isEqual:adUnit1]);

  XCTAssertFalse([adUnit1 isEqualToAdUnit:adUnit2]);
  XCTAssertFalse([adUnit2 isEqualToAdUnit:adUnit1]);

  XCTAssertNotEqualObjects(adUnit1, adUnit2);
}

- (void)testAdUnitsDifferByType {
  CRAdUnit *adUnit1 = [[CRAdUnit alloc] initWithAdUnitId:@"String1" adUnitType:CRAdUnitTypeBanner];
  CRAdUnit *adUnit2 = [[CRAdUnit alloc] initWithAdUnitId:@"String1"
                                              adUnitType:CRAdUnitTypeInterstitial];

  XCTAssertFalse([adUnit1 isEqual:adUnit2]);
  XCTAssertFalse([adUnit2 isEqual:adUnit1]);

  XCTAssertFalse([adUnit1 isEqualToAdUnit:adUnit2]);
  XCTAssertFalse([adUnit2 isEqualToAdUnit:adUnit1]);

  XCTAssertNotEqualObjects(adUnit1, adUnit2);
}

@end
