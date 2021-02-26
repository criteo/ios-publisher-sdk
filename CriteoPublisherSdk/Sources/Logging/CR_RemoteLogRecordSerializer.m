//
//  CR_RemoteLogRecordSerializer.m
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

#import <UIKit/UIKit.h>
#import "CR_RemoteLogRecordSerializer.h"

@interface CR_RemoteLogRecordSerializer ()
@property(strong, nonatomic) NSString *deviceOs;
@end

@implementation CR_RemoteLogRecordSerializer

- (NSArray<NSDictionary<NSString *, NSObject *> *> *)serializeRecords:
    (NSArray<CR_RemoteLogRecord *> *)records {
  NSMutableArray *formattedArray = [NSMutableArray arrayWithCapacity:records.count];
  for (CR_RemoteLogRecord *record in records) {
    NSDictionary<NSString *, NSObject *> *dictionary = [self serializeRecord:record];
    [formattedArray addObject:dictionary];
  }
  return formattedArray;
}

- (NSDictionary<NSString *, NSObject *> *)serializeRecord:(CR_RemoteLogRecord *)record {
  // The exception type is nullable, so it is not possible to use @{} notation.
  NSMutableDictionary *context = [NSMutableDictionary new];
  context[@"version"] = record.version;
  context[@"bundleId"] = record.bundleId;
  context[@"deviceId"] = record.deviceId;
  context[@"deviceOs"] = self.deviceOs;
  context[@"sessionId"] = record.sessionId;
  context[@"profileId"] = record.profileId;
  context[@"tag"] = record.tag;
  context[@"exception"] = record.exceptionType;

  return @{
    @"context" : context,
    @"errors" : @[
      @{@"errorType" : [self formatSeverity:record.severity], @"messages" : @[ record.message ]}
    ]
  };
}

- (NSString *)formatSeverity:(CR_LogSeverity)severity {
  switch (severity) {
    case CR_LogSeverityError:
      return @"Error";
    case CR_LogSeverityWarning:
      return @"Warning";
    case CR_LogSeverityInfo:
      return @"Info";
    case CR_LogSeverityDebug:
      return @"Debug";
    case CR_LogSeverityNone:
      return @"None";
  }
}

- (NSString *)deviceOs {
  if (!_deviceOs) {
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    _deviceOs = [@"iOS" stringByAppendingString:systemVersion];
  }
  return _deviceOs;
}

@end