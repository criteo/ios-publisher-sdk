//
//  CR_ApiHandlerTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <OCMock.h>

#import "CR_ApiQueryKeys.h"
#import "CR_BidManager.h"
#import "CR_CacheManager.h"
#import "CR_Config.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_Gdpr.h"
#import "CR_NetworkManager.h"
#import "CR_NetworkManagerMock.h"
#import "CR_ThreadManager.h"
#import "CR_ThreadManager+Waiter.h"
#import "Logging.h"
#import "NSString+APIKeys.h"
#import "NSString+GDPR.h"
#import "NSString+CriteoUrl.h"
#import "CriteoPublisherSdkTests-Swift.h"
#import "XCTestCase+Criteo.h"

#define CR_AssertLastAppEventUrlContains(name, val)                         \
  do {                                                                      \
    [self assertLastAppEventUrlContainsKey:name value:val atLine:__LINE__]; \
  } while (0);

#define CR_AssertLastAppEventUrlDoNotContains(name)                    \
  do {                                                                 \
    [self assertLastAppEventUrlDoNotContainsKey:name atLine:__LINE__]; \
  } while (0);

@interface CR_ApiHandlerTests : XCTestCase

@property(nonatomic, strong) CR_ApiHandler *apiHandler;
@property(nonatomic, strong) CR_NetworkManagerMock *networkManagerMock;
@property(nonatomic, strong) CR_DataProtectionConsentMock *consentMock;
@property(nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property(nonatomic, strong) CR_Config *configMock;
@property(nonatomic, strong) CR_ThreadManager *threadManager;

// overridden properties
@property(strong, nonatomic, readonly, nullable) NSDictionary *cdbPayload;
@property(strong, nonatomic, readonly, nullable) NSString *appEventUrlString;

@end

@implementation CR_ApiHandlerTests

- (void)setUp {
  self.deviceInfoMock = [self buildDeviceInfoMock];
  self.configMock = [self buildConfigMock];
  self.consentMock = [[CR_DataProtectionConsentMock alloc] init];
  self.networkManagerMock = [[CR_NetworkManagerMock alloc] initWithDeviceInfo:self.deviceInfoMock];
  self.threadManager = [[CR_ThreadManager alloc] init];
  self.apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:self.networkManagerMock
                                                  bidFetchTracker:[CR_BidFetchTracker new]
                                                    threadManager:self.threadManager];
}

