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
#import "CR_DataProtectionConsent.h"
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
    CR_CacheAdUnit *testAdUnit_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_1" width:300 height:250];

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:[CR_BidFetchTracker new]];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid_1" cpm:@"1.12"
                                                    currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:[NSDate date]
                                                nativeAssets:nil];

    CR_DataProtectionConsent *mockUserConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
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

    [apiHandler callCdb:@[testAdUnit_1]
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

- (void) testCallCdbWithMultipleAdUnits {
    XCTestExpectation *expectation = [self expectationWithDescription:@"CDB call expectation"];

    CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);

    // Json response from CDB
    NSString *rawJsonCdbResponse = @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"cpm\":\"1.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250, \"ttl\": 600, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},{\"placementId\": \"adunitid_2\",\"cpm\":\"1.6\",\"currency\":\"USD\",\"width\": 320,\"height\": 50, \"ttl\": 700, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative2.png' width='320' height='50' />\"}]}";

    NSData *responseData = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
    // OCM substitues "[NSNull null]" to nil at runtime
    id error = [NSNull null];

    OCMStub([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                                 postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                          responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);
    CR_CacheAdUnit *testAdUnit_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_1" width:300 height:250];
    CR_CacheAdUnit *testAdUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_2" width:320 height:50];

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:[CR_BidFetchTracker new]];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid_1" cpm:@"1.12"
                                                    currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
                                                  insertTime:[NSDate date]
                                                nativeAssets:nil];

    CR_CdbBid *testBid_2 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid_2" cpm:@"1.6"
                                                    currency:@"USD" width:@(320) height:@(50) ttl:700 creative:nil
                                                  displayUrl:@"<img src='https://demo.criteo.com/publishertag/preprodtest/creative2.png' width='300' height='250' />"
                                                  insertTime:[NSDate date]
                                                nativeAssets:nil];

    CR_DataProtectionConsent *mockUserConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
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

    [apiHandler callCdb:@[testAdUnit_1, testAdUnit_2]
            gdprConsent:mockUserConsent
                 config:mockConfig
             deviceInfo:mockDeviceInfo
   ahCdbResponseHandler:^(CR_CdbResponse *cdbResponse) {

       XCTAssertNotNil(cdbResponse.cdbBids);
       CLog(@"Data length is %ld", [cdbResponse.cdbBids count]);
       XCTAssertEqual(2, [cdbResponse.cdbBids count]);

       CR_CdbBid *receivedBid1 = cdbResponse.cdbBids[0];
       XCTAssertEqualObjects(testBid_1.placementId, receivedBid1.placementId);
       XCTAssertEqualObjects(testBid_1.width, receivedBid1.width);
       XCTAssertEqualObjects(testBid_1.height, receivedBid1.height);
       XCTAssertEqualObjects(testBid_1.cpm, receivedBid1.cpm);
       XCTAssertEqual(testBid_1.ttl, receivedBid1.ttl);

       CR_CdbBid *receivedBid2 = cdbResponse.cdbBids[1];
       XCTAssertEqualObjects(testBid_2.placementId, receivedBid2.placementId);
       XCTAssertEqualObjects(testBid_2.width, receivedBid2.width);
       XCTAssertEqualObjects(testBid_2.height, receivedBid2.height);
       XCTAssertEqualObjects(testBid_2.cpm, receivedBid2.cpm);
       XCTAssertEqual(testBid_2.ttl, receivedBid2.ttl);

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
    OCMStub([mockConfig configUrl]).andReturn(@"https://url-for-getting-config");

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:[CR_BidFetchTracker new]];

    [apiHandler getConfig:mockConfig ahConfigHandler:^(NSDictionary *configValues){
        CLog(@"Data length is %ld", [configValues count]);
        XCTAssertNotNil(configValues);
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:100];
}

- (void) testCDBNotInvokedWhenBidFetchInProgress {
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:300 height:250];
    id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
    OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(NO);
    OCMReject([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
    id mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
    OCMReject([mockNetworkManager postToUrl:[OCMArg any]
                                   postBody:[OCMArg any]
                            responseHandler:([OCMArg any])]);

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:mockBidFetchTracker];
    [apiHandler callCdb:@[testAdUnit]
            gdprConsent:nil
                 config:nil
             deviceInfo:nil
   ahCdbResponseHandler:nil];
}

- (void) testCDBInvokedWhenBidFetchNotInProgress {
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:300 height:250];
    id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
    OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(YES);
    OCMExpect([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
    id mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
    OCMExpect([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                                   postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                            responseHandler:([OCMArg invokeBlockWithArgs:[NSNull null], [NSNull null], nil])]);

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:mockBidFetchTracker];
    [apiHandler callCdb:@[testAdUnit]
            gdprConsent:nil
                 config:nil
             deviceInfo:nil
   ahCdbResponseHandler:nil];
    OCMVerifyAllWithDelay(mockBidFetchTracker, 1);
    OCMVerifyAllWithDelay(mockNetworkManager, 1);
}

- (void) testBidFetchTrackerCacheClearedWhenCDBFailsWithError {
    CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:300 height:250];
    id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
    OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(YES);
    OCMExpect([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
    CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
    NSData *responseData = [@"testSlot" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = [NSError errorWithDomain:@"testDomain" code:1 userInfo:nil];
    OCMStub([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                                 postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                          responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:mockBidFetchTracker];
    [apiHandler callCdb:@[testAdUnit]
            gdprConsent:nil
                 config:nil
             deviceInfo:nil
   ahCdbResponseHandler:nil];
    OCMVerifyAllWithDelay(mockBidFetchTracker, 1);
}

- (void) testBidFetchTrackerCacheClearedWhenCDBReturnsNoData {
     CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:300 height:250];
    id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
    OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(YES);
    OCMExpect([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
    CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
    OCMStub([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                                   postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                            responseHandler:([OCMArg invokeBlockWithArgs:[NSNull null], [NSNull null], nil])]);

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:mockBidFetchTracker];
    [apiHandler callCdb:@[testAdUnit]
            gdprConsent:nil
                 config:nil
             deviceInfo:nil
   ahCdbResponseHandler:nil];
    OCMVerifyAllWithDelay(mockBidFetchTracker, 1);
}

- (void) testTwoThreadsInvokingCDBForSameAdUnit {
     CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" width:300 height:250];
    CR_BidFetchTracker *bidFetchTracker = [CR_BidFetchTracker new];
    id mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
    OCMExpect([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                                   postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                            responseHandler:([OCMArg invokeBlockWithArgs:[NSNull null], [NSNull null], nil])]);
    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager bidFetchTracker:bidFetchTracker];
    dispatch_queue_t queue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [apiHandler callCdb:@[testAdUnit]
                gdprConsent:nil
                     config:nil
                 deviceInfo:nil
       ahCdbResponseHandler:nil];
    });
    dispatch_async(queue, ^{
        [apiHandler callCdb:@[testAdUnit]
                gdprConsent:nil
                     config:nil
                 deviceInfo:nil
       ahCdbResponseHandler:nil];
    });
    OCMVerifyAllWithDelay(mockNetworkManager, 5);
}

- (void) testFilterRequestAdUnitsAndSetProgressFlags {

    // Make a bunch of CR_CacheAdUnit
    CR_CacheAdUnit *adUnit1  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"" width:10 height:20];      //Bad
    CR_CacheAdUnit *adUnit2  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1" width:0 height:21];  //Bad
    CR_CacheAdUnit *adUnit3  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1" width:10 height:0];  //Bad
    CR_CacheAdUnit *adUnit4  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1" width:42 height:33];
    CR_CacheAdUnit *adUnit5  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:42 height:33];
    CR_CacheAdUnit *adUnit6  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:43 height:33];

    CR_BidFetchTracker *bidFetchTracker = [CR_BidFetchTracker new];
    [bidFetchTracker trySetBidFetchInProgressForAdUnit:adUnit4];
    // Make a CR_ApiHandler
    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:nil bidFetchTracker:bidFetchTracker];

    CR_CacheAdUnitArray *adUnits1 = @[adUnit1, adUnit2, adUnit3, adUnit4];
    CR_CacheAdUnitArray *filteredAdUnits1 = [apiHandler filterRequestAdUnitsAndSetProgressFlags:adUnits1];
    XCTAssertEqual(filteredAdUnits1.count, 0);

    CR_CacheAdUnitArray *adUnits2 = @[adUnit1, adUnit2, adUnit3, adUnit4, adUnit5, adUnit6];
    CR_CacheAdUnitArray *expectedFilteredAdUnits2 = @[adUnit5, adUnit6];
    CR_CacheAdUnitArray *filteredAdUnits2 = [apiHandler filterRequestAdUnitsAndSetProgressFlags:adUnits2];
    XCTAssertTrue([filteredAdUnits2 isEqualToArray:expectedFilteredAdUnits2]);

    [bidFetchTracker clearBidFetchInProgressForAdUnit:adUnit4];
    CR_CacheAdUnitArray *expectedFilteredAdUnits3 = @[adUnit4];   // adUnit5 and adUnit6 had their progress flags
                                                                  // set in the previous call to filterRequest...
    CR_CacheAdUnitArray *filteredAdUnits3 = [apiHandler filterRequestAdUnitsAndSetProgressFlags:adUnits2];
    XCTAssertTrue([filteredAdUnits3 isEqualToArray:expectedFilteredAdUnits3]);
}

