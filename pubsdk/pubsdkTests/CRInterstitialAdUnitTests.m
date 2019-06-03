//
//  CRInterstitialAdUnitTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
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
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:expectedAdUnitId];
    XCTAssertTrue([[interstitialAdUnit adUnitId] isEqual:expectedAdUnitId]);
    XCTAssertEqual([interstitialAdUnit adUnitType], expectedType);
}

@end
