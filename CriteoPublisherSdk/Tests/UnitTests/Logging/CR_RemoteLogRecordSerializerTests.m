//
//  CR_RemoteLogRecordSerializerTests.m
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
#import "CR_RemoteLogRecordSerializer.h"

@interface CR_RemoteLogRecordSerializerTests : XCTestCase
@end

@implementation CR_RemoteLogRecordSerializerTests

- (void)testSerialization_GivenRecords_ReturnExpectedPayload {
  NSArray<CR_RemoteLogRecord *> *records = @[
    [[CR_RemoteLogRecord alloc] initWithVersion:@"1.2.3"
                                       bundleId:@"org.dummy.bundle"
                                       deviceId:@"my-device-id"
                                      sessionId:@"my-session-id"
                                      profileId:@42
                                            tag:@"myTag"
                                       severity:CR_LogSeverityDebug
                                        message:@"message"
                                  exceptionType:nil],
    [[CR_RemoteLogRecord alloc] initWithVersion:@"4.5.6"
                                       bundleId:@"org.dummy.bundle2"
                                       deviceId:@"my-device-id2"
                                      sessionId:@"my-session-id2"
                                      profileId:@1337
                                            tag:@"myTag2"
                                       severity:CR_LogSeverityInfo
                                        message:@"message2"
                                  exceptionType:@"NullPointerException"]
  ];

  CR_RemoteLogRecordSerializer *serializer = CR_RemoteLogRecordSerializer.new;
  NSArray<NSDictionary<NSString *, NSObject *> *> *body = [serializer serializeRecords:records];
  NSString *json = [self jsonStringFromDictionaryArray:body];

  NSString *expected = @"[\n"
                        "  {\n"
                        "    \"context\": {\n"
                        "      \"tag\": \"myTag\",\n"
                        "      \"deviceId\": \"my-device-id\",\n"
                        "      \"profileId\": 42,\n"
                        "      \"sessionId\": \"my-session-id\",\n"
                        "      \"bundleId\": \"org.dummy.bundle\",\n"
                        "      \"version\": \"1.2.3\"\n"
                        "    },\n"
                        "    \"errors\": [\n"
                        "      {\n"
                        "        \"messages\": [\n"
                        "          \"message\"\n"
                        "        ],\n"
                        "        \"errorType\": \"Debug\"\n"
                        "      }\n"
                        "    ]\n"
                        "  },\n"
                        "  {\n"
                        "    \"context\": {\n"
                        "      \"deviceId\": \"my-device-id2\",\n"
                        "      \"sessionId\": \"my-session-id2\",\n"
                        "      \"tag\": \"myTag2\",\n"
                        "      \"bundleId\": \"org.dummy.bundle2\",\n"
                        "      \"exception\": \"NullPointerException\",\n"
                        "      \"profileId\": 1337,\n"
                        "      \"version\": \"4.5.6\"\n"
                        "    },\n"
                        "    \"errors\": [\n"
                        "      {\n"
                        "        \"messages\": [\n"
                        "          \"message2\"\n"
                        "        ],\n"
                        "        \"errorType\": \"Info\"\n"
                        "      }\n"
                        "    ]\n"
                        "  }\n"
                        "]";

  XCTAssertEqualObjects([self normalizeJsonString:json], [self normalizeJsonString:expected]);
}

#pragma mark Private

- (NSString *)normalizeJsonString:(NSString *)jsonString {
  return [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""]
      stringByReplacingOccurrencesOfString:@"\n"
                                withString:@""];
}

- (NSString *)jsonStringFromDictionaryArray:(NSArray<NSDictionary *> *)dictionaryArray {
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionaryArray
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:nil];

  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end