- (void)testPostBodyWithGdprConsent {
    CR_DataProtectionConsent *mockUserConsent = OCMStrictClassMock([CR_DataProtectionConsent class]);
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

    // Make a CR_ApiHandler
    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:nil bidFetchTracker:nil];

    // With consent
    NSMutableDictionary *postBody = [apiHandler postBodyWithGdprConsent:mockUserConsent
                                                                 config:mockConfig
                                                             deviceInfo:mockDeviceInfo];

    XCTAssertTrue([postBody[@"sdkVersion"] isEqualToString:mockConfig.sdkVersion]);
    XCTAssertTrue([postBody[@"profileId"]  isEqualToNumber:mockConfig.profileId]);

    XCTAssertTrue([postBody[@"user"][@"userAgent"]    isEqualToString:mockDeviceInfo.userAgent]);
    XCTAssertTrue([postBody[@"user"][@"deviceId"]     isEqualToString:mockDeviceInfo.deviceId]);
    XCTAssertTrue([postBody[@"user"][@"deviceOs"]     isEqualToString:mockConfig.deviceOs]);
    XCTAssertTrue([postBody[@"user"][@"deviceModel"]  isEqualToString:mockConfig.deviceModel]);
    XCTAssertTrue([postBody[@"user"][@"deviceIdType"] isEqualToString:@"IDFA"]);

    XCTAssertTrue([postBody[@"publisher"][@"bundleId"] isEqualToString:mockConfig.appId]);
    XCTAssertTrue([postBody[@"publisher"][@"cpId"]     isEqualToString:mockConfig.criteoPublisherId]);

    XCTAssertTrue([postBody[@"gdprConsent"][@"consentData"] isEqualToString:mockUserConsent.consentString]);
    XCTAssertEqual([postBody[@"gdprConsent"][@"gdprApplies"] boolValue], mockUserConsent.gdprApplies);
    XCTAssertEqual([postBody[@"gdprConsent"][@"consentGiven"] boolValue], mockUserConsent.consentGiven);

    // Nil consent
    postBody = [apiHandler postBodyWithGdprConsent:nil
                                            config:mockConfig
                                        deviceInfo:mockDeviceInfo];

    XCTAssertTrue([postBody[@"sdkVersion"] isEqualToString:mockConfig.sdkVersion]);
    XCTAssertTrue([postBody[@"profileId"]  isEqualToNumber:mockConfig.profileId]);

    XCTAssertTrue([postBody[@"user"][@"userAgent"]    isEqualToString:mockDeviceInfo.userAgent]);
    XCTAssertTrue([postBody[@"user"][@"deviceId"]     isEqualToString:mockDeviceInfo.deviceId]);
    XCTAssertTrue([postBody[@"user"][@"deviceOs"]     isEqualToString:mockConfig.deviceOs]);
    XCTAssertTrue([postBody[@"user"][@"deviceModel"]  isEqualToString:mockConfig.deviceModel]);
    XCTAssertTrue([postBody[@"user"][@"deviceIdType"] isEqualToString:@"IDFA"]);

    XCTAssertTrue([postBody[@"publisher"][@"bundleId"] isEqualToString:mockConfig.appId]);
    XCTAssertTrue([postBody[@"publisher"][@"cpId"]     isEqualToString:mockConfig.criteoPublisherId]);

    XCTAssertNil(postBody[@"gdprConsent"]);

    // Nil consent string
    CR_DataProtectionConsent *mockUserConsent2 = OCMStrictClassMock([CR_DataProtectionConsent class]);
    OCMStub([mockUserConsent2 gdprApplies]).andReturn(YES);
    OCMStub([mockUserConsent2 consentGiven]).andReturn(YES);
    OCMStub([mockUserConsent2 consentString]).andReturn(nil);

    postBody = [apiHandler postBodyWithGdprConsent:mockUserConsent2
                                            config:mockConfig
                                        deviceInfo:mockDeviceInfo];

    XCTAssertTrue([postBody[@"sdkVersion"] isEqualToString:mockConfig.sdkVersion]);
    XCTAssertTrue([postBody[@"profileId"]  isEqualToNumber:mockConfig.profileId]);

    XCTAssertTrue([postBody[@"user"][@"userAgent"]    isEqualToString:mockDeviceInfo.userAgent]);
    XCTAssertTrue([postBody[@"user"][@"deviceId"]     isEqualToString:mockDeviceInfo.deviceId]);
    XCTAssertTrue([postBody[@"user"][@"deviceOs"]     isEqualToString:mockConfig.deviceOs]);
    XCTAssertTrue([postBody[@"user"][@"deviceModel"]  isEqualToString:mockConfig.deviceModel]);
    XCTAssertTrue([postBody[@"user"][@"deviceIdType"] isEqualToString:@"IDFA"]);

    XCTAssertTrue([postBody[@"publisher"][@"bundleId"] isEqualToString:mockConfig.appId]);
    XCTAssertTrue([postBody[@"publisher"][@"cpId"]     isEqualToString:mockConfig.criteoPublisherId]);

    XCTAssertNil(postBody[@"gdprConsent"]);
}

