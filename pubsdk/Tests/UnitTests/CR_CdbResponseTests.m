//
//  CR_CdbResponseTests.m
//  pubsdkTests
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_CdbResponse.h"

@interface CR_CdbResponseTests : XCTestCase

@end

@implementation CR_CdbResponseTests

- (void)testInstanceWithNoParameters {
    XCTAssertNil([CR_CdbResponse responseWithData:[NSData new] receivedAt:nil]);
    XCTAssertNil([CR_CdbResponse responseWithData:nil receivedAt:[NSDate dateWithTimeIntervalSince1970:0]]);
    XCTAssertNil([CR_CdbResponse responseWithData:nil receivedAt:nil]);
}

- (void) testParsingWithNoTimeToNextCall {

    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];
    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_2"
                                                         cpm:@"5.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];


    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":5.12,\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"}]}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(cdbResponse);
    XCTAssertNotNil(cdbResponse.cdbBids);
    XCTAssertEqual(2, cdbResponse.cdbBids.count);
    XCTAssertEqual(0, cdbResponse.timeToNextCall);
    XCTAssertTrue([testBid_1 isEqual:cdbResponse.cdbBids[0]]);
    XCTAssertFalse([testBid_2 isEqual:cdbResponse.cdbBids[1]]);
}

- (void) testParsingWithTimeToNextCall {

    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_2"
                                                         cpm:@"5.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":5.12,\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"}], \"timeToNextCall\":360}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(cdbResponse);
    XCTAssertNotNil(cdbResponse.cdbBids);
    XCTAssertEqual(2, cdbResponse.cdbBids.count);
    XCTAssertEqual(360, cdbResponse.timeToNextCall);
    XCTAssertTrue([testBid_1 isEqual:cdbResponse.cdbBids[0]]);
    XCTAssertFalse([testBid_2 isEqual:cdbResponse.cdbBids[1]]);
}

- (void) testParsingWithOnlyTimeToNextCall {

    NSDate *testDate = [NSDate date];
    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[], \"timeToNextCall\":600}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(cdbResponse);
    XCTAssertNotNil(cdbResponse.cdbBids);
    XCTAssertEqual(0, cdbResponse.cdbBids.count);
    XCTAssertEqual(600, cdbResponse.timeToNextCall);
}

- (void) testParsingWithNoSlots {

    NSDate *testDate = [NSDate date];
    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"timeToNextCall\":720}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(cdbResponse);
    XCTAssertNotNil(cdbResponse.cdbBids);
    XCTAssertEqual(0, cdbResponse.cdbBids.count);
    XCTAssertEqual(720, cdbResponse.timeToNextCall);
}

- (void) testParsingWithNullTimeToNextCall {

    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}], \"timeToNextCall\":null}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(cdbResponse);
    XCTAssertNotNil(cdbResponse.cdbBids);
    XCTAssertEqual(1, cdbResponse.cdbBids.count);
    XCTAssertEqual(0, cdbResponse.timeToNextCall);
    XCTAssertTrue([testBid_1 isEqual:cdbResponse.cdbBids[0]]);

}

- (void) testParsingWithStringTimeToNextCall {

    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate
                                                nativeAssets:nil
                                                impressionId:nil];

    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}], \"timeToNextCall\":\"555\"}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(cdbResponse);
    XCTAssertNotNil(cdbResponse.cdbBids);
    XCTAssertEqual(1, cdbResponse.cdbBids.count);
    XCTAssertEqual(0, cdbResponse.timeToNextCall);
    XCTAssertTrue([testBid_1 isEqual:cdbResponse.cdbBids[0]]);

}

@end
