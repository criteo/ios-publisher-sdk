//
//  CR_ApiHandlerTests.m
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

#import <OCMock.h>

#import "CRContextData.h"
#import "CR_ApiQueryKeys.h"
#import "CR_BidManager.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_Gdpr.h"
#import "CR_IntegrationRegistry.h"
#import "CR_NetworkManagerMock.h"
#import "CR_ThreadManager.h"
#import "CR_ThreadManager+Waiter.h"
#import "NSString+APIKeys.h"
#import "NSString+GDPR.h"
#import "NSString+CriteoUrl.h"
#import "CriteoPublisherSdkTests-Swift.h"
#import "XCTestCase+Criteo.h"
#import "CR_RemoteConfigRequest.h"
#import "CR_UserDataHolder.h"
#import "CR_InternalContextProvider.h"

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
@property(nonatomic, strong) CR_NetworkManager *networkManager;
@property(nonatomic, strong) CR_DataProtectionConsentMock *consentMock;
@property(nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property(nonatomic, strong) CR_Config *configMock;
@property(nonatomic, strong) CR_ThreadManager *threadManager;
@property(nonatomic, strong) CR_IntegrationRegistry *integrationRegistry;
@property(nonatomic, strong) CRContextData *contextData;

// overridden properties
@property(strong, nonatomic, readonly, nullable) NSDictionary *cdbPayload;
@property(strong, nonatomic, readonly, nullable) NSString *appEventUrlString;

@end

@implementation CR_ApiHandlerTests

- (void)setUp {
  self.deviceInfoMock = [self buildDeviceInfoMock];
  self.configMock = [self buildConfigMock];
  self.consentMock = [[CR_DataProtectionConsentMock alloc] init];
  self.networkManager = [[CR_NetworkManagerMock alloc] initWithDeviceInfo:self.deviceInfoMock];
  self.threadManager = [[CR_ThreadManager alloc] init];
  self.integrationRegistry = OCMClassMock(CR_IntegrationRegistry.class);
  OCMStub([self.integrationRegistry profileId]).andReturn(@42);
  self.contextData = CRContextData.new;

  self.apiHandler = [self buildApiHandler];
}

- (void)testCallCdb {
  CR_CdbBid *testBid_1 = [self buildEuroBid];
  XCTestExpectation *expectation = [self expectationWithDescription:@"CDB call expectation"];

  [self.apiHandler callCdb:@[ [self buildCacheAdUnit] ]
                     consent:self.consentMock
                      config:self.configMock
                  deviceInfo:self.deviceInfoMock
                     context:self.contextData
      childDirectedTreatment:nil
               beforeCdbCall:nil
           completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                               NSError *error) {
             XCTAssertNil(nil);
             XCTAssertNotNil(cdbResponse.cdbBids);
             NSLog(@"Data length is %lu", (unsigned long)[cdbResponse.cdbBids count]);
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
                     context:self.contextData
      childDirectedTreatment:nil
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
  self.networkManager = mockNetworkManager;

  // Json response from CDB
  NSString *rawJsonCdbResponse =
      @"{\"slots\":[{\"placementId\": \"adunitid_1\",\"cpm\":\"1.12\",\"currency\":\"EUR\",\"width\": 300,\"height\": 250, \"ttl\": 600, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative.png' width='300' height='250' />\"},{\"placementId\": \"adunitid_2\",\"cpm\":\"1.6\",\"currency\":\"USD\",\"width\": 320,\"height\": 50, \"ttl\": 700, \"displayUrl\": \"<img src='https://demo.criteo.com/publishertag/preprodtest/creative2.png' width='320' height='50' />\"}]}";

  NSData *responseData = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
  // OCM substitues "[NSNull null]" to nil at runtime
  id error = [NSNull null];

  OCMStub([mockNetworkManager postToUrl:[OCMArg isKindOfClass:[NSURL class]]
                                   body:[OCMArg isKindOfClass:[NSDictionary class]]
                             logWithTag:[OCMArg any]
                        responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);
  CR_CacheAdUnit *testAdUnit_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_1"
                                                                    width:300
                                                                   height:250];
  CR_CacheAdUnit *testAdUnit_2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_2"
                                                                    width:320
                                                                   height:50];

  CR_ApiHandler *apiHandler = [self buildApiHandler];

  CR_CdbBid *testBid_1 = [self buildEuroBid];
  CR_CdbBid *testBid_2 = [self buildDollarBid];
  [apiHandler callCdb:@[ testAdUnit_1, testAdUnit_2 ]
                     consent:self.consentMock
                      config:self.configMock
                  deviceInfo:self.deviceInfoMock
                     context:self.contextData
      childDirectedTreatment:nil
               beforeCdbCall:nil
           completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                               NSError *error) {
             XCTAssertNotNil(cdbResponse.cdbBids);
             NSLog(@"Data length is %lu", (unsigned long)[cdbResponse.cdbBids count]);
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

- (void)testCallCdbWithChildDirectedTreatment {
  XCTAssertNil([self networkManagerMock].lastPostBody[CR_ApiQueryKeys.regs][CR_ApiQueryKeys.coppa]);
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"beforeCdbCall callback invoked"];

  [self.apiHandler callCdb:@[ [self buildCacheAdUnit] ]
                     consent:self.consentMock
                      config:self.configMock
                  deviceInfo:self.deviceInfoMock
                     context:self.contextData
      childDirectedTreatment:@YES
               beforeCdbCall:nil
           completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                               NSError *error) {
             XCTAssertEqual([self networkManagerMock]
                                .lastPostBody[CR_ApiQueryKeys.regs][CR_ApiQueryKeys.coppa],
                            @YES);
             [expectation fulfill];
           }];

  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testGetConfig {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Config call expectation"];

  CR_NetworkManager *mockNetworkManager = OCMStrictClassMock([CR_NetworkManager class]);
  self.networkManager = mockNetworkManager;

  // Json response from CR_Config
  NSString *rawJsonCdbResponse = @"{\"killSwitch\":true}";
  NSData *responseData = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
  // OCM substitutes "[NSNull null]" to nil at runtime
  id error = [NSNull null];

  OCMStub([mockNetworkManager postToUrl:OCMOCK_ANY
                                   body:OCMOCK_ANY
                        responseHandler:([OCMArg invokeBlockWithArgs:responseData, error, nil])]);

  CR_Config *mockConfig = OCMStrictClassMock([CR_Config class]);
  OCMStub([mockConfig criteoPublisherId]).andReturn(@("1"));
  OCMStub([mockConfig sdkVersion]).andReturn(@"1.0");
  OCMStub([mockConfig appId]).andReturn(@"com.criteo.sdk.publisher");
  OCMStub([mockConfig configUrl]).andReturn(@"https://url-for-getting-config");
  OCMStub([mockConfig deviceModel]).andReturn(@"deviceModel");
  OCMStub([mockConfig deviceOs]).andReturn(@"deviceOs");

  CR_RemoteConfigRequest *request = [CR_RemoteConfigRequest requestWithConfig:mockConfig
                                                                    profileId:@42];

  CR_ApiHandler *apiHandler = [self buildApiHandler];

  [apiHandler getConfig:request
        ahConfigHandler:^(NSDictionary *configValues) {
          NSLog(@"Data length is %lu", (unsigned long)[configValues count]);
          XCTAssertNotNil(configValues);
          [expectation fulfill];
        }];
  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testDisregardBidRequestAlreadyInProgress {
  self.networkManagerMock.respondingToPost = NO;

  for (int i = 1; i <= 3; i++) {
    [self.apiHandler callCdb:@[ [self buildCacheAdUnit] ]
                       consent:self.consentMock
                        config:self.configMock
                    deviceInfo:self.deviceInfoMock
                       context:self.contextData
        childDirectedTreatment:nil
                 beforeCdbCall:nil
             completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                 NSError *error){
             }];
  }

  [self.threadManager waiter_waitIdle];
  XCTAssertEqual(self.networkManagerMock.numberOfPostCall, 3);
}

#pragma mark - CDB call

- (void)testCdbCallContainsSdkAndProfile {
  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[CR_ApiQueryKeys.sdkVersion], self.configMock.sdkVersion);
  XCTAssertEqualObjects(self.cdbPayload[CR_ApiQueryKeys.profileId], @42);
}

- (void)testCdbCallContainsPublisherInfo {
  NSDictionary *expected = @{
    CR_ApiQueryKeys.cpId : self.configMock.criteoPublisherId,
    CR_ApiQueryKeys.bundleId : self.configMock.appId,
    CR_ApiQueryKeys.storeId : self.configMock.storeId,
    CR_ApiQueryKeys.ext : @{}
  };

  [self callCdb];

  XCTAssertEqualObjects(self.cdbPayload[CR_ApiQueryKeys.publisher], expected);
}

- (void)testCdbCallContainsUserInfo {
  self.consentMock.trackingAuthorizationStatus_mock = nil;

  NSDictionary *expected = @{
    CR_ApiQueryKeys.deviceIdType : CR_ApiQueryKeys.deviceIdValue,
    CR_ApiQueryKeys.deviceId : self.deviceInfoMock.deviceId,
    CR_ApiQueryKeys.deviceOs : self.configMock.deviceOs,
    CR_ApiQueryKeys.deviceModel : self.configMock.deviceModel,
    CR_ApiQueryKeys.userAgent : self.deviceInfoMock.userAgent,
    CR_ApiQueryKeys.uspIab : CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString,
    CR_ApiQueryKeys.skAdNetwork : @{
      CR_ApiQueryKeys.skAdNetworkVersion : @[ @"2.0", @"2.1", @"2.2", @"3.0" ],
      CR_ApiQueryKeys.skAdNetworkIds : @[ @"hs6bdukanm.skadnetwork" ]
    }
  };

  [self callCdb];

  NSMutableDictionary *userInfo = [self.cdbPayload[CR_ApiQueryKeys.user] mutableCopy];
  userInfo[@"ext"] = nil;  // contextual data is checked in other tests
  XCTAssertEqualObjects(userInfo, expected);
}

- (void)testCdbCallContainsUserInfoWithAuthorizationStatus {
  self.consentMock.trackingAuthorizationStatus_mock = @3;

  NSDictionary *expected = @{
    CR_ApiQueryKeys.deviceIdType : CR_ApiQueryKeys.deviceIdValue,
    CR_ApiQueryKeys.deviceId : self.deviceInfoMock.deviceId,
    CR_ApiQueryKeys.deviceOs : self.configMock.deviceOs,
    CR_ApiQueryKeys.deviceModel : self.configMock.deviceModel,
    CR_ApiQueryKeys.userAgent : self.deviceInfoMock.userAgent,
    CR_ApiQueryKeys.uspIab : CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString,
    CR_ApiQueryKeys.skAdNetwork : @{
      CR_ApiQueryKeys.skAdNetworkVersion : @[ @"2.0", @"2.1", @"2.2", @"3.0" ],
      CR_ApiQueryKeys.skAdNetworkIds : @[ @"hs6bdukanm.skadnetwork" ]
    },
    CR_ApiQueryKeys.trackingAuthorizationStatus : @"3"
  };

  [self callCdb];

  NSMutableDictionary *userInfo = [self.cdbPayload[CR_ApiQueryKeys.user] mutableCopy];
  userInfo[@"ext"] = nil;  // contextual data is checked in other tests
  XCTAssertEqualObjects(userInfo, expected);
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
  [self cr_waitShortlyForExpectations:@[ expectation ]];
}

- (void)testSendAppEventUrlWithoutGdpr {
  self.consentMock.trackingAuthorizationStatus_mock = nil;

  NSDictionary *expected = @{
    CR_ApiQueryKeys.idfa : self.deviceInfoMock.deviceId,
    CR_ApiQueryKeys.appId : self.configMock.appId,
    CR_ApiQueryKeys.eventType : @"Launch"
  };

  [self callSendAppEventWithCompletionHandler:nil];

  XCTAssertEqualObjects(self.appEventUrlString.cr_urlQueryParamsDictionary, expected);
}

- (void)testSendAppEventUrlWithTrackingAuthorizationStatus {
  self.consentMock.trackingAuthorizationStatus_mock = @2;

  NSDictionary *expected = @{
    CR_ApiQueryKeys.idfa : self.deviceInfoMock.deviceId,
    CR_ApiQueryKeys.appId : self.configMock.appId,
    CR_ApiQueryKeys.eventType : @"Launch",
    CR_ApiQueryKeys.trackingAuthorizationStatus : @"2"
  };

  [self callSendAppEventWithCompletionHandler:nil];

  XCTAssertEqualObjects(self.appEventUrlString.cr_urlQueryParamsDictionary, expected);
}

- (void)testSendAppEventUrlWithGdpr {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion1_1];
  self.consentMock.gdprMock.consentStringValue = @"ssds";

  [self callSendAppEventWithCompletionHandler:nil];

  NSString *gdprEncodedString =
      self.appEventUrlString.cr_urlQueryParamsDictionary[NSString.gdprConsentKeyForGum];
  XCTAssertEqualObjects(gdprEncodedString, @"ssds");
}

