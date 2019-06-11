//
//  CR_ApiHandlerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/14/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <OCMock.h>

#import "CR_BidManager.h"
#import "CR_CacheManager.h"
#import "CR_Config.h"
#import "CR_GdprUserConsent.h"
#import "Logging.h"
#import "CR_NetworkManager.h"

@interface CR_ApiHandlerTests : XCTestCase

@end

@implementation CR_ApiHandlerTests

- (void) testCallCdb {
    XCTestExpectation *expectation = [self expectationWithDescription:@"CDB call expectation"];

    CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);

    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"cpm\":\"1.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250, \"ttl\": 600, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"}]}";

    NSData *responseData = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
    // OCM substitues "[NSNull null]" to nil at runtime
    id error = [NSNull null];

    OCMStub([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                                 postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                          responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid_1" cpm:@"1.12"
                                              currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil
                                            displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                            insertTime:[NSDate date]];

    CR_CacheAdUnit *testAdUnit_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_1" width:300 height:250];

    CR_GdprUserConsent *mockUserConsent = OCMStrictClassMock([CR_GdprUserConsent class]);
    OCMStub([mockUserConsent gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent consentString]).andReturn(@"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA");

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig criteoPublisherId]).andReturn(@("1"));
    OCMStub([mockConfig sdkVersion]).andReturn(@"1.0");
    OCMStub([mockConfig profileId]).andReturn(@(235));
    OCMStub([mockConfig cdbUrl]).andReturn(@"https://dummyCdb.com");
    OCMStub([mockConfig path]).andReturn(@"inApp");
    OCMStub([mockConfig appId]).andReturn(@"com.criteo.pubsdk");
    OCMStub([mockConfig deviceModel]).andReturn(@"iPhone");
    OCMStub([mockConfig osVersion]).andReturn(@"12.1");
    OCMStub([mockConfig deviceOs]).andReturn(@"ios");

    CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
    OCMStub([mockDeviceInfo deviceId]).andReturn(@"A0AA0A0A-000A-0A00-AAA0-0A00000A0A0A");
    OCMStub([mockDeviceInfo userAgent]).andReturn(@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91");

    [apiHandler callCdb:testAdUnit_1
            gdprConsent:mockUserConsent
                 config:mockConfig
             deviceInfo:mockDeviceInfo
   ahCdbResponseHandler:^(CR_CdbResponse *cdbResponse) {

       XCTAssertNotNil(cdbResponse.cdbBids);
       CLog(@"Data length is %ld", [cdbResponse.cdbBids count]);
       XCTAssertEqual(1, [cdbResponse.cdbBids count]);
       CR_CdbBid *receivedBid = cdbResponse.cdbBids[0];
       XCTAssertEqualObjects(testBid_1.placementId, receivedBid.placementId);
       XCTAssertEqualObjects(testBid_1.width, receivedBid.width);
       XCTAssertEqualObjects(testBid_1.height, receivedBid.height);
       XCTAssertEqualObjects(testBid_1.cpm, receivedBid.cpm);
       XCTAssertEqual(testBid_1.ttl, receivedBid.ttl);
       [expectation fulfill];
   }];

    /*
     [mockNetworkManager postToUrl:[NSURL URLWithString:@"http://example.com"]
     queryParams:[NSDictionary dictionary]
     postBody:[NSDictionary dictionary]
     responseHandler:^(NSData *data, NSError *error) {
     CLog(@"Block ran!");
     NSArray *cdbBids = [CR_CdbBid getCdbResponsesFromData:data];
     CLog(@"Data length is %ld", [cdbBids count]);
     [expectation fulfill];
     }];

     CLog(@"%d", [mockNetworkManager isEqual:[NSNull null]]);
     */

    [self waitForExpectations:@[expectation] timeout:100];
}

- (void) testGetConfig {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Config call expectation"];

    CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);

    // Json response from CR_Config
    NSString *rawJsonCdbResponse = @"{\"killSwitch\":true}";
    NSData *responseData = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
    // OCM substitues "[NSNull null]" to nil at runtime
    id error = [NSNull null];

    OCMStub([mockNetworkManager getFromUrl:[OCMArg isKindOfClass:[NSURL class]]
                           responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);

    CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
    OCMStub([mockConfig criteoPublisherId]).andReturn(@("1"));
    OCMStub([mockConfig sdkVersion]).andReturn(@"1.0");
    OCMStub([mockConfig appId]).andReturn(@"com.criteo.pubsdk");

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager];

    [apiHandler getConfig:mockConfig ahConfigHandler:^(NSDictionary *configValues){
        CLog(@"Data length is %ld", [configValues count]);
        XCTAssertNotNil(configValues);
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:100];
}

@end