- (void)testCallCdb {
  CR_CdbBid *testBid_1 = [self buildEuroBid];
  XCTestExpectation *expectation = [self expectationWithDescription:@"CDB call expectation"];

  [self.apiHandler
                callCdb:@[ [self buildCacheAdUnit] ]
                consent:self.consentMock
                 config:self.configMock
             deviceInfo:self.deviceInfoMock
          beforeCdbCall:nil
      completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse, NSError *error) {
        XCTAssertNil(nil);
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

  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testCdbSlotFilledWithImpressionId {
  [self callCdb];

  NSArray *slots = self.networkManagerMock.lastPostBody[CR_ApiQueryKeys.bidSlots];
  XCTAssertEqual(slots.count, 1);
  NSString *impId = slots[0][CR_ApiQueryKeys.impId];
  XCTAssertEqual([impId length], 32);
}

- (void)testCallCdb_ShouldInvokeBeforeCdbCallback {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"beforeCdbCall callback invoked"];
  CR_CacheAdUnit *adUnit = [self buildCacheAdUnit];
  [self.apiHandler callCdb:@[ adUnit ]
                   consent:self.consentMock
                    config:self.configMock
                deviceInfo:self.deviceInfoMock
             beforeCdbCall:^(CR_CdbRequest *cdbRequest) {
               XCTAssertNotNil(cdbRequest);
               XCTAssertEqual(cdbRequest.adUnits.count, 1);
               XCTAssertEqualObjects(cdbRequest.adUnits[0], adUnit);
               [expectation fulfill];
             }
         completionHandler:nil];
  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testCallCdbWithMultipleAdUnits {
  XCTestExpectation *expectation = [self expectationWithDescription:@"CDB call expectation"];

  CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);

  // Json response from CDB
  NSString *rawJsonCdbResponse =
      @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"cpm\":\"1.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250, \"ttl\": 600, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},{\"placementId\": \"adunitid_2\",\"cpm\":\"1.6\",\"currency\":\"USD\",\"width\": 320,\"height\": 50, \"ttl\": 700, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative2.png' width='320' height='50' />\"}]}";

  NSData *responseData = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
  // OCM substitues "[NSNull null]" to nil at runtime
  id error = [NSNull null];

  OCMStub([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                               postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                        responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);
  CR_CacheAdUnit *testAdUnit_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_1"
                                                                    width:300
                                                                   height:250];
  CR_CacheAdUnit *testAdUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_2"
                                                                    width:320
                                                                   height:50];

  CR_ApiHandler *apiHandler =
      [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager
                                    bidFetchTracker:[CR_BidFetchTracker new]
                                      threadManager:[[CR_ThreadManager alloc] init]];

  CR_CdbBid *testBid_1 = [self buildEuroBid];
  CR_CdbBid *testBid_2 = [self buildDollarBid];
  [apiHandler callCdb:@[ testAdUnit_1, testAdUnit_2 ]
                consent:self.consentMock
                 config:self.configMock
             deviceInfo:self.deviceInfoMock
          beforeCdbCall:nil
      completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse, NSError *error) {
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
  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testGetConfig {
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

  CR_ApiHandler *apiHandler =
      [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager
                                    bidFetchTracker:[CR_BidFetchTracker new]
                                      threadManager:[[CR_ThreadManager alloc] init]];

  [apiHandler getConfig:mockConfig
        ahConfigHandler:^(NSDictionary *configValues) {
          CLog(@"Data length is %ld", [configValues count]);
          XCTAssertNotNil(configValues);
          [expectation fulfill];
        }];
  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testCDBNotInvokedWhenBidFetchInProgress {
  CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                  width:300
                                                                 height:250];
  id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
  OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(NO);
  OCMReject([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
  id mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
  OCMReject([mockNetworkManager postToUrl:[OCMArg any]
                                 postBody:[OCMArg any]
                          responseHandler:([OCMArg any])]);

  CR_ApiHandler *apiHandler =
      [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager
                                    bidFetchTracker:mockBidFetchTracker
                                      threadManager:[[CR_ThreadManager alloc] init]];
  [apiHandler callCdb:@[ testAdUnit ]
                consent:nil
                 config:nil
             deviceInfo:nil
          beforeCdbCall:nil
      completionHandler:nil];
}

- (void)testCDBInvokedWhenBidFetchNotInProgress {
  CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                  width:300
                                                                 height:250];
  id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
  OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(YES);
  OCMExpect([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
  id mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
  OCMExpect([mockNetworkManager
            postToUrl:[OCMArg isKindOfClass:[NSURL class]]
             postBody:[OCMArg isKindOfClass:[NSDictionary class]]
      responseHandler:([OCMArg invokeBlockWithArgs:[NSNull null], [NSNull null], nil])]);

  CR_ApiHandler *apiHandler =
      [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager
                                    bidFetchTracker:mockBidFetchTracker
                                      threadManager:[[CR_ThreadManager alloc] init]];
  [apiHandler callCdb:@[ testAdUnit ]
                consent:nil
                 config:nil
             deviceInfo:nil
          beforeCdbCall:nil
      completionHandler:nil];
  OCMVerifyAllWithDelay(mockBidFetchTracker, 1);
  OCMVerifyAllWithDelay(mockNetworkManager, 1);
}

- (void)testBidFetchTrackerCacheClearedWhenCDBFailsWithError {
  CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                  width:300
                                                                 height:250];
  id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
  OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(YES);
  OCMExpect([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
  CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
  NSData *responseData = [@"testSlot" dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error = [NSError errorWithDomain:@"testDomain" code:1 userInfo:nil];
  OCMStub([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                               postBody:[OCMArg isKindOfClass:[NSDictionary class]]
                        responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);

  CR_ApiHandler *apiHandler =
      [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager
                                    bidFetchTracker:mockBidFetchTracker
                                      threadManager:[[CR_ThreadManager alloc] init]];
  [apiHandler callCdb:@[ testAdUnit ]
                consent:nil
                 config:nil
             deviceInfo:nil
          beforeCdbCall:nil
      completionHandler:nil];
  OCMVerifyAllWithDelay(mockBidFetchTracker, 1);
}

- (void)testBidFetchTrackerCacheClearedWhenCDBReturnsNoData {
  CR_CacheAdUnit *testAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"testAdUnit"
                                                                  width:300
                                                                 height:250];
  id mockBidFetchTracker = OCMStrictClassMock([CR_BidFetchTracker class]);
  OCMStub([mockBidFetchTracker trySetBidFetchInProgressForAdUnit:testAdUnit]).andReturn(YES);
  OCMExpect([mockBidFetchTracker clearBidFetchInProgressForAdUnit:testAdUnit]);
  CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
  OCMStub([mockNetworkManager
            postToUrl:[OCMArg isKindOfClass:[NSURL class]]
             postBody:[OCMArg isKindOfClass:[NSDictionary class]]
      responseHandler:([OCMArg invokeBlockWithArgs:[NSNull null], [NSNull null], nil])]);

  CR_ApiHandler *apiHandler =
      [[CR_ApiHandler alloc] initWithNetworkManager:mockNetworkManager
                                    bidFetchTracker:mockBidFetchTracker
                                      threadManager:[[CR_ThreadManager alloc] init]];
  [apiHandler callCdb:@[ testAdUnit ]
                consent:nil
                 config:nil
             deviceInfo:nil
          beforeCdbCall:nil
      completionHandler:nil];
  OCMVerifyAllWithDelay(mockBidFetchTracker, 1);
}

- (void)testDisregardBidRequestAlreadyInProgress {
  self.networkManagerMock.respondingToPost = NO;

  for (int i = 1; i <= 3; i++) {
    [self.apiHandler
                  callCdb:@[ [self buildCacheAdUnit] ]
                  consent:self.consentMock
                   config:self.configMock
               deviceInfo:self.deviceInfoMock
            beforeCdbCall:nil
        completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse, NSError *error){
        }];
  }

  [self.threadManager waiter_waitIdle];
  XCTAssertEqual(self.networkManagerMock.numberOfPostCall, 1);
}

- (void)testFilterRequestAdUnitsAndSetProgressFlags {
  // Make a bunch of CR_CacheAdUnit
  CR_CacheAdUnit *adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@""
                                                               width:10
                                                              height:20];  // Bad
  CR_CacheAdUnit *adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1"
                                                               width:0
                                                              height:21];  // Bad
  CR_CacheAdUnit *adUnit3 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1"
                                                               width:10
                                                              height:0];  // Bad
  CR_CacheAdUnit *adUnit4 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot1" width:42 height:33];
  CR_CacheAdUnit *adUnit5 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:42 height:33];
  CR_CacheAdUnit *adUnit6 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"slot2" width:43 height:33];

  CR_BidFetchTracker *bidFetchTracker = [CR_BidFetchTracker new];
  [bidFetchTracker trySetBidFetchInProgressForAdUnit:adUnit4];
  // Make a CR_ApiHandler
  CR_ApiHandler *apiHandler =
      [[CR_ApiHandler alloc] initWithNetworkManager:nil
                                    bidFetchTracker:bidFetchTracker
                                      threadManager:[[CR_ThreadManager alloc] init]];

  CR_CacheAdUnitArray *adUnits1 = @[ adUnit1, adUnit2, adUnit3, adUnit4 ];
  CR_CacheAdUnitArray *filteredAdUnits1 =
      [apiHandler filterRequestAdUnitsAndSetProgressFlags:adUnits1];
  XCTAssertEqual(filteredAdUnits1.count, 0);

  CR_CacheAdUnitArray *adUnits2 = @[ adUnit1, adUnit2, adUnit3, adUnit4, adUnit5, adUnit6 ];
  CR_CacheAdUnitArray *expectedFilteredAdUnits2 = @[ adUnit5, adUnit6 ];
  CR_CacheAdUnitArray *filteredAdUnits2 =
      [apiHandler filterRequestAdUnitsAndSetProgressFlags:adUnits2];
  XCTAssertTrue([filteredAdUnits2 isEqualToArray:expectedFilteredAdUnits2]);

  [bidFetchTracker clearBidFetchInProgressForAdUnit:adUnit4];
  CR_CacheAdUnitArray *expectedFilteredAdUnits3 =
      @[ adUnit4 ];  // adUnit5 and adUnit6 had their progress flags
                     // set in the previous call to filterRequest...
  CR_CacheAdUnitArray *filteredAdUnits3 =
      [apiHandler filterRequestAdUnitsAndSetProgressFlags:adUnits2];
  XCTAssertTrue([filteredAdUnits3 isEqualToArray:expectedFilteredAdUnits3]);
}

#pragma mark - CDB call

- (void)testCdbCallContainsSdkAndProfile {
  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[CR_ApiQueryKeys.sdkVersion], self.configMock.sdkVersion);
  XCTAssertEqualObjects(self.cdbPayload[CR_ApiQueryKeys.profileId], self.configMock.profileId);
}

