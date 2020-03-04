//
//  CR_WebApiIntegrationTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 3/4/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_ApiHandler.h"
#import "CR_BidManagerBuilder.h"
#import "CR_Config.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_DeviceInfo.h"
#import "Criteo+Testing.h"
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

@end

@implementation CR_WebApiIntegrationTests

- (void)setUp {
    self.deviceInfo = [[CR_DeviceInfo alloc] init];
    self.consentMock = [[CR_DataProtectionConsentMock alloc] init];
    self.config = [CR_Config configForPreprodWithCriteoPublisherId:CriteoTestingPublisherId];
    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    self.apiHandler = builder.apiHandler;
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

@end
