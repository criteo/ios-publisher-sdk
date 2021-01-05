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

@interface CR_LoggingFunctionalTests : XCTestCase
@property(nonatomic, strong) id loggingMock;
@property(nonatomic, strong) CR_ConsoleLogHandler *consoleLogHandlerMock;
@property(strong, nonatomic) Criteo *criteo;
@property(nonatomic, copy) NSString *publisherId;
@property(nonatomic, strong) NSArray<CRAdUnit *> *adUnits;
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation CR_LoggingFunctionalTests

#pragma mark - Lifecycle

- (void)setUp {
  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
  dependencyProvider.threadManager = CR_SynchronousThreadManager.new;
  self.userDefaults = dependencyProvider.userDefaults;

  self.loggingMock = OCMPartialMock(CR_Logging.sharedInstance);
  self.consoleLogHandlerMock = OCMPartialMock([[CR_ConsoleLogHandler alloc] init]);
  [CR_Logging setSharedLogHandler:self.consoleLogHandlerMock];
  self.criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProvider];
  self.publisherId = @"testPublisherId";
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
  [self.criteo registerCriteoPublisherId:self.publisherId withAdUnits:self.adUnits];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                NSString *message = logMessage.message;
                                return [logMessage.tag isEqualToString:@"Registration"] &&
                                       [message containsString:self.publisherId] &&
                                       [message containsString:self.adUnits.description];
                              }]]);
}

- (void)testCriteoRegisterTwice_ShouldBeLogged {
  [self.criteo registerCriteoPublisherId:self.publisherId withAdUnits:self.adUnits];
  OCMVerify([self.loggingMock logMessage:[OCMArg any]]);
  [self.criteo registerCriteoPublisherId:self.publisherId withAdUnits:self.adUnits];
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

- (void)testCriteoSetMoPubConsent_ShouldBeLogged {
  NSString *mopubConsent = @"MoPubConsent";
  [self.criteo setMopubConsent:mopubConsent];
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"Consent"] &&
                                       [logMessage.message containsString:@"MoPub"] &&
                                       [logMessage.message containsString:mopubConsent];
                              }]]);
}

- (void)testConsentInit_WhenNoTCFData_ShouldNotBeLogged {
  OCMReject([self.loggingMock logMessage:[OCMArg any]]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
  [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
#pragma clang diagnostic pop
}

- (void)testConsentInit_WhenTCFData_ShouldBeLogged {
  NSString *consentString = @"TestConsentString";
  [self.userDefaults setObject:@YES forKey:@"IABConsent_SubjectToGDPR"];
  [self.userDefaults setObject:consentString forKey:@"IABConsent_ConsentString"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
  [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
#pragma clang diagnostic pop
  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"Consent"] &&
                                       [logMessage.message containsString:consentString];
                              }]]);
}

@end
