//
//  CR_CbdBidTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_CdbBid.h"

@interface CR_CdbBidTests : XCTestCase

@end

@implementation CR_CdbBidTests

- (void) testCdbBidIsEqual {
    NSDate *testDate = [NSDate date];
    CR_CdbBid *first = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];
    CR_CdbBid *second = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];

    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testCdbBidIsEqualDuex {
    NSDate *testDate = [NSDate date];
    CR_CdbBid *first = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];
    CR_CdbBid *second = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:testDate];

    XCTAssertTrue([first isEqual:second]);
    XCTAssertTrue([second isEqual:first]);
}

- (void) testCdbBidIsNotEqual {
    CR_CdbBid *first = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:[NSDate date]];
    CR_CdbBid *second = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:nil ttl:600 creative:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />" displayUrl:@"" insertTime:[NSDate date]];

    XCTAssertFalse([first isEqual:second]);
    XCTAssertFalse([second isEqual:first]);
}

- (void) testCdbResponsesForData {
    // Bid Objects
    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate];

    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_2"
                                                         cpm:@"5.12" currency:@"EUR"
                                                       width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate];

    CR_CdbBid *testBid_3 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_3"
                                                         cpm:@"5.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate];

    CR_CdbBid *testBid_4 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_4"
                                                         cpm:nil currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate];

    // Json response from CDB
    // The cpm is a number
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":5.12,\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_3\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_4\",\"zoneId\": 497747,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";

    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *testBids = [CR_CdbBid getCdbResponsesForData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(testBids);
    XCTAssertEqual(4, [testBids count]);
    XCTAssertTrue([testBid_1 isEqual:testBids[0]]);
    // the json response is missing ttl
    XCTAssertFalse([testBid_2 isEqual:testBids[1]]);
    // the creative string is mismatched
    XCTAssertFalse([testBid_3 isEqual:testBids[2]]);
    // missing cpm
    XCTAssertFalse([testBid_4 isEqual:testBids[3]]);
}

- (void) testCdbResponsesForDataWhenCpmIsAString {
    // Bid Objects
    NSDate *testDate = [NSDate date];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747) placementId:@"adunitid_1"
                                                         cpm:@"1.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:testDate];

    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_2"
                                                         cpm:@"5.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate];

    CR_CdbBid *testBid_3 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_3"
                                                         cpm:@"5.12" currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate];

    CR_CdbBid *testBid_4 = [[CR_CdbBid alloc] initWithZoneId:@(1234567) placementId:@"adunitid_4"
                                                         cpm:nil currency:@"EUR" width:@(300) height:@(250) ttl:600
                                                    creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                                                  insertTime:testDate];

    // Json response from CDB
    // The CPM is a string
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":\"1.12\",\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":\"5.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_3\",\"zoneId\": 497747,\"cpm\":\"1.12\",\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_4\",\"zoneId\": 497747,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";
    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *testBids = [CR_CdbBid getCdbResponsesForData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(testBids);
    XCTAssertEqual(4, [testBids count]);
    XCTAssertTrue([testBid_1 isEqual:testBids[0]]);
    // the json response is missing ttl
    XCTAssertFalse([testBid_2 isEqual:testBids[1]]);
    // the creative string is mismatched
    XCTAssertFalse([testBid_3 isEqual:testBids[2]]);
    // missing cpm
    XCTAssertFalse([testBid_4 isEqual:testBids[3]]);
}

- (CR_CdbBid*) testBidWithTTL:(NSTimeInterval)ttl insertTimeDiff:(NSTimeInterval)diff
{
    return [[CR_CdbBid alloc] initWithZoneId:nil
                                 placementId:@"a_test_placement"
                                         cpm:@"0.0312"
                                    currency:@"USD"
                                       width:@(300)
                                      height:@(200)
                                         ttl:ttl
                                    creative:nil
                                  displayUrl:@"https://someUrl.com"
                                  insertTime:[NSDate dateWithTimeIntervalSinceNow:diff]];
}


