//
//  CR_LoggingFunctionalTests.m
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

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CriteoPublisherSdk.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_Logging.h"
#import "CR_SynchronousThreadManager.h"
#import "CR_DataProtectionConsent.h"
#import "CR_ApiHandler.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"

@interface CR_Logging (Testing)
+ (Criteo *)sharedCriteo;
@end

@interface CR_LoggingFunctionalTests : XCTestCase
@property(nonatomic, strong) id loggingMock;
@property(nonatomic, strong) CR_ConsoleLogHandler *consoleLogHandlerMock;
@property(strong, nonatomic) Criteo *criteo;
@property(nonatomic, copy) NSString *publisherId;
@property(nonatomic, copy) NSString *inventoryGroupId;
@property(nonatomic, strong) NSArray<CRAdUnit *> *adUnits;
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) CR_ApiHandler *apiHandler;
@property(nonatomic, copy) NSString *storeId;
@end

@implementation CR_LoggingFunctionalTests

#pragma mark - Lifecycle

- (void)setUp {
  self.consoleLogHandlerMock = OCMPartialMock([[CR_ConsoleLogHandler alloc] init]);

  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
  dependencyProvider.threadManager = CR_SynchronousThreadManager.new;
  dependencyProvider.consoleLogHandler = self.consoleLogHandlerMock;
  self.userDefaults = dependencyProvider.userDefaults;

  self.apiHandler = OCMPartialMock(dependencyProvider.apiHandler);
  dependencyProvider.apiHandler = self.apiHandler;

  self.criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProvider];

  self.loggingMock = OCMPartialMock(dependencyProvider.logging);
  OCMStub([self.loggingMock sharedCriteo]).andReturn(self.criteo);
  dependencyProvider.logging = self.loggingMock;

  self.publisherId = @"testPublisherId";
  self.inventoryGroupId = @"testInventoryGroupId";
  self.storeId = @"testStoreId";
  self.adUnits = @[
    [[CRBannerAdUnit alloc] initWithAdUnitId:@"adUnitId1" size:CGSizeMake(42, 21)],
    [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"adUnitId2"],
    [[CRNativeAdUnit alloc] initWithAdUnitId:@"adUnitId3"]
  ];
}

- (void)tearDown {
  [self.loggingMock stopMocking];
}

#pragma mark - Tests

#pragma mark Console minimum level

- (void)testConsoleMinimumLogSeverityDefaultToWarn {
  [Criteo setVerboseLogsEnabled:NO];
  CR_LogSeverity defaultSeverity = CR_LogSeverityWarning;
  XCTAssertEqual(self.consoleLogHandlerMock.severityThreshold, defaultSeverity);
  OCMReject([self.consoleLogHandlerMock
      logMessageToConsole:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
        return logMessage.severity > defaultSeverity;
      }]]);

  CRLogError(@"Test", @"Test");
  CRLogWarn(@"Test", @"Test");
  CRLogInfo(@"Test", @"Test");
  CRLogDebug(@"Test", @"Test");

  OCMVerify(times(2),
            [self.consoleLogHandlerMock
                logMessageToConsole:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                  return logMessage.severity <= defaultSeverity;
                }]]);
}

- (void)testConsoleMinimumLogSeverityWhenSet {
  CR_LogSeverity severitySet = CR_LogSeverityDebug;
  self.consoleLogHandlerMock.severityThreshold = severitySet;
  OCMReject([self.consoleLogHandlerMock
      logMessageToConsole:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
        return logMessage.severity > severitySet;
      }]]);
  CRLogError(@"Test", @"Test");
  CRLogWarn(@"Test", @"Test");
  CRLogInfo(@"Test", @"Test");
  CRLogDebug(@"Test", @"Test");
  OCMVerify(times(4),
            [self.consoleLogHandlerMock
                logMessageToConsole:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                  return logMessage.severity <= severitySet;
                }]]);
}

#pragma mark Criteo

- (void)testVerboseLogsEnabled {
  XCTAssertEqual([CR_Logging consoleLogSeverityThreshold], CR_LogSeverityWarning);
  [Criteo setVerboseLogsEnabled:YES];
  XCTAssertEqual([CR_Logging consoleLogSeverityThreshold], CR_LogSeverityInfo);
  [Criteo setVerboseLogsEnabled:NO];
  XCTAssertEqual([CR_Logging consoleLogSeverityThreshold], CR_LogSeverityWarning);
}

- (void)testCriteoRegister_ShouldBeLogged {
  [self.criteo registerCriteoPublisherId:self.publisherId withStoreId:@"" withAdUnits:self.adUnits];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                NSString *message = logMessage.message;
                                return [logMessage.tag isEqualToString:@"Registration"] &&
                                       [message containsString:self.publisherId] &&
                                       [message containsString:self.adUnits.description];
                              }]]);
}

- (void)testCriteoRegisterWithInventoryGroupId_ShouldBeLogged {
  [self.criteo registerCriteoPublisherId:self.publisherId
                    withInventoryGroupId:self.inventoryGroupId
                             withStoreId:@""
                             withAdUnits:self.adUnits];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                NSString *message = logMessage.message;
                                return [logMessage.tag isEqualToString:@"Registration"] &&
                                       [message containsString:self.publisherId] &&
                                       [message containsString:self.adUnits.description];
                              }]]);
}

- (void)testCriteoRegisterTwice_ShouldBeLogged {
  [self.criteo registerCriteoPublisherId:self.publisherId
                             withStoreId:self.storeId
                             withAdUnits:self.adUnits];
  OCMVerify([self.loggingMock logMessage:[OCMArg any]]);
  [self.criteo registerCriteoPublisherId:self.publisherId
                             withStoreId:self.storeId
                             withAdUnits:self.adUnits];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"Registration"] &&
                                       logMessage.severity == CR_LogSeverityInfo &&
                                       [logMessage.message containsString:@"once"];
                              }]]);
}

#pragma mark Consent

- (void)testCriteoSetUsPrivacyOptOut_ShouldBeLogged {
  [self.criteo setUsPrivacyOptOut:YES];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"Consent"] &&
                                       [logMessage.message containsString:@"CCPA"];
                              }]]);
}

- (void)testInit_WhenTCFData_ShouldBeLogged {
  NSString *consentString = @"TestConsentString";
  [self.userDefaults setObject:@YES forKey:@"IABConsent_SubjectToGDPR"];
  [self.userDefaults setObject:consentString forKey:@"IABConsent_ConsentString"];

  [self.criteo setup];

  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"Consent"] &&
                                       [logMessage.message containsString:consentString];
                              }]]);
}

#pragma mark RemoteLog

- (void)testRemoteLog_GivenLogAndBid_ThenRemoteLogsAreSent {
  CRLogError(@"tag", @"message");

  [self.criteo loadBidForAdUnit:CR_TestAdUnits.randomBanner320x50
                responseHandler:^(CRBid *bid){
                    // ignored
                }];

  [self.criteo.threadManager waiter_waitIdle];

  OCMVerify([self.apiHandler sendLogs:OCMOCK_ANY config:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

@end
