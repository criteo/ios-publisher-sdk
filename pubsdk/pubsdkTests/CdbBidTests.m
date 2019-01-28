//
//  cbdBidTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "../pubsdk/CdbBid.h"

@interface CdbBidTests : XCTestCase

@end

@implementation CdbBidTests

- (void) testCdbBidIsEqual {
    NSDate *testDate = [NSDate date];
    CdbBid *first = [[CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];
    CdbBid *second = [[CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];

    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testCdbBidIsEqualDuex {
    NSDate *testDate = [NSDate date];
    CdbBid *first = [[CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];
    CdbBid *second = [[CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];

    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testCdbBidIsNotEqual {
    CdbBid *first = [[CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:[NSDate date]];
    CdbBid *second = [[CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:nil ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:[NSDate date]];

    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);
}

- (void) testCdbResponsesFromData {
    // Bid Objects
    NSDate *testDate = [NSDate date];
    CdbBid *testBid_1 = [[CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1" cpm:@(1.1200000047683716) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:nil insertTime:testDate];
    CdbBid *testBid_2 = [[CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_2" cpm:@(5.1200000012345678) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />" displayUrl:nil insertTime:testDate];

    CdbBid *testBid_3 = [[CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_3" cpm:@(5.1200000012345678) currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />" displayUrl:nil insertTime:testDate];

    CdbBid *testBid_4 = [[CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_4" cpm:nil currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />" displayUrl:nil insertTime:testDate];

    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.1200000047683716,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"creative\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":5.1200000012345678,\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"creative\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_3\",\"zoneId\": 497747,\"cpm\":1.1200000047683716,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"creative\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_4\",\"zoneId\": 497747,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"creative\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *testBids = [CdbBid getCdbResponsesFromData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(testBids);
    XCTAssertNotEqual(0, [testBids count]);
    XCTAssertTrue([testBid_1 isEqual:testBids[0]]);
    // the json response is missing ttl
    XCTAssertFalse([testBid_2 isEqual:testBids[1]]);
    // the creative string is mismatched
    XCTAssertFalse([testBid_3 isEqual:testBids[2]]);
    // missing cpm
    XCTAssertFalse([testBid_4 isEqual:testBids[3]]);
}

- (void) testBidIsExpired {
    CdbBid *testBid = [[CdbBid alloc] initWithZoneId:nil placementId:@"a_test_placement" cpm:@(0.0312) currency:@"USD" width:@(300) height:@(200) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-400]];
    XCTAssertTrue([testBid isExpired]);
}

- (void) testBidIsNotExpired {
    CdbBid *testBid = [[CdbBid alloc] initWithZoneId:nil placementId:@"a_test_placement" cpm:@(0.0312) currency:@"USD" width:@(300) height:@(200) ttl:200 creative:nil displayUrl:@"https://someUrl.com" insertTime:[[NSDate alloc] initWithTimeIntervalSinceNow:-100]];
    XCTAssertFalse([testBid isExpired]);
}
@end