- (void)testCdbCallContainsPublisherInfo {
  NSDictionary *expected = @{
    CR_ApiQueryKeys.cpId : self.configMock.criteoPublisherId,
    CR_ApiQueryKeys.bundleId : self.configMock.appId,
  };

  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[CR_ApiQueryKeys.publisher], expected);
}

- (void)testCdbCallContainsUserInfo {
  NSDictionary *expected = @{
    CR_ApiQueryKeys.deviceIdType : CR_ApiQueryKeys.deviceIdValue,
    CR_ApiQueryKeys.deviceId : self.deviceInfoMock.deviceId,
    CR_ApiQueryKeys.deviceOs : self.configMock.deviceOs,
    CR_ApiQueryKeys.deviceModel : self.configMock.deviceModel,
    CR_ApiQueryKeys.userAgent : self.deviceInfoMock.userAgent,
    CR_ApiQueryKeys.uspIab : CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString
  };

  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[CR_ApiQueryKeys.user], expected);
}

- (void)testCdbCallWithNoDataAndNoError {
  self.networkManagerMock.postResponseData = nil;
  self.networkManagerMock.postResponseError = nil;

  [self callCdbWithCompletionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                       NSError *error) {
    XCTAssertNotNil(cdbRequest);
    XCTAssertNil(cdbResponse);
    XCTAssertNil(error);
  }];
}

