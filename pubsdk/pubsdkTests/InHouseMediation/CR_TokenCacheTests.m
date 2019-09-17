//
//  CR_TokenCacheTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 6/10/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_TokenCache.h"
#import "CRAdUnit+Internal.h"
#import "CRBidToken.h"
#import "CRBidToken+Internal.h"

@interface CR_TokenCacheTests : XCTestCase

@end

@implementation CR_TokenCacheTests

- (void)testGetTokenForBidAndGetValueForToken {
    NSDate *firstDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-400];
    NSDate *secondDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-300];
    NSDate *thirdDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-200];

    CR_CdbBid *firstCdbBid = [[CR_CdbBid alloc] initWithZoneId:@(1111)
                                                   placementId:@"adunitid1"
                                                           cpm:@"1.00"
                                                      currency:@"EUR"
                                                         width:@(300)
                                                        height:@(250)
                                                           ttl:4000
                                                      creative:@"someTag1"
                                                    displayUrl:@"someJS1"
                                                    insertTime:firstDate
                                                  nativeAssets:nil];
    CR_CdbBid *secondCdbBid = [[CR_CdbBid alloc] initWithZoneId:@(2222)
                                                    placementId:@"adunitid2"
                                                            cpm:@"2.00"
                                                       currency:@"EUR"
                                                          width:@(300)
                                                         height:@(250)
                                                            ttl:5000
                                                       creative:@"someTag2"
                                                     displayUrl:@"someJS2"
                                                     insertTime:secondDate
                                                   nativeAssets:nil];
    CR_CdbBid *thirdCdbBid = [[CR_CdbBid alloc] initWithZoneId:@(3333)
                                                   placementId:@"adunitid3"
                                                           cpm:@"3.00"
                                                      currency:@"EUR"
                                                         width:@(300)
                                                        height:@(250)
                                                           ttl:6000
                                                      creative:@"someTag3"
                                                    displayUrl:@"someJS3"
                                                    insertTime:thirdDate
                                                  nativeAssets:nil];

    CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
    CRBidToken *firstToken = [tokenCache getTokenForBid:firstCdbBid adUnitType:CRAdUnitTypeBanner];
    CRBidToken *secondToken = [tokenCache getTokenForBid:secondCdbBid adUnitType:CRAdUnitTypeBanner];
    CRBidToken *thirdToken = [tokenCache getTokenForBid:thirdCdbBid adUnitType:CRAdUnitTypeBanner];

    XCTAssertFalse([firstToken isEqual:secondToken]);
    XCTAssertFalse([secondToken isEqual:thirdToken]);

    CR_TokenValue *firstExpectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"someJS1" insertTime:firstDate ttl:4000 adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *secondExpectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"someJS2" insertTime:secondDate ttl:5000 adUnitType:CRAdUnitTypeBanner];
    CR_TokenValue *thirdExpectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"someJS3" insertTime:thirdDate ttl:6000 adUnitType:CRAdUnitTypeBanner];

    XCTAssertTrue([firstExpectedTokenValue isEqual:[tokenCache getValueForToken:firstToken
                                                                     adUnitType:CRAdUnitTypeBanner]]);
    XCTAssertTrue([secondExpectedTokenValue isEqual:[tokenCache getValueForToken:secondToken
                                                                      adUnitType:CRAdUnitTypeBanner]]);
    XCTAssertTrue([thirdExpectedTokenValue isEqual:[tokenCache getValueForToken:thirdToken
                                                                     adUnitType:CRAdUnitTypeBanner]]);
}

- (void)testGetUncachedTokenAndNilToken {
    CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
    CRBidToken *uncachedToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CRBidToken *nilToken = nil;

    XCTAssertNil([tokenCache getValueForToken:uncachedToken
                                   adUnitType:CRAdUnitTypeBanner]);
    XCTAssertNil([tokenCache getValueForToken:nilToken
                                   adUnitType:CRAdUnitTypeBanner]);
}

- (void)testGetConsumedToken {
    NSDate *firstDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-400];
    CR_CdbBid *cdbBid = [[CR_CdbBid alloc] initWithZoneId:@(1111)
                                              placementId:@"adunitid1"
                                                      cpm:@"1.00"
                                                 currency:@"EUR"
                                                    width:@(300)
                                                   height:@(250)
                                                      ttl:4000
                                                 creative:@"someTag1"
                                               displayUrl:@"someJS1"
                                               insertTime:firstDate
                                             nativeAssets:nil];


    CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@"someJS1" insertTime:firstDate ttl:4000 adUnitType:CRAdUnitTypeBanner];
    CRBidToken *token = [tokenCache getTokenForBid:cdbBid adUnitType:CRAdUnitTypeBanner];

    CR_TokenValue *consumedTokenValue = [tokenCache getValueForToken:token
                                                          adUnitType:CRAdUnitTypeBanner];
    XCTAssertTrue([expectedTokenValue isEqual:consumedTokenValue]);
    XCTAssertNil([tokenCache getValueForToken:token
                                   adUnitType:CRAdUnitTypeBanner]);
}

- (void)testGettingTokenFromNilBid {
    CR_CdbBid *cdbBid = nil;
    CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
    CRBidToken *token = [tokenCache getTokenForBid:cdbBid adUnitType:CRAdUnitTypeBanner];

    XCTAssertNil(token);
}

- (void)testTokenValueForExpiredBidToken {
    CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
    CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@""
                                                                       insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-400]
                                                                              ttl:200
                                                                       adUnitType:CRAdUnitTypeBanner];
    [tokenCache setTokenMapWithValue:expectedTokenValue
                              forKey:token];
    CR_TokenValue *tokenValue = [tokenCache getValueForToken:token
                                                  adUnitType:CRAdUnitTypeBanner];
    XCTAssertNil(tokenValue);
    XCTAssertNil([tokenCache tokenValueForKey:token]);
}

- (void)testTokenValueForBidTokenWithDifferentAdUnitType {
    CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
    CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithDisplayURL:@""
                                                                       insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-400]
                                                                              ttl:200
                                                                       adUnitType:CRAdUnitTypeInterstitial];
    [tokenCache setTokenMapWithValue:expectedTokenValue
                              forKey:token];
    CR_TokenValue *tokenValue = [tokenCache getValueForToken:token
                                                  adUnitType:CRAdUnitTypeBanner];
    XCTAssertNil(tokenValue);
    XCTAssertEqual([tokenCache tokenValueForKey:token], expectedTokenValue);
}



@end
