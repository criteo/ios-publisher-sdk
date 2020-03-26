//
//  CR_BidRequestSerializerTests.m
//  pubsdk
//
//  Created by Romain Lofaso on 3/26/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_BidRequestSerializer.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbRequest.h"

@interface CR_BidRequestSerializerTests : XCTestCase

@property (strong, nonatomic, readonly) CR_BidRequestSerializer *serializer;

@end

@implementation CR_BidRequestSerializerTests

- (void)setUp {
    _serializer = [[CR_BidRequestSerializer alloc] init];
}

#pragma mark - Tests to be refactored

- (void)testSlotsForRequest {
    CR_CacheAdUnit *adUnit1  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1" width:42 height:33];
    CR_CacheAdUnit *adUnit2  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:42 height:33];
    CR_CacheAdUnit *adUnit3  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:43 height:33];
    CR_CacheAdUnitArray *adUnits = @[adUnit1, adUnit2, adUnit3];
    CR_CdbRequest *cdbRequest = [[CR_CdbRequest alloc] initWithAdUnits:adUnits];
    NSArray *slots = [self.serializer slotsWithCdbRequest:cdbRequest];
    XCTAssertEqual(slots.count, adUnits.count);
    for (int i = 0; i < adUnits.count; i++) {
        NSDictionary *slot = slots[i];
        CR_CacheAdUnit *adUnit = adUnits[i];
        XCTAssertTrue([slot[@"placementId"] isEqualToString:adUnit.adUnitId]);
        NSArray *sizes = slot[@"sizes"];
        XCTAssertEqual(sizes.count, 1);
        XCTAssertTrue([sizes[0] isEqualToString:adUnit.cdbSize]);
    }
}

- (void)testNativeSlotForRequest {
    CR_CacheAdUnit *nativeAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeNative];
    CR_CdbRequest *cdbRequest = [[CR_CdbRequest alloc] initWithAdUnits:@[nativeAdUnit]];
    NSArray *slots = [self.serializer slotsWithCdbRequest:cdbRequest];
    XCTAssertTrue([slots[0][@"placementId"] isEqualToString:nativeAdUnit.adUnitId]);
    XCTAssertTrue([slots[0][@"sizes"] isEqual:@[nativeAdUnit.cdbSize]]);
    XCTAssertTrue(slots[0][@"isNative"]);

    CR_CacheAdUnit *nonNativeAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeInterstitial];
    CR_CdbRequest *cdbRequest2 = [[CR_CdbRequest alloc] initWithAdUnits:@[nonNativeAdUnit]];
    NSArray *nonNativeSlots = [self.serializer slotsWithCdbRequest:cdbRequest2];
    XCTAssertTrue([nonNativeSlots[0][@"placementId"] isEqualToString:nonNativeAdUnit.adUnitId]);
    XCTAssertTrue([nonNativeSlots[0][@"sizes"] isEqual:@[nonNativeAdUnit.cdbSize]]);
    XCTAssertNil(nonNativeSlots[0][@"isNative"]);
}

@end