- (void)testSlotsForRequest {
    CR_CacheAdUnit *adUnit1  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1" width:42 height:33];
    CR_CacheAdUnit *adUnit2  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:42 height:33];
    CR_CacheAdUnit *adUnit3  = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:43 height:33];
    CR_CacheAdUnitArray *adUnits = @[adUnit1, adUnit2, adUnit3];

    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:nil bidFetchTracker:nil];

    NSArray *slots = [apiHandler slotsForRequest:adUnits];
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
    CR_ApiHandler *apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:nil bidFetchTracker:nil];
    NSArray *slots = [apiHandler slotsForRequest:@[nativeAdUnit]];
    XCTAssertTrue([slots[0][@"placementId"] isEqualToString:nativeAdUnit.adUnitId]);
    XCTAssertTrue([slots[0][@"sizes"] isEqual:@[nativeAdUnit.cdbSize]]);
    XCTAssertTrue(slots[0][@"isNative"]);

    CR_CacheAdUnit *nonNativeAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit" size:CGSizeMake(2, 2) adUnitType:CRAdUnitTypeInterstitial];
    NSArray *nonNativeSlots = [apiHandler slotsForRequest:@[nonNativeAdUnit]];
    XCTAssertTrue([nonNativeSlots[0][@"placementId"] isEqualToString:nonNativeAdUnit.adUnitId]);
    XCTAssertTrue([nonNativeSlots[0][@"sizes"] isEqual:@[nonNativeAdUnit.cdbSize]]);
    XCTAssertNil(nonNativeSlots[0][@"isNative"]);
}

@end
