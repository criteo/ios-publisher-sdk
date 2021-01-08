//
//  CR_RemoteLogRecordTests.m
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
#import "CR_RemoteLogRecord.h"

@interface CR_RemoteLogRecordTests : XCTestCase
@end

@implementation CR_RemoteLogRecordTests

- (void)testEncoding {
  CR_RemoteLogRecord *remoteLogRecord =
      [[CR_RemoteLogRecord alloc] initWithVersion:@"1.2.3"
                                         bundleId:@"myBundleId"
                                              tag:@"myTag"
                                         severity:CR_LogSeverityDebug
                                          message:@"myMessage"
                                    exceptionType:@"myExceptionType"];

  CR_RemoteLogRecord *unarchivedRecord = [self archiveAndUnarchiveRemoteLogRecord:remoteLogRecord];

  XCTAssertEqualObjects(unarchivedRecord.version, remoteLogRecord.version);
  XCTAssertEqualObjects(unarchivedRecord.bundleId, remoteLogRecord.bundleId);
  XCTAssertEqualObjects(unarchivedRecord.tag, remoteLogRecord.tag);
  XCTAssertEqual(unarchivedRecord.severity, remoteLogRecord.severity);
  XCTAssertEqualObjects(unarchivedRecord.message, remoteLogRecord.message);
  XCTAssertEqualObjects(unarchivedRecord.exceptionType, remoteLogRecord.exceptionType);
}

- (CR_RemoteLogRecord *)archiveAndUnarchiveRemoteLogRecord:(CR_RemoteLogRecord *)remoteLogRecord {
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:remoteLogRecord];
  return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