#pragma mark GDPR

- (void)testCdbCallContainsGdprUnknown {
  [self callCdb];

  XCTAssertNil(self.cdbPayload[NSString.gdprConsentKey]);
}

- (void)testCdbCallContainsGdprV2 {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion2_0];
  NSDictionary *expected = @{
    NSString.gdprVersionKey : @2,
    NSString.gdprConsentDataKey : NSString.gdprConsentStringForTcf2_0,
    NSString.gdprAppliesKey : @YES
  };

  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[NSString.gdprConsentKey], expected);
}

- (void)testCdbCallContainsGdprV1 {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion1_1];
  NSDictionary *expected = @{
    NSString.gdprVersionKey : @1,
    NSString.gdprConsentDataKey : NSString.gdprConsentStringForTcf1_1,
    NSString.gdprAppliesKey : @YES
  };

  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[NSString.gdprConsentKey], expected);
}

- (void)testCdbCallContainsGdprV1WithoutConsentString {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion1_1];
  self.consentMock.gdprMock.consentStringValue = nil;
  NSDictionary *expected = @{
    // Do not include NSString.gdprConsentDataKey
    NSString.gdprVersionKey : @1,
    NSString.gdprAppliesKey : @YES
  };

  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[NSString.gdprConsentKey], expected);
}

- (void)testCdbCallContainsGdprV1WithoutGdprApplies {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion1_1];
  self.consentMock.gdprMock.appliesValue = nil;
  NSDictionary *expected = @{
    // Do not include NSString.gdprAppliesKey
    NSString.gdprVersionKey : @1,
    NSString.gdprConsentDataKey : NSString.gdprConsentStringForTcf1_1
  };

  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[NSString.gdprConsentKey], expected);
}

#pragma mark CCPA

- (void)testCallCdbWithUspIapContentString {
  self.consentMock.usPrivacyIabConsentString_mock =
      CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString;

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  XCTAssertEqualObjects(body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.uspIab],
                        CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)testCallCdbWithUspIapContentStringEmpty {
  self.consentMock.usPrivacyIabConsentString_mock = @"";

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  XCTAssertNil(body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.uspIab]);
}

- (void)testCallCdbWithUspIapContentStringNil {
  self.consentMock.usPrivacyIabConsentString_mock = nil;

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  XCTAssertNil(body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.uspIab]);
}

- (void)testCallCdbWithUspCriteoStateOptOut {
  self.consentMock.usPrivacyCriteoState = CR_CcpaCriteoStateOptOut;

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  XCTAssertEqualObjects(body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.uspCriteoOptout], @YES);
}

- (void)testCallCdbWithUspCriteoStateOptIn {
  self.consentMock.usPrivacyCriteoState = CR_CcpaCriteoStateOptIn;

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  XCTAssertEqualObjects(body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.uspCriteoOptout], @NO);
}

