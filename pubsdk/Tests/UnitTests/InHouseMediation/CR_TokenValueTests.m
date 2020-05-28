//
//  CR_TokenValueTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_TokenValue.h"
#import "CR_CdbBid.h"
#import "OCMock.h"

@interface CR_TokenValueTests : XCTestCase

@end

@implementation CR_TokenValueTests

- (void)testTokenValueExpired {
    CR_CdbBid *cdbBid = OCMClassMock([CR_CdbBid class]);
    OCMStub(cdbBid.isExpired).andReturn(YES);

    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];

    CR_TokenValue *tokenValue = [[CR_TokenValue alloc] initWithCdbBid:cdbBid adUnit:adUnit];

    XCTAssertTrue([tokenValue isExpired]);
}

- (void)testTokenValueNotExpired {
    CR_CdbBid *cdbBid = OCMClassMock([CR_CdbBid class]);
    OCMStub(cdbBid.isExpired).andReturn(NO);

    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];

    CR_TokenValue *tokenValue = [[CR_TokenValue alloc] initWithCdbBid:cdbBid adUnit:adUnit];

    XCTAssertFalse([tokenValue isExpired]);
}

@end
