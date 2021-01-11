//
//  CR_RemoteLogHandlerTest.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2021 Criteo. All rights reserved.
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
#import <OCMock/OCMock.h>
#import "CR_Logging.h"
#import "CR_RemoteLogHandler.h"
#import "CR_RemoteLogStorage.h"
#import "CR_RemoteLogRecord.h"
#import "CR_Config.h"
#import "CR_DeviceInfo.h"
#import "CR_IntegrationRegistry.h"
#import "CR_Session.h"
#import "CR_DataProtectionConsent.h"
#import "CR_InMemoryUserDefaults.h"

@interface CR_RemoteLogHandler ()
- (CR_RemoteLogRecord *_Nullable)remoteLogRecordFromLogMessage:(CR_LogMessage *)logMessage;
@end

@interface CR_RemoteLogHandlerTest : XCTestCase

@property(nonatomic, strong) CR_DataProtectionConsent *consent;
@property(nonatomic, strong) CR_Session *session;
@property(nonatomic, strong) CR_IntegrationRegistry *integrationRegistry;
@property(nonatomic, strong) CR_DeviceInfo *deviceInfo;
@property(nonatomic, strong) CR_Config *config;
@property(nonatomic, strong) CR_RemoteLogStorage *storage;
@property(nonatomic, strong) CR_RemoteLogHandler *handler;

@end

@implementation CR_RemoteLogHandlerTest

- (void)setUp {
  [super setUp];

  NSUserDefaults *userDefaults = [[CR_InMemoryUserDefaults alloc] init];

  self.storage = OCMClassMock(CR_RemoteLogStorage.class);
  self.config = OCMClassMock(CR_Config.class);
  self.deviceInfo = OCMClassMock(CR_DeviceInfo.class);
  self.integrationRegistry = OCMClassMock(CR_IntegrationRegistry.class);
  self.session = OCMClassMock(CR_Session.class);
  self.consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:userDefaults];
  self.handler = [[CR_RemoteLogHandler alloc] initWithRemoteLogStorage:self.storage
                                                                config:self.config
                                                            deviceInfo:self.deviceInfo
                                                   integrationRegistry:self.integrationRegistry
                                                               session:self.session
                                                               consent:self.consent];

  self.consent.consentGiven = YES;
}

#pragma mark Consent

- (void)testConsent_GivenNoConsent_DoNothing {
  CR_LogMessage *logMessage = [self validLogMessage:CR_LogSeverityError];

  self.handler = OCMPartialMock(self.handler);

  OCMStub([self.config remoteLogLevel]).andReturn(CR_LogSeverityInfo);
  self.consent.consentGiven = NO;

  [self.handler logMessage:logMessage];

  OCMVerify(never(), [self.handler remoteLogRecordFromLogMessage:OCMOCK_ANY]);
  OCMVerify(never(), [self.storage pushRemoteLogRecord:OCMOCK_ANY]);
}

#pragma mark RemoteLogRecord handling

- (void)testHandling_GivenNullRecord_DoNothing {
  self.handler = OCMPartialMock(self.handler);
  OCMStub([self.handler remoteLogRecordFromLogMessage:OCMOCK_ANY]).andReturn(nil);
  OCMStub([self.config remoteLogLevel]).andReturn(CR_LogSeverityDebug);

  [self.handler logMessage:[self validLogMessage:CR_LogSeverityError]];

  OCMVerify(never(), [self.storage pushRemoteLogRecord:OCMOCK_ANY]);
}

- (void)testHandling_GivenValidRecord_PushItInStorage {
  CR_RemoteLogRecord *remoteLogRecordDebug = OCMClassMock(CR_RemoteLogRecord.class);
  CR_RemoteLogRecord *remoteLogRecordInfo = OCMClassMock(CR_RemoteLogRecord.class);
  CR_RemoteLogRecord *remoteLogRecordWarning = OCMClassMock(CR_RemoteLogRecord.class);
  CR_RemoteLogRecord *remoteLogRecordError = OCMClassMock(CR_RemoteLogRecord.class);

  CR_LogMessage *logMessageDebug = [self validLogMessage:CR_LogSeverityDebug];
  CR_LogMessage *logMessageInfo = [self validLogMessage:CR_LogSeverityInfo];
  CR_LogMessage *logMessageWarning = [self validLogMessage:CR_LogSeverityWarning];
  CR_LogMessage *logMessageError = [self validLogMessage:CR_LogSeverityError];

  self.handler = OCMPartialMock(self.handler);
  OCMStub([self.handler remoteLogRecordFromLogMessage:logMessageDebug])
      .andReturn(remoteLogRecordDebug);
  OCMStub([self.handler remoteLogRecordFromLogMessage:logMessageInfo])
      .andReturn(remoteLogRecordInfo);
  OCMStub([self.handler remoteLogRecordFromLogMessage:logMessageWarning])
      .andReturn(remoteLogRecordWarning);
  OCMStub([self.handler remoteLogRecordFromLogMessage:logMessageError])
      .andReturn(remoteLogRecordError);

  OCMStub([self.config remoteLogLevel]).andReturn(CR_LogSeverityInfo);

  [self.handler logMessage:logMessageDebug];
  [self.handler logMessage:logMessageInfo];
  [self.handler logMessage:logMessageWarning];
  [self.handler logMessage:logMessageError];

  OCMVerify(never(), [self.storage pushRemoteLogRecord:remoteLogRecordDebug]);
  OCMVerify(times(1), [self.storage pushRemoteLogRecord:remoteLogRecordInfo]);
  OCMVerify(times(1), [self.storage pushRemoteLogRecord:remoteLogRecordWarning]);
  OCMVerify(times(1), [self.storage pushRemoteLogRecord:remoteLogRecordError]);
}