- (void)testCompletionInvokedWhenCDBFailsWithError {
  NSError *expectedError = [NSError errorWithDomain:@"testDomain" code:1 userInfo:nil];
  self.networkManagerMock.postResponseError = expectedError;
  XCTestExpectation *expectation = [[XCTestExpectation alloc]
      initWithDescription:
          @"Expect that completionHandler is invoked when network error is occurred"];

  [self.apiHandler callCdb:@[ [self buildCacheAdUnit] ]
                     consent:nil
                      config:nil
                  deviceInfo:nil
                     context:self.contextData
      childDirectedTreatment:nil
               beforeCdbCall:nil
           completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                               NSError *error) {
             XCTAssertNil(cdbResponse);
             XCTAssertEqual(error, expectedError);
             [expectation fulfill];
           }];

  [self cr_waitForExpectations:@[ expectation ]];
}

#pragma mark - Logs

- (void)testSendLogs_GivenLog_Send {
  [self callSendLogs:@[ self.logRecord, self.logRecord ]
          expectingSend:YES
      completionHandler:^(NSError *error) {
        XCTAssertNil(error);
      }];
}

- (void)testSendLogs_GivenEmptyArray_DoNotSend {
  [self callSendLogs:@[] expectingSend:NO completionHandler:NULL];
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
    [self cr_recordFailureWithDescription:desc inFile:file atLine:line expected:YES];
  }
}

