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

@interface CR_RemoteLogHandler ()
- (CR_RemoteLogRecord *_Nullable)remoteLogRecordFromLogMessage:(CR_LogMessage *)logMessage;
@end

@interface CR_RemoteLogHandlerTest : XCTestCase

@property(nonatomic, strong) CR_RemoteLogStorage *storage;
@property(nonatomic, strong) CR_RemoteLogHandler *handler;

@end

@implementation CR_RemoteLogHandlerTest

- (void)setUp {
  [super setUp];

  self.storage = OCMClassMock(CR_RemoteLogStorage.class);
  self.handler = [[CR_RemoteLogHandler alloc] initWithRemoteLogStorage:self.storage];
}

#pragma mark RemoteLogRecord handling

- (void)testHandling_GivenNullRecord_DoNothing {
  self.handler = OCMPartialMock(self.handler);
  OCMStub([self.handler remoteLogRecordFromLogMessage:OCMOCK_ANY]).andReturn(nil);

  [self.handler logMessage:[CR_LogMessage messageWithTag:@"tag"
                                                severity:CR_LogSeverityError
                                                    file:"myFile"
                                                    line:42
                                                function:"foobar"
                                               exception:nil
                                                  format:@"message"]];

  OCMVerify(never(), [self.storage pushRemoteLogRecord:OCMOCK_ANY]);
}

- (void)testHandling_GivenValidRecord_PushItInStorage {
  CR_RemoteLogRecord *remoteLogRecord = OCMClassMock(CR_RemoteLogRecord.class);

  self.handler = OCMPartialMock(self.handler);
  OCMStub([self.handler remoteLogRecordFromLogMessage:OCMOCK_ANY]).andReturn(remoteLogRecord);

  [self.handler logMessage:[CR_LogMessage messageWithTag:@"tag"
                                                severity:CR_LogSeverityError
                                                    file:"myFile"
                                                    line:42
                                                function:"foobar"
                                               exception:nil
                                                  format:@"message"]];

  OCMVerify([self.storage pushRemoteLogRecord:remoteLogRecord]);
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

  XCTAssertEqualObjects(record.tag, @"myTag");
  XCTAssertEqual(record.severity, CR_LogSeverityWarning);
  XCTAssertEqualObjects(record.message, @"myMessage,myFile:42,2042-06-22T13:37:28.000Z");
  XCTAssertNil(record.exceptionType);
}

@end