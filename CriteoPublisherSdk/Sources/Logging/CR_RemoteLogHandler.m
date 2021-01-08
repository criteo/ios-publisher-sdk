//
//  CR_RemoteLogHandler.m
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

#import "CR_RemoteLogHandler.h"
#import "CR_RemoteLogStorage.h"
#import "CR_RemoteLogRecord.h"
#import "CR_Config.h"

@interface CR_RemoteLogHandler ()

@property(nonatomic, readonly) CR_RemoteLogStorage *remoteLogStorage;
@property(nonatomic, readonly) CR_Config *config;

@end

@implementation CR_RemoteLogHandler

- (instancetype)initWithRemoteLogStorage:(CR_RemoteLogStorage *)remoteLogStorage
                                  config:(CR_Config *)config {
  self = [super init];
  if (self) {
    _remoteLogStorage = remoteLogStorage;
    _config = config;
  }

  return self;
}

- (void)logMessage:(CR_LogMessage *)message {
  // TODO EE-1374 check consent

  // TODO check log level

  CR_RemoteLogRecord *remoteLogRecord = [self remoteLogRecordFromLogMessage:message];
  if (remoteLogRecord != nil) {
    [self.remoteLogStorage pushRemoteLogRecord:remoteLogRecord];
  }
}

- (CR_RemoteLogRecord *_Nullable)remoteLogRecordFromLogMessage:(CR_LogMessage *)logMessage {
  NSString *message = [self messageBodyFromLogMessage:logMessage];
  if (message == nil) {
    return nil;
  }

  return [[CR_RemoteLogRecord alloc] initWithVersion:self.config.sdkVersion
                                            bundleId:self.config.appId
                                                 tag:logMessage.tag
                                            severity:logMessage.severity
                                             message:message
                                       exceptionType:logMessage.exception.name];
}

- (NSString *_Nullable)messageBodyFromLogMessage:(CR_LogMessage *)logMessage {
  if (logMessage.message.length == 0 && logMessage.exception == nil) {
    return nil;
  }

  NSString *formattedDate = [self.dateFormatter stringFromDate:logMessage.timestamp];

  // A script to read the logs is sensible to the format: date should always be at the end of the
  // message, separated with a ","
  if (logMessage.exception) {
    return [NSString
        stringWithFormat:@"%@\n--- Exception: %@\n--- Stack: %@\n--- User info: %@,%@:%lu,%@",
                         logMessage.message, logMessage.exception,
                         logMessage.exception.callStackSymbols, logMessage.exception.userInfo,
                         logMessage.file, (unsigned long)logMessage.line, formattedDate];
  } else {
    return [NSString stringWithFormat:@"%@,%@:%lu,%@", logMessage.message, logMessage.file,
                                      (unsigned long)logMessage.line, formattedDate];
  }
}

- (NSDateFormatter *)dateFormatter {
  static NSDateFormatter *formatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    formatter = NSDateFormatter.new;
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  });
  return formatter;
}

- (CR_ConsoleLogHandler *)consoleLogHandler {
  return nil;
}

@end