- (void)testCallCdbWithUspCriteoStateUnset {
  self.consentMock.usPrivacyCriteoState = CR_CcpaCriteoStateUnset;

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  XCTAssertNil(body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.uspCriteoOptout]);
}

- (void)testCallCdbWithoutMopubConsent {
  NSString *trickCompilerWithNil = nil;
  self.consentMock.mopubConsent = trickCompilerWithNil;

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  XCTAssertNil(body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.mopubConsent]);
}

- (void)testCallCdbWithMopubConsent {
  NSString *expected = @"POTENTIAL_WHITELIST";
  self.consentMock.mopubConsent = expected;

  [self callCdb];

  NSDictionary *body = self.networkManagerMock.lastPostBody;
  NSString *actual = body[CR_ApiQueryKeys.user][CR_ApiQueryKeys.mopubConsent];
  XCTAssertEqualObjects(actual, expected);
}

#pragma mark - Sent App Event

- (void)testSendAppEventWithCompletion {
  [self callSendAppEventWithCompletionHandler:^(NSDictionary *appEventValues, NSDate *receivedAt) {
    XCTAssertNotNil(appEventValues);
    XCTAssertNotNil(receivedAt);
  }];
}

- (void)testSendAppEventWithError {
  // Test the existing behaviour but this may require a new design.
  self.networkManagerMock.getResponseData = nil;
  self.networkManagerMock.getResponseError = [NSError errorWithDomain:@"domain"
                                                                 code:1
                                                             userInfo:nil];

  XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
  expectation.inverted = YES;
  [self.apiHandler sendAppEvent:@"Launch"
                        consent:self.consentMock
                         config:self.configMock
                     deviceInfo:self.deviceInfoMock
                 ahEventHandler:^(NSDictionary *appEventValues, NSDate *receivedAt) {
                   [expectation fulfill];
                 }];
  [self waitForExpectations:@[ expectation ] timeout:.25];
}

- (void)testSendAppEventUrlWithoutGdpr {
  NSDictionary *expected = @{
    CR_ApiQueryKeys.idfa : self.deviceInfoMock.deviceId,
    CR_ApiQueryKeys.appId : self.configMock.appId,
    CR_ApiQueryKeys.eventType : @"Launch",
    CR_ApiQueryKeys.limitedAdTracking : @"0"
  };

  [self callSendAppEventWithCompletionHandler:nil];

  XCTAssertEqualObjects(self.appEventUrlString.cr_urlQueryParamsDictionary, expected);
}

- (void)testSendAppEventUrlWithGdpr {
  // GDPR -> JSON -> Base64 -> URL encoding
  // {"consentData":"ssds","gdprApplies":true,"version":1}
  // encoded by https://www.base64encode.org/ (for being neutral) gives:
  // eyJjb25zZW50RGF0YSI6InNzZHMiLCJnZHByQXBwbGllcyI6dHJ1ZSwidmVyc2lvbiI6MX0=
  // encoded by https://www.urlencoder.org/ gives:
  NSString *expectedGdprJsonBase64 =
      @"eyJjb25zZW50RGF0YSI6InNzZHMiLCJnZHByQXBwbGllcyI6dHJ1ZSwidmVyc2lvbiI6MX0%3D";
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion1_1];
  self.consentMock.gdprMock.consentStringValue =
      @"ssds";  // To have escaped chars from base64 to URL encoding.

  [self callSendAppEventWithCompletionHandler:nil];

  NSString *gdprEncodedString =
      self.appEventUrlString.cr_urlQueryParamsDictionary[NSString.gdprConsentKey];
  XCTAssertEqualObjects(gdprEncodedString, expectedGdprJsonBase64);
}

- (void)testCompletionInvokedWhenCDBFailsWithError {
  NSError *expectedError = [NSError errorWithDomain:@"testDomain" code:1 userInfo:nil];
  self.networkManagerMock.postResponseError = expectedError;
  XCTestExpectation *expectation = [[XCTestExpectation alloc]
      initWithDescription:
          @"Expect that completionHandler is invoked when network error is occurred"];

  [self.apiHandler
                callCdb:@[ [self buildCacheAdUnit] ]
                consent:nil
                 config:nil
             deviceInfo:nil
          beforeCdbCall:nil
      completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse, NSError *error) {
        XCTAssertNil(cdbResponse);
        XCTAssertEqual(error, expectedError);
        [expectation fulfill];
      }];

  [self cr_waitForExpectations:@[ expectation ]];
}

#pragma mark - Private methods

- (NSString *)appEventUrlString {
  return self.networkManagerMock.lastGetUrl.absoluteString;
}

