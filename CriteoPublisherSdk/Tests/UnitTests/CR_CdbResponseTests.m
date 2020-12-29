//
//  CR_CdbResponseTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_CdbResponse.h"

@interface CR_CdbResponseTests : XCTestCase
@property(nonatomic, strong) NSDate *testDate;
@property(nonatomic, strong) CR_CdbBid *testBid1;
@property(nonatomic, strong) CR_CdbBid *testBid2;
@end

@implementation CR_CdbResponseTests

#pragma mark - Lifecycle

- (void)setUp {
  self.testDate = [NSDate date];
  self.testBid1 = [[CR_CdbBid alloc]
             initWithZoneId:@(497747)
                placementId:@"adunitid_1"
                        cpm:@"1.12"
                   currency:@"EUR"
                      width:@(300)
                     height:@(250)
                        ttl:600
                   creative:nil
                 displayUrl:
                     @"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                 insertTime:self.testDate
               nativeAssets:nil
               impressionId:nil
      skAdNetworkParameters:nil];
  self.testBid2 = [[CR_CdbBid alloc]
             initWithZoneId:@(1234567)
                placementId:@"adunitid_2"
                        cpm:@"5.12"
                   currency:@"EUR"
                      width:@(300)
                     height:@(250)
                        ttl:600
                   creative:nil
                 displayUrl:
                     @"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />"
                 insertTime:self.testDate
               nativeAssets:nil
               impressionId:nil
      skAdNetworkParameters:nil];
}

#pragma mark - Tests
#pragma mark Init

- (void)testInitWithNoParameters {
  XCTAssertNil([CR_CdbResponse responseWithData:[NSData new] receivedAt:nil]);
  XCTAssertNil([CR_CdbResponse responseWithData:nil
                                     receivedAt:[NSDate dateWithTimeIntervalSince1970:0]]);
  XCTAssertNil([CR_CdbResponse responseWithData:nil receivedAt:nil]);
}

#pragma mark Time to next call

- (void)testParsingWithNoTimeToNextCall {
  // Json response from CDB
  NSString *rawJsonCdbResponse =
      @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":5.12,\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"}]}";
  NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

  CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse
                                                      receivedAt:self.testDate];
  XCTAssertNotNil(cdbResponse);
  XCTAssertNotNil(cdbResponse.cdbBids);
  XCTAssertEqual(2, cdbResponse.cdbBids.count);
  XCTAssertEqual(0, cdbResponse.timeToNextCall);
  XCTAssertEqualObjects(self.testBid1, cdbResponse.cdbBids[0]);
  XCTAssertNotEqualObjects(self.testBid2, cdbResponse.cdbBids[1]);
}

- (void)testParsingWithTimeToNextCall {
  // Json response from CDB
  NSString *rawJsonCdbResponse =
      @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},\
    {\"placementId\": \"adunitid_2\",\"zoneId\": 1234567,\"cpm\":5.12,\"currency\":\"EUR\",\"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative_2.png' width='300' height='250' />\"}], \"timeToNextCall\":360}";
  NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

  CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse
                                                      receivedAt:self.testDate];
  XCTAssertNotNil(cdbResponse);
  XCTAssertNotNil(cdbResponse.cdbBids);
  XCTAssertEqual(2, cdbResponse.cdbBids.count);
  XCTAssertEqual(360, cdbResponse.timeToNextCall);
  XCTAssertEqualObjects(self.testBid1, cdbResponse.cdbBids[0]);
  XCTAssertNotEqualObjects(self.testBid2, cdbResponse.cdbBids[1]);
}

- (void)testParsingWithOnlyTimeToNextCall {
  // Json response from CDB
  NSString *rawJsonCdbResponse = @"{\"slots\":[], \"timeToNextCall\":600}";
  NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

  CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse
                                                      receivedAt:self.testDate];
  XCTAssertNotNil(cdbResponse);
  XCTAssertNotNil(cdbResponse.cdbBids);
  XCTAssertEqual(0, cdbResponse.cdbBids.count);
  XCTAssertEqual(600, cdbResponse.timeToNextCall);
}

- (void)testParsingWithNullTimeToNextCall {
  // Json response from CDB
  NSString *rawJsonCdbResponse =
      @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}], \"timeToNextCall\":null}";
  NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

  CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse
                                                      receivedAt:self.testDate];
  XCTAssertNotNil(cdbResponse);
  XCTAssertNotNil(cdbResponse.cdbBids);
  XCTAssertEqual(1, cdbResponse.cdbBids.count);
  XCTAssertEqual(0, cdbResponse.timeToNextCall);
  XCTAssertEqualObjects(self.testBid1, cdbResponse.cdbBids[0]);
}

- (void)testParsingWithStringTimeToNextCall {
  // Json response from CDB
  NSString *rawJsonCdbResponse =
      @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"zoneId\": 497747,\"cpm\":1.12,\"currency\":\"EUR\", \"ttl\":600, \"width\": 300,\"height\": 250,\"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}], \"timeToNextCall\":\"555\"}";
  NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

  CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse
                                                      receivedAt:self.testDate];
  XCTAssertNotNil(cdbResponse);
  XCTAssertNotNil(cdbResponse.cdbBids);
  XCTAssertEqual(1, cdbResponse.cdbBids.count);
  XCTAssertEqual(0, cdbResponse.timeToNextCall);
  XCTAssertEqualObjects(self.testBid1, cdbResponse.cdbBids[0]);
}

#pragma mark Slots

- (void)testParsingWithNoSlots {
  NSDate *testDate = [NSDate date];
  // Json response from CDB
  NSString *rawJsonCdbResponse = @"{\"timeToNextCall\":720}";
  NSData *cdbApiResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];

  CR_CdbResponse *cdbResponse = [CR_CdbResponse responseWithData:cdbApiResponse
                                                      receivedAt:testDate];
  XCTAssertNotNil(cdbResponse);
  XCTAssertNotNil(cdbResponse.cdbBids);
  XCTAssertEqual(0, cdbResponse.cdbBids.count);
  XCTAssertEqual(720, cdbResponse.timeToNextCall);
}

@end