- (void)assertLastAppEventUrlDoNotContainsKey:(NSString *)key atLine:(int)line {
  NSString *keyValueStr = [[NSString alloc] initWithFormat:@"%@=", key];
  if ([self.appEventUrlString containsString:keyValueStr]) {
    NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    NSString *desc = [[NSString alloc]
        initWithFormat:@"Given key %@ is found in the URL %@", keyValueStr, self.appEventUrlString];
    [self cr_recordFailureWithDescription:desc inFile:file atLine:line expected:YES];
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
  [self cr_waitShortlyForExpectations:@[ expectation ]];
}

- (void)callSendLogs:(NSArray<CR_RemoteLogRecord *> *)logs
        expectingSend:(BOOL)sendExpected
    completionHandler:(CR_LogsCompletionHandler)completionHandler {
  XCTestExpectation *sendExpectation = [[XCTestExpectation alloc] init];
  sendExpectation.inverted = !sendExpected;
  [self.apiHandler sendLogs:logs
                     config:self.configMock
          completionHandler:^(NSError *error) {
            if (completionHandler != nil) {
              completionHandler(error);
            }
            [sendExpectation fulfill];
          }];
  [self cr_waitShortlyForExpectations:@[ sendExpectation ]];
}

- (CR_RemoteLogRecord *)logRecord {
  return [[CR_RemoteLogRecord alloc] initWithVersion:@"1"
                                            bundleId:@"bundle"
                                            deviceId:@"12345"
                                           sessionId:@"67890"
                                           profileId:@42
                                                 tag:@"tag"
                                            severity:CR_LogSeverityWarning
                                             message:@"message"
                                       exceptionType:nil];
}

- (void)callCdb {
  [self callCdbWithCompletionHandler:nil];
}

- (void)callCdbWithCompletionHandler:(CR_CdbCompletionHandler)completionHandler {
  XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
  [self.apiHandler callCdb:@[ [self buildCacheAdUnit] ]
                     consent:self.consentMock
                      config:self.configMock
                  deviceInfo:self.deviceInfoMock
                     context:self.contextData
      childDirectedTreatment:nil
               beforeCdbCall:nil
           completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                               NSError *error) {
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
  OCMStub([mockConfig cdbUrl]).andReturn(@"https://dummyCdb.com");
  OCMStub([mockConfig path]).andReturn(@"inApp");
  OCMStub([mockConfig logsPath]).andReturn(@"logs");
  OCMStub([mockConfig appId]).andReturn(@"com.criteo.sdk.publisher");
  OCMStub([mockConfig deviceModel]).andReturn(@"iPhone");
  OCMStub([mockConfig osVersion]).andReturn(@"12.1");
  OCMStub([mockConfig deviceOs]).andReturn(@"ios");
  OCMStub([mockConfig appEventsUrl]).andReturn(@"https://appevent.com");
  OCMStub([mockConfig appEventsSenderId]).andReturn(@"com.sdk.test");
  OCMStub([mockConfig isMraidEnabled]).andReturn(NO);
  OCMStub([mockConfig isMraid2Enabled]).andReturn(NO);
  OCMStub([mockConfig storeId]).andReturn(@("12"));
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
                    isVideo:NO
                 isRewarded:NO
                 insertTime:[NSDate date]
               nativeAssets:nil
               impressionId:nil
      skAdNetworkParameters:nil];
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
                    isVideo:NO
                 isRewarded:NO
                 insertTime:[NSDate date]
               nativeAssets:nil
               impressionId:nil
      skAdNetworkParameters:nil];
  return testBid_2;
}

- (CR_CacheAdUnit *)buildCacheAdUnit {
  CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid_1"
                                                              width:300
                                                             height:250];
  return adUnit;
}

- (CR_ApiHandler *)buildApiHandler {
  return [[CR_ApiHandler alloc] initWithNetworkManager:self.networkManagerMock
                                         threadManager:self.threadManager
                                   integrationRegistry:self.integrationRegistry
                                        userDataHolder:CR_UserDataHolder.new
                               internalContextProvider:CR_InternalContextProvider.new];
}

- (CR_NetworkManagerMock *)networkManagerMock {
  return (CR_NetworkManagerMock *)self.networkManager;
}

@end