- (CR_LogMessage *)validLogMessage:(CR_LogSeverity)severity {
  return [CR_LogMessage messageWithTag:@"tag"
                              severity:severity
                                  file:"myFile"
                                  line:42
                              function:"foobar"
                             exception:nil
                                format:@"message"];
}

#pragma mark RemoteLogRecord from LogMessage

- (void)testMapping_GivenNoMessageNorException_ReturnNull {
  CR_LogMessage *logMessage = [CR_LogMessage messageWithTag:@"myTag"
                                                   severity:CR_LogSeverityError
                                                       file:"myFile"
                                                       line:42
                                                   function:"foobar"
                                                  exception:nil
                                                     format:@""];

  CR_RemoteLogRecord *record = [self.handler remoteLogRecordFromLogMessage:logMessage];

  XCTAssertNil(record);
}

- (void)testMapping_GivenLogWithBothMessageAndException_ReturnRecord {
  OCMStub([self.config sdkVersion]).andReturn(@"1.2.3");
  OCMStub([self.config appId]).andReturn(@"myBundleId");
  OCMStub([self.deviceInfo deviceId]).andReturn(@"myDeviceId");
  OCMStub([self.integrationRegistry profileId]).andReturn(@42);
  OCMStub([self.session sessionId]).andReturn(@"mySessionId");

  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setDay:22];
  [components setMonth:6];
  [components setYear:2042];
  [components setHour:14];
  [components setMinute:37];
  [components setSecond:28];
  [components setNanosecond:12300000];

  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSTimeZone *gmtPlus1 = [NSTimeZone timeZoneForSecondsFromGMT:3600];
  [calendar setTimeZone:gmtPlus1];
  NSDate *date = [calendar dateFromComponents:components];

  NSException *exception = [NSException exceptionWithName:@"myExceptionType"
                                                   reason:@"dummy reason"
                                                 userInfo:@{@"dummy" : @"info"}];

  CR_LogMessage *logMessage = [[CR_LogMessage alloc] initWithTag:@"myTag"
                                                        severity:CR_LogSeverityError
                                                            file:@"myFile"
                                                            line:42
                                                        function:@"foobar"
                                                       timestamp:date
                                                       exception:exception
                                                         message:@"myMessage"];

  CR_RemoteLogRecord *record = [self.handler remoteLogRecordFromLogMessage:logMessage];

  XCTAssertEqualObjects(record.version, @"1.2.3");
  XCTAssertEqualObjects(record.bundleId, @"myBundleId");
  XCTAssertEqualObjects(record.deviceId, @"myDeviceId");
  XCTAssertEqualObjects(record.profileId, @42);
  XCTAssertEqualObjects(record.sessionId, @"mySessionId");
  XCTAssertEqualObjects(record.tag, @"myTag");
  XCTAssertEqual(record.severity, CR_LogSeverityError);
  XCTAssertEqualObjects(record.message, @"myMessage\n"
                                         "--- Exception: dummy reason\n"
                                         "--- Stack: (null)\n"
                                         "--- User info: {\n"
                                         "    dummy = info;\n"
                                         "},myFile:42,2042-06-22T13:37:28.012Z");
  XCTAssertEqualObjects(record.exceptionType, @"myExceptionType");
}

- (void)testMapping_GivenLogWithOnlyMessage_ReturnRecordWithoutException {
  OCMStub([self.config sdkVersion]).andReturn(@"1.2.3");
  OCMStub([self.config appId]).andReturn(@"myBundleId");
  OCMStub([self.deviceInfo deviceId]).andReturn(@"myDeviceId");
  OCMStub([self.integrationRegistry profileId]).andReturn(@42);
  OCMStub([self.session sessionId]).andReturn(@"mySessionId");

  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setDay:22];
  [components setMonth:6];
  [components setYear:2042];
  [components setHour:15];
  [components setMinute:37];
  [components setSecond:28];
  [components setNanosecond:123000];

  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSTimeZone *gmtPlus2 = [NSTimeZone timeZoneForSecondsFromGMT:2 * 3600];
  [calendar setTimeZone:gmtPlus2];
  NSDate *date = [calendar dateFromComponents:components];

  CR_LogMessage *logMessage = [[CR_LogMessage alloc] initWithTag:@"myTag"
                                                        severity:CR_LogSeverityWarning
                                                            file:@"myFile"
                                                            line:42
                                                        function:@"foobar"
                                                       timestamp:date
                                                       exception:nil
                                                         message:@"myMessage"];

  CR_RemoteLogRecord *record = [self.handler remoteLogRecordFromLogMessage:logMessage];

  XCTAssertEqualObjects(record.version, @"1.2.3");
  XCTAssertEqualObjects(record.bundleId, @"myBundleId");
  XCTAssertEqualObjects(record.deviceId, @"myDeviceId");
  XCTAssertEqualObjects(record.profileId, @42);
  XCTAssertEqualObjects(record.sessionId, @"mySessionId");
  XCTAssertEqualObjects(record.tag, @"myTag");
  XCTAssertEqual(record.severity, CR_LogSeverityWarning);
  XCTAssertEqualObjects(record.message, @"myMessage,myFile:42,2042-06-22T13:37:28.000Z");
  XCTAssertNil(record.exceptionType);
}

@end