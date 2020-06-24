//
//  CR_WebApiIntegrationTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CR_AdUnitHelper.h"
#import "CR_ApiHandler.h"
#import "CR_DependencyProvider.h"
#import "CR_Config.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_DeviceInfo.h"
#import "CR_TestAdUnits.h"
#import "Criteo+Testing.h"
#import "NSString+GDPR.h"
#import "CriteoPublisherSdkTests-Swift.h"
#import "XCTestCase+Criteo.h"

/**
 Test web APIs

 The following test suite ensure that the integration with the real API still works.
 Other testsuites use a mock or a simulator of the NetworkManager for isolation purpose.
 */
@interface CR_WebApiIntegrationTests : XCTestCase

@property(strong, nonatomic) CR_ApiHandler *apiHandler;
@property(strong, nonatomic) CR_Config *config;
@property(strong, nonatomic) CR_DataProtectionConsentMock *consentMock;
@property(strong, nonatomic) CR_DeviceInfo *deviceInfo;
@property(strong, nonatomic) CR_CacheAdUnit *preprodCacheAdUnit;

@end

@implementation CR_WebApiIntegrationTests

- (void)setUp {
  NSString *userDefaultsId = NSStringFromClass(self.class);
  [[NSUserDefaults new] removePersistentDomainForName:userDefaultsId];
  NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:userDefaultsId];

  self.deviceInfo = [[CR_DeviceInfo alloc] init];
  self.consentMock = [[CR_DataProtectionConsentMock alloc] init];
  self.config = [CR_Config configForTestWithCriteoPublisherId:CriteoTestingPublisherId
                                                 userDefaults:userDefaults];
  CR_DependencyProvider *dependencyProvider = [[CR_DependencyProvider alloc] init];
  self.apiHandler = dependencyProvider.apiHandler;

  // We use the preprod adunit because
  // the GDPR of the demo adunit is not processed by RTB.
  CRAdUnit *adUnit = [CR_TestAdUnits preprodInterstitial];
  self.preprodCacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
}

- (void)testSendAppEvent {
  XCTestExpectation *expectation = [[XCTestExpectation alloc] init];
  [self.apiHandler sendAppEvent:@"Launch"
                        consent:self.consentMock
                         config:self.config
                     deviceInfo:self.deviceInfo
                 ahEventHandler:^(NSDictionary *appEventValues, NSDate *receivedAt) {
                   [expectation fulfill];
                 }];
  [self cr_waitForExpectations:@[ expectation ]];
}

#pragma mark - Call CDB

- (void)testSendValidBidRequest {
  [self callCdbWithCacheAdUnit:self.preprodCacheAdUnit
             completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                 NSError *error) {
               XCTAssertEqual(cdbResponse.cdbBids.count, 1);
               XCTAssertNil(error);
             }];
}

- (void)testSendValidBidRequestWithGdprTcf2_0 {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion2_0];

  [self callCdbWithCacheAdUnit:self.preprodCacheAdUnit
             completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                 NSError *error) {
               XCTAssertEqual(cdbResponse.cdbBids.count, 1);
               XCTAssertNil(error);
             }];
}

- (void)testSendValidBidRequestWithGdprTcf1_1 {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion1_1];

  [self callCdbWithCacheAdUnit:self.preprodCacheAdUnit
             completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                 NSError *error) {
               XCTAssertEqual(cdbResponse.cdbBids.count, 1);
               XCTAssertNil(error);
             }];
}

- (void)testSendValidBidRequestWithGdprTcf1_1ConsentDenied {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion1_1];
  self.consentMock.gdprMock.consentStringValue = NSString.gdprConsentStringDeniedForTcf1_1;

  [self callCdbWithCacheAdUnit:self.preprodCacheAdUnit
             completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                 NSError *error) {
               XCTAssertEqual(cdbResponse.cdbBids.count, 0);
               XCTAssertNil(error);
             }];
}

- (void)testSendValidBidRequestWithGdprTcf2_0ConsentDenied {
  [self.consentMock.gdprMock configureWithTcfVersion:CR_GdprTcfVersion2_0];
  self.consentMock.gdprMock.consentStringValue = NSString.gdprConsentStringDeniedForTcf2_0;

  [self callCdbWithCacheAdUnit:self.preprodCacheAdUnit
             completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                 NSError *error) {
               XCTAssertEqual(cdbResponse.cdbBids.count, 0);
               XCTAssertNil(error);
             }];
}

#pragma mark - Private

- (void)callCdbWithCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit
             completionHandler:(CR_CdbCompletionHandler)completionHandler {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Bid webservice didn't call the completion handler"];

  [self.apiHandler
                callCdb:@[ cacheAdUnit ]
                consent:self.consentMock
                 config:self.config
             deviceInfo:self.deviceInfo
          beforeCdbCall:nil
      completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse, NSError *error) {
        if (completionHandler) {
          completionHandler(cdbRequest, cdbResponse, error);
        }
        [expectation fulfill];
      }];

  [self cr_waitForExpectations:@[ expectation ]];
}

@end