- (void) testBidIsExpired {
    CR_CdbBid *testBid = [self testBidWithTTL:200 insertTimeDiff:-400];
    XCTAssertTrue(testBid.isExpired);
}

- (void) testTtlLTEZeroIsAlwaysExpired {
    CR_CdbBid *testBid = [self testBidWithTTL:0 insertTimeDiff:0];
    XCTAssertTrue(testBid.isExpired);

    CR_CdbBid *testBid2 = [self testBidWithTTL:0 insertTimeDiff:-100];
    XCTAssertTrue(testBid2.isExpired);

    CR_CdbBid *testBid3 = [self testBidWithTTL:0 insertTimeDiff:100];
    XCTAssertTrue(testBid3.isExpired);

    CR_CdbBid *testBid4 = [self testBidWithTTL:-100 insertTimeDiff:0];
    XCTAssertTrue(testBid4.isExpired);

    CR_CdbBid *testBid5 = [self testBidWithTTL:-100 insertTimeDiff:-100];
    XCTAssertTrue(testBid5.isExpired);

    CR_CdbBid *testBid6 = [self testBidWithTTL:-100 insertTimeDiff:100];
    XCTAssertTrue(testBid6.isExpired);
}

- (void) testBidIsNotExpired {
    CR_CdbBid *testBid = [self testBidWithTTL:200 insertTimeDiff:-100];
    XCTAssertFalse(testBid.isExpired);
}

- (void) testDfpCompatibleUrlIsDoubleUrlEncodedBase64
{
    NSString *displayUrl = @"https://ads.us.criteo.com/delivery/r/ajs.php?did=5c560a19383b7ad93bb37508deb03a00&u=%7CHX1eM0zpPitVbf0xT24vaM6U4AiY1TeYgfjDUVVbdu4%3D%7C&c1=eG9IAZIK2MKnlif_A3VZ1-8PEx5_bFVofQVrPPiKhda8JkCsKWBsD2zYvC_F9owWsiKQANPjzJs2iM3m5bCHei3w1zNKxtB3Cx_TBleNKtL5VK1aqyK68XTa0A43qlwLNaStT5NXB3Mz7kx6fDZ20Rh6eAGAW2F9SXVN_7xiLgP288-4OqtK-R7pziZDS04LRUhkL7ohLmAFFyVuwQTREHbpx-4NoonsiQRHKn7ZkuIqZR_rqEewHQ2YowxbI3EOowxo6OV50faWCc7QO5M388FHv8NxeOgOH03LHZT_a2PEKF1xh0-G_qdu5wiyGjJYyPEoNVxB0OaEnDaFVtM7cVaHDm4jrjKlfFhtIGuJb8mg2EeHN0mhUL_0eyv9xWUUQ6osYh3B-jiawHq4592kDDCpS2kYYeqR073IOoRNFNRCR7Fnl0yhIA";

    NSString *doubleUrlEncodedBase64DisplayUrl = @"aHR0cHM6Ly9hZHMudXMuY3JpdGVvLmNvbS9kZWxpdmVyeS9yL2Fqcy5waHA%252FZGlkPTVjNTYwYTE5MzgzYjdhZDkzYmIzNzUwOGRlYjAzYTAwJnU9JTdDSFgxZU0wenBQaXRWYmYweFQyNHZhTTZVNEFpWTFUZVlnZmpEVVZWYmR1NCUzRCU3QyZjMT1lRzlJQVpJSzJNS25saWZfQTNWWjEtOFBFeDVfYkZWb2ZRVnJQUGlLaGRhOEprQ3NLV0JzRDJ6WXZDX0Y5b3dXc2lLUUFOUGp6SnMyaU0zbTViQ0hlaTN3MXpOS3h0QjNDeF9UQmxlTkt0TDVWSzFhcXlLNjhYVGEwQTQzcWx3TE5hU3RUNU5YQjNNejdreDZmRFoyMFJoNmVBR0FXMkY5U1hWTl83eGlMZ1AyODgtNE9xdEstUjdwemlaRFMwNExSVWhrTDdvaExtQUZGeVZ1d1FUUkVIYnB4LTROb29uc2lRUkhLbjdaa3VJcVpSX3JxRWV3SFEyWW93eGJJM0VPb3d4bzZPVjUwZmFXQ2M3UU81TTM4OEZIdjhOeGVPZ09IMDNMSFpUX2EyUEVLRjF4aDAtR19xZHU1d2l5R2pKWXlQRW9OVnhCME9hRW5EYUZWdE03Y1ZhSERtNGpyaktsZkZodElHdUpiOG1nMkVlSE4wbWhVTF8wZXl2OXhXVVVRNm9zWWgzQi1qaWF3SHE0NTkya0REQ3BTMmtZWWVxUjA3M0lPb1JORk5SQ1I3Rm5sMHloSUE%253D";

    CR_CdbBid *testBid = [[CR_CdbBid alloc] initWithZoneId:nil
                                               placementId:nil
                                                       cpm:nil
                                                  currency:nil
                                                     width:nil
                                                    height:nil
                                                       ttl:0.0
                                                  creative:nil
                                                displayUrl:displayUrl
                                                insertTime:nil];

    XCTAssertEqualObjects(displayUrl, testBid.displayUrl, @"displayUrl property should not alter displayUrl");
    XCTAssertEqualObjects(doubleUrlEncodedBase64DisplayUrl, testBid.dfpCompatibleDisplayUrl, @"dfpCompatibleDisplayUrl property is not a properly encoded version of displayUrl");
}

