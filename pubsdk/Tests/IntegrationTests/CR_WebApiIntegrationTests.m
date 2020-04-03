//
//  CR_WebApiIntegrationTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 3/4/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CR_AdUnitHelper.h"
#import "CR_ApiHandler.h"
#import "CR_BidManagerBuilder.h"
#import "CR_Config.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_DeviceInfo.h"
#import "CR_TestAdUnits.h"
#import "Criteo+Testing.h"
#import "NSString+GDPR.h"
#import "pubsdkTests-Swift.h"
#import "XCTestCase+Criteo.h"

/**
 Test web APIs

 The following test suite ensure that the integration with the real API still works.
 Other testsuites use a mock or a simulator of the NetworkManager for isolation purpose.
 */
@interface CR_WebApiIntegrationTests : XCTestCase

@property (strong, nonatomic) CR_ApiHandler *apiHandler;
@property (strong, nonatomic) CR_Config *config;
@property (strong, nonatomic) CR_DataProtectionConsentMock *consentMock;
@property (strong, nonatomic) CR_DeviceInfo *deviceInfo;
@property (strong, nonatomic) CR_CacheAdUnit *demoCacheAdUnit;

@end

@implementation CR_WebApiIntegrationTests

- (void)setUp {
    NSString *userDefaultsId = NSStringFromClass(self.class);
    [[NSUserDefaults new] removePersistentDomainForName:userDefaultsId];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:userDefaultsId];

    self.deviceInfo = [[CR_DeviceInfo alloc] init];
    self.consentMock = [[CR_DataProtectionConsentMock alloc] init];
    self.config = [CR_Config configForPreprodWithCriteoPublisherId:CriteoTestingPublisherId
                                                      userDefaults:userDefaults];
    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    self.apiHandler = builder.apiHandler;

    CRBannerAdUnit *banner = [CR_TestAdUnits demoBanner320x50];
    self.demoCacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:banner];
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
    [self criteo_waitForExpectations:@[expectation]];
}

#pragma mark - Call CDB

- (void)testSendValidBidRequest {
    [self callCdbWithCacheAdUnit:self.demoCacheAdUnit
               completionHandler:^(CR_CdbRequest *cdbRequest,
                                   CR_CdbResponse *cdbResponse,
                                   NSError *error) {
        XCTAssertEqual(cdbResponse.cdbBids.count, 1);
        XCTAssertNil(error);
    }];
}

- (void)testSendValidBidRequestWithGdpr {
    self.consentMock.gdprMock.appliesValue = @YES;
    self.consentMock.gdprMock.consentStringValue = NSString.gdprConsentStringForTcf2_0;

    [self callCdbWithCacheAdUnit:self.demoCacheAdUnit
               completionHandler:^(CR_CdbRequest *cdbRequest,
                                   CR_CdbResponse *cdbResponse,
                                   NSError *error) {
        XCTAssertEqual(cdbResponse.cdbBids.count, 1);
        XCTAssertNil(error);
    }];
}

#pragma mark - Private

- (void)callCdbWithCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit
             completionHandler:(CR_CdbCompletionHandler)completionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:
                                      @"Bid webservice didn't call the completion handler"];

    [self.apiHandler callCdb:@[cacheAdUnit]
                     consent:self.consentMock
                      config:self.config
                  deviceInfo:self.deviceInfo
               beforeCdbCall:nil
           completionHandler:^(CR_CdbRequest *cdbRequest,
                               CR_CdbResponse *cdbResponse,
                               NSError *error) {
        if (completionHandler) {
            completionHandler(cdbRequest, cdbResponse, error);
        }
        [expectation fulfill];
    }];

    [self criteo_waitForExpectations:@[expectation]];
}

@end
