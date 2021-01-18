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
#import "CR_DeviceInfo.h"
#import "CR_IntegrationRegistry.h"
#import "CR_Session.h"
#import "CR_DataProtectionConsent.h"
#import "CR_ApiHandler.h"
#import "CR_ThreadManager.h"

// The batch size of logs sent, at most, in each remote logs request.
static NSUInteger const CR_RemoteLogHandlerLogBatchSize = 200;

@interface CR_RemoteLogHandler ()

@property(nonatomic, readonly) CR_RemoteLogStorage *remoteLogStorage;
@property(nonatomic, readonly) CR_Config *config;
@property(nonatomic, readonly) CR_DeviceInfo *deviceInfo;
@property(nonatomic, readonly) CR_IntegrationRegistry *integrationRegistry;
@property(nonatomic, readonly) CR_Session *session;
@property(nonatomic, readonly) CR_DataProtectionConsent *consent;
@property(nonatomic, readonly) CR_ApiHandler *apiHandler;
@property(nonatomic, readonly) CR_ThreadManager *threadManager;

@end

@implementation CR_RemoteLogHandler

- (instancetype)initWithRemoteLogStorage:(CR_RemoteLogStorage *)remoteLogStorage
                                  config:(CR_Config *)config
                              deviceInfo:(CR_DeviceInfo *)deviceInfo
                     integrationRegistry:(CR_IntegrationRegistry *)integrationRegistry
                                 session:(CR_Session *)session
                                 consent:(CR_DataProtectionConsent *)consent
                              apiHandler:(CR_ApiHandler *)apiHandler
                           threadManager:(CR_ThreadManager *)threadManager {
  self = [super init];
  if (self) {
    _remoteLogStorage = remoteLogStorage;
    _config = config;
    _deviceInfo = deviceInfo;
    _integrationRegistry = integrationRegistry;
    _session = session;
    _consent = consent;
    _apiHandler = apiHandler;
    _threadManager = threadManager;
  }

  return self;
}

#pragma mark LogHandler

- (CR_ConsoleLogHandler *)consoleLogHandler {
  return nil;
}

- (void)logMessage:(CR_LogMessage *)message {
  if (!self.consent.isConsentGiven) {
    return;
  }

  if (message.severity > self.config.remoteLogLevel) {
    return;
  }

  CR_RemoteLogRecord *remoteLogRecord = [self remoteLogRecordFromLogMessage:message];
  if (remoteLogRecord != nil) {
    [self.threadManager dispatchAsyncOnGlobalQueue:^{
      [self.remoteLogStorage pushRemoteLogRecord:remoteLogRecord];
    }];
  }
}

#pragma mark Formatting

- (CR_RemoteLogRecord *_Nullable)remoteLogRecordFromLogMessage:(CR_LogMessage *)logMessage {
  NSString *message = [self messageBodyFromLogMessage:logMessage];
  if (message == nil) {
    return nil;
  }

  return [[CR_RemoteLogRecord alloc] initWithVersion:self.config.sdkVersion
                                            bundleId:self.config.appId
                                            deviceId:self.deviceInfo.deviceId
                                           sessionId:self.session.sessionId
                                           profileId:self.integrationRegistry.profileId
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
  NSString *filename = logMessage.file.lastPathComponent;

  // A script to read the logs is sensible to the format: date should always be at the end of the
  // message, separated with a ","
  if (logMessage.exception) {
    return [NSString
        stringWithFormat:@"%@\n--- Exception: %@\n--- Stack: %@\n--- User info: %@,%@:%lu,%@",
                         logMessage.message, logMessage.exception,
                         logMessage.exception.callStackSymbols, logMessage.exception.userInfo,
                         filename, (unsigned long)logMessage.line, formattedDate];
  } else {
    return [NSString stringWithFormat:@"%@,%@:%lu,%@", logMessage.message, filename,
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

#pragma mark Sending

- (void)sendRemoteLogBatch {
  [self.threadManager dispatchAsyncOnGlobalQueue:^{
    NSArray<CR_RemoteLogRecord *> *records =
        [self.remoteLogStorage popRemoteLogRecords:CR_RemoteLogHandlerLogBatchSize];
    [self.apiHandler sendLogs:records
                       config:self.config
            completionHandler:^(NSError *error) {
              if (error) {
                for (CR_RemoteLogRecord *record in records) {
                  [self.remoteLogStorage pushRemoteLogRecord:record];
                }
              }
            }];
  }];
}

@end