- (void) testCdbResponsesForDataForBidCachingCases {
    // Bid Objects
    NSDate *testDate = [NSDate date];
    //case when no bid : cpm = 0 and ttl = 0
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_1"
                                                         cpm:@"0"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:0
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate];

    //case when silent mode : cpm = 0 and ttl > 0
    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_2"
                                                         cpm:@"0"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:900
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate];

    //case when bid : cpm > 0 and ttl = 0, but ttl set to 900
    CR_CdbBid *testBid_3 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_3"
                                                         cpm:@"1.2"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:900
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate];

    //case when bid caching : cpm > 0 and ttl > 0
    CR_CdbBid *testBid_4 = [[CR_CdbBid alloc] initWithZoneId:@(497747)
                                                 placementId:@"adunitid_4"
                                                         cpm:@"1.2"
                                                    currency:@"EUR"
                                                       width:@(300)
                                                      height:@(250)
                                                         ttl:700
                                                    creative:nil
                                                  displayUrl:@""
                                                  insertTime:testDate];

    // Json response from CDB
    // The cpm is a number
    NSString *rawJsonCdbResponse =
    @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":0,\"currency\":\"EUR\", \"ttl\":0, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 497747,\"cpm\":0,\"currency\":\"EUR\", \"ttl\":900, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"},\
    {\"placementId\": \"adunitid_3\",\"zoneId\": 497747,\"cpm\":1.2,\"currency\":\"EUR\", \"ttl\":0, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"},\
    {\"placementId\": \"adunitid_4\",\"zoneId\": 497747,\"cpm\":1.2,\"currency\":\"EUR\", \"ttl\":700, \"width\": 300,\"height\": 250,\"displayUrl\": \"\"}]}";

    NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *testBids = [CR_CdbBid getCdbResponsesForData:cdbApiResponse receivedAt:testDate];
    XCTAssertNotNil(testBids);
    XCTAssertEqual(4, [testBids count]);
    XCTAssertTrue([testBid_1 isEqual:testBids[0]]);
    // the json response is missing ttl
    XCTAssertTrue([testBid_2 isEqual:testBids[1]]);
    // the creative string is mismatched
    XCTAssertTrue([testBid_3 isEqual:testBids[2]]);
    // missing cpm
    XCTAssertTrue([testBid_4 isEqual:testBids[3]]);

}

@end
