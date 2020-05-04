//
//  CR_TokenValueTests.m
//  pubsdkTests
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_TokenValue.h"
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"

@interface CR_TokenValueTests : XCTestCase

@end

@implementation CR_TokenValueTests

- (void)testTokenValueInitialization {
    NSString *expectedDisplayURL = @"expectedDisplayURL";
    NSDate *expectedInsertTime = [NSDate date];
    NSTimeInterval expectedTtl = 500;
    CRAdUnitType expectedAdUnitType = CRAdUnitTypeBanner;
    NSString *expectedAdUnitId = @"adunittestid1";
    CRAdUnit *expectedAdUnit = [[CRAdUnit alloc] initWithAdUnitId:expectedAdUnitId adUnitType:expectedAdUnitType];
    CR_TokenValue *tokenValue = [[CR_TokenValue alloc] initWithDisplayURL:expectedDisplayURL insertTime:expectedInsertTime ttl:expectedTtl adUnit:expectedAdUnit];
    XCTAssertEqualObjects(tokenValue.displayUrl, expectedDisplayURL);
    XCTAssertEqual(tokenValue.ttl, expectedTtl);
    XCTAssertEqualObjects(tokenValue.insertTime, expectedInsertTime);
    XCTAssertEqual(tokenValue.adUnit.adUnitType, expectedAdUnitType);
    XCTAssertEqualObjects(tokenValue.adUnit.adUnitId, expectedAdUnitId);
    XCTAssertEqualObjects(tokenValue.adUnit, expectedAdUnit);
}

- (void)testTokenValueExpired {
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *tokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-400]
                                                                       ttl:200
                                                                    adUnit:adUnit];
    XCTAssertTrue([tokenValue isExpired]);
}

- (void)testTokenValueNotExpired {
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *tokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                               insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-100]
                                                                      ttl:200
                                                                   adUnit:adUnit];
    XCTAssertFalse([tokenValue isExpired]);
}

- (void)testSameTokenValues {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-100];
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *firstTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                    insertTime:date
                                                                           ttl:200
                                                                        adUnit:adUnit];
    CR_TokenValue *secondTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                     insertTime:date
                                                                            ttl:200
                                                                         adUnit:adUnit];
    XCTAssertTrue([firstTokenValue isEqual:secondTokenValue]);
}

- (void)testDifferentURL {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-100];
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *firstTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                    insertTime:date
                                                                           ttl:200
                                                                        adUnit:adUnit];
    CR_TokenValue *secondTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"456"
                                                                     insertTime:date
                                                                            ttl:200
                                                                         adUnit:adUnit];
    XCTAssertFalse([firstTokenValue isEqual:secondTokenValue]);
}

- (void)testDifferentInsertTime {
    NSDate *date1 = [[NSDate alloc] initWithTimeIntervalSinceNow:-100];
    NSDate *date2 = [[NSDate alloc] initWithTimeIntervalSinceNow:-500];
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *firstTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                    insertTime:date1
                                                                           ttl:200
                                                                        adUnit:adUnit];
    CR_TokenValue *secondTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                     insertTime:date2
                                                                            ttl:200
                                                                         adUnit:adUnit];
    XCTAssertFalse([firstTokenValue isEqual:secondTokenValue]);
}

- (void)testDifferentTtl {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-100];
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *firstTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                    insertTime:date
                                                                           ttl:200
                                                                        adUnit:adUnit];
    CR_TokenValue *secondTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                     insertTime:date
                                                                            ttl:206
                                                                         adUnit:adUnit];
    XCTAssertFalse([firstTokenValue isEqual:secondTokenValue]);
}

- (void)testDifferentAdUnit {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-100];
    CRAdUnit *adUnit1 = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CRAdUnit *adUnit2 = [[CRAdUnit alloc] initWithAdUnitId:@"Heliosxxx" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *firstTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                    insertTime:date
                                                                           ttl:200
                                                                        adUnit:adUnit1];
    CR_TokenValue *secondTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                     insertTime:date
                                                                            ttl:206
                                                                         adUnit:adUnit2];
    XCTAssertFalse([firstTokenValue isEqual:secondTokenValue]);
}

- (void)testNullTokenValue {
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *firstTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                    insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-100]
                                                                           ttl:200
                                                                        adUnit:adUnit];
    CR_TokenValue *secondTokenValue = NULL;
    XCTAssertFalse([firstTokenValue isEqual:secondTokenValue]);
    XCTAssertFalse([firstTokenValue isEqual:nil]);
}

- (void)testDifferentObjectType {
    CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *firstTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"123"
                                                                    insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-100]
                                                                           ttl:200
                                                                        adUnit:adUnit];
    NSString *fakeTokenValue = @"fake";
    XCTAssertFalse([firstTokenValue isEqual:fakeTokenValue]);
}

@end
