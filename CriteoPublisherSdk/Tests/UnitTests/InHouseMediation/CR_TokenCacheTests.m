//
//  CR_TokenCacheTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_TokenCache.h"
#import "CRBidToken.h"
#import "CRBidToken+Internal.h"
#import "CR_TokenValue+Testing.h"
#import "CR_CdbBidBuilder.h"
#import "CR_NativeAssets+Testing.h"

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
                                                nativeAssets:nil
                                                impressionId:nil];
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
                                                 nativeAssets:nil
                                                 impressionId:nil];
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
                                                nativeAssets:nil
                                                impressionId:nil];

  CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
  CRBidToken *firstToken = [tokenCache getTokenForBid:firstCdbBid adUnitType:CRAdUnitTypeBanner];
  CRBidToken *secondToken = [tokenCache getTokenForBid:secondCdbBid adUnitType:CRAdUnitTypeBanner];
  CRBidToken *thirdToken = [tokenCache getTokenForBid:thirdCdbBid adUnitType:CRAdUnitTypeBanner];

  CRAdUnit *firstAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid1"
                                                  adUnitType:CRAdUnitTypeBanner];
  CRAdUnit *secondAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid2"
                                                   adUnitType:CRAdUnitTypeBanner];
  CRAdUnit *thirdAdUnit = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid3"
                                                  adUnitType:CRAdUnitTypeBanner];

  XCTAssertFalse([firstToken isEqual:secondToken]);
  XCTAssertFalse([secondToken isEqual:thirdToken]);

  CR_TokenValue *firstExpectedTokenValue = [[CR_TokenValue alloc] initWithCdbBid:firstCdbBid
                                                                          adUnit:firstAdUnit];
  CR_TokenValue *secondExpectedTokenValue = [[CR_TokenValue alloc] initWithCdbBid:secondCdbBid
                                                                           adUnit:secondAdUnit];
  CR_TokenValue *thirdExpectedTokenValue = [[CR_TokenValue alloc] initWithCdbBid:thirdCdbBid
                                                                          adUnit:thirdAdUnit];

  XCTAssertTrue([firstExpectedTokenValue isEqual:[tokenCache getValueForToken:firstToken
                                                                   adUnitType:CRAdUnitTypeBanner]]);
  XCTAssertTrue([secondExpectedTokenValue
      isEqual:[tokenCache getValueForToken:secondToken adUnitType:CRAdUnitTypeBanner]]);
  XCTAssertTrue([thirdExpectedTokenValue isEqual:[tokenCache getValueForToken:thirdToken
                                                                   adUnitType:CRAdUnitTypeBanner]]);
}

- (void)testGetUncachedTokenAndNilToken {
  CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
  CRBidToken *uncachedToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CRBidToken *nilToken = nil;

  XCTAssertNil([tokenCache getValueForToken:uncachedToken adUnitType:CRAdUnitTypeBanner]);
  XCTAssertNil([tokenCache getValueForToken:nilToken adUnitType:CRAdUnitTypeBanner]);
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
                                           nativeAssets:nil
                                           impressionId:nil];

  CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
  CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"adunitid1" adUnitType:CRAdUnitTypeBanner];
  CR_TokenValue *expectedTokenValue = [[CR_TokenValue alloc] initWithCdbBid:cdbBid adUnit:adUnit];
  CRBidToken *token = [tokenCache getTokenForBid:cdbBid adUnitType:CRAdUnitTypeBanner];

  CR_TokenValue *consumedTokenValue = [tokenCache getValueForToken:token
                                                        adUnitType:CRAdUnitTypeBanner];
  XCTAssertTrue([expectedTokenValue isEqual:consumedTokenValue]);
  XCTAssertNil([tokenCache getValueForToken:token adUnitType:CRAdUnitTypeBanner]);
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
  CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Hello" adUnitType:CRAdUnitTypeBanner];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@""
                                                                       adUnit:adUnit
                                                                      expired:YES];
  [tokenCache setTokenMapWithValue:expectedTokenValue forKey:token];
  CR_TokenValue *tokenValue = [tokenCache getValueForToken:token adUnitType:CRAdUnitTypeBanner];
  XCTAssertNil(tokenValue);
  XCTAssertNil([tokenCache tokenValueForKey:token]);
}

- (void)testTokenValueForBidTokenWithDifferentAdUnitType {
  CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Hello"
                                             adUnitType:CRAdUnitTypeInterstitial];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@"" adUnit:adUnit];
  [tokenCache setTokenMapWithValue:expectedTokenValue forKey:token];
  CR_TokenValue *tokenValue = [tokenCache getValueForToken:token adUnitType:CRAdUnitTypeBanner];
  XCTAssertNil(tokenValue);
  XCTAssertEqual([tokenCache tokenValueForKey:token], expectedTokenValue);
}

- (void)testTokenValueForNativeBid {
  CR_TokenCache *tokenCache = [[CR_TokenCache alloc] init];

  CR_NativeAssets *nativeAssets = [CR_NativeAssets nativeAssetsFromCdb];
  CR_CdbBid *bid = CR_CdbBidBuilder.new.displayUrl(nil).nativeAssets(nativeAssets).build;

  CRBidToken *token = [tokenCache getTokenForBid:bid adUnitType:CRAdUnitTypeNative];
  CR_TokenValue *tokenValue = [tokenCache getValueForToken:token adUnitType:CRAdUnitTypeNative];

  XCTAssertNotNil(tokenValue);
  XCTAssertNil(tokenValue.displayUrl);
  XCTAssertEqualObjects(nativeAssets, tokenValue.nativeAssets);
}

@end