- (NSDictionary *)cdbPayload {
  return self.networkManagerMock.lastPostBody;
}

- (void)assertLastAppEventUrlContainsKey:(NSString *)key value:(NSString *)value atLine:(int)line {
  NSString *keyValueStr = [[NSString alloc] initWithFormat:@"%@=%@", key, value];
  if (![self.appEventUrlString containsString:keyValueStr]) {
    NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    NSString *desc = [[NSString alloc] initWithFormat:@"Given key=value %@ not found in URL %@",
                                                      keyValueStr, self.appEventUrlString];
    [self recordFailureWithDescription:desc inFile:file atLine:line expected:YES];
  }
}

- (void)assertLastAppEventUrlDoNotContainsKey:(NSString *)key atLine:(int)line {
  NSString *keyValueStr = [[NSString alloc] initWithFormat:@"%@=", key];
  if ([self.appEventUrlString containsString:keyValueStr]) {
    NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    NSString *desc = [[NSString alloc]
        initWithFormat:@"Given key %@ is found in the URL %@", keyValueStr, self.appEventUrlString];
    [self recordFailureWithDescription:desc inFile:file atLine:line expected:YES];
  }
}

- (void)callSendAppEventWithCompletionHandler:(AHAppEventsResponse)completionHandler {
  XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
  [self.apiHandler sendAppEvent:@"Launch"
                        consent:self.consentMock
                         config:self.configMock
                     deviceInfo:self.deviceInfoMock
                 ahEventHandler:^(NSDictionary *appEventValues, NSDate *receivedAt) {
                   if (completionHandler != nil) {
                     completionHandler(appEventValues, receivedAt);
                   }
                   [expectation fulfill];
                 }];
  [self waitForExpectations:@[ expectation ] timeout:.25];
}

- (void)callCdb {
  [self callCdbWithCompletionHandler:nil];
}

- (void)callCdbWithCompletionHandler:(CR_CdbCompletionHandler)completionHandler {
  XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
  [self.apiHandler
                callCdb:@[ [self buildCacheAdUnit] ]
                consent:self.consentMock
                 config:self.configMock
             deviceInfo:self.deviceInfoMock
          beforeCdbCall:nil
      completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse, NSError *error) {
        if (completionHandler) {
          completionHandler(cdbRequest, cdbResponse, error);
        }
        [expectation fulfill];
      }];
  [self cr_waitForExpectations:@[ expectation ]];
}

- (CR_Config *)buildConfigMock {
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
  OCMStub([mockConfig appEventsUrl]).andReturn(@"https://appevent.com");
  OCMStub([mockConfig appEventsSenderId]).andReturn(@"com.sdk.test");
  return mockConfig;
}

- (CR_DeviceInfo *)buildDeviceInfoMock {
  CR_DeviceInfo *mockDeviceInfo = OCMStrictClassMock([CR_DeviceInfo class]);
  OCMStub([mockDeviceInfo deviceId]).andReturn(@"A0AA0A0A-000A-0A00-AAA0-0A00000A0A0A");
  OCMStub([mockDeviceInfo userAgent])
      .andReturn(
          @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91");
  return mockDeviceInfo;
}

- (CR_CdbBid *)buildEuroBid {
  CR_CdbBid *testBid_1 = [[CR_CdbBid alloc]
      initWithZoneId:nil
         placementId:@"adunitid_1"
                 cpm:@"1.12"
            currency:@"EUR"
               width:@(300)
              height:@(250)
                 ttl:600
            creative:nil
          displayUrl:
              @"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />"
          insertTime:[NSDate date]
        nativeAssets:nil
        impressionId:nil];
  return testBid_1;
}

- (CR_CdbBid *)buildDollarBid {
  CR_CdbBid *testBid_2 = [[CR_CdbBid alloc]
      initWithZoneId:nil
         placementId:@"adunitid_2"
                 cpm:@"1.6"
            currency:@"USD"
               width:@(320)
              height:@(50)
                 ttl:700
            creative:nil
          displayUrl:
              @"<img src='https://demo.criteo.com/publishertag/preprodtest/creative2.png' width='300' height='250' />"
          insertTime:[NSDate date]
        nativeAssets:nil
        impressionId:nil];
  return testBid_2;
}

- (CR_CacheAdUnit *)buildCacheAdUnit {
  CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_1"
                                                              width:300
                                                             height:250];
  return adUnit;
}

@end
