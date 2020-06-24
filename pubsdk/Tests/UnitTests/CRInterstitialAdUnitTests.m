//
//  CRInterstitialAdUnitTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRInterstitialAdUnit.h"
#import "CRAdUnit+Internal.h"

@interface CRInterstitialAdUnitTests : XCTestCase

@end

@implementation CRInterstitialAdUnitTests

- (void)testInterstitialAdUnitInitialization {
  NSString *expectedAdUnitId = @"expected";
  CRAdUnitType expectedType = CRAdUnitTypeInterstitial;
  CRInterstitialAdUnit *interstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:expectedAdUnitId];
  XCTAssertTrue([[interstitialAdUnit adUnitId] isEqual:expectedAdUnitId]);
  XCTAssertEqual([interstitialAdUnit adUnitType], expectedType);
}

- (void)testSameAdUnitsHaveSameHash {
  CRInterstitialAdUnit *adUnit1 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"String1"];
  CRInterstitialAdUnit *adUnit2 =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"]];

  XCTAssertEqual(adUnit1.hash, adUnit2.hash);
}

- (void)testSameAdUnitsAreEqual {
  CRInterstitialAdUnit *adUnit1 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"String1"];
  CRInterstitialAdUnit *adUnit2 =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:[@"Str" stringByAppendingString:@"ing1"]];

  XCTAssert([adUnit1 isEqual:adUnit2]);
  XCTAssert([adUnit2 isEqual:adUnit1]);

  XCTAssert([adUnit1 isEqualToAdUnit:adUnit2]);
  XCTAssert([adUnit2 isEqualToAdUnit:adUnit1]);

  XCTAssertEqualObjects(adUnit1, adUnit2);
}

- (void)testDifferentAdUnitsHaveDifferentHash {
  CRInterstitialAdUnit *adUnit1 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"String1"];
  CRInterstitialAdUnit *adUnit2 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Changed"];

  XCTAssertNotEqual(adUnit1.hash, adUnit2.hash);
}

- (void)testDifferentAdUnitsAreNotEqual {
  CRInterstitialAdUnit *adUnit1 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"String1"];
  CRInterstitialAdUnit *adUnit2 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Changed"];

  XCTAssertFalse([adUnit1 isEqual:adUnit2]);
  XCTAssertFalse([adUnit2 isEqual:adUnit1]);

  XCTAssertFalse([adUnit1 isEqualToInterstitialAdUnit:adUnit2]);
  XCTAssertFalse([adUnit2 isEqualToInterstitialAdUnit:adUnit1]);

  XCTAssertNotEqualObjects(adUnit1, adUnit2);
}

@end
