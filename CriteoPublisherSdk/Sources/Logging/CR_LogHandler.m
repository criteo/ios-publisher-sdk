//
//  CR_LogHandler.m
//  CriteoPublisherSdk
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

#import "CR_LogHandler.h"

static const CR_LogSeverity crConsoleSeverityThresholdDefault = CR_LogSeverityWarning;

@implementation CR_ConsoleLogHandler

@synthesize severityThreshold = _severityThreshold;

#pragma mark - Lifecycle

- (instancetype)init {
  if (self = [super init]) {
    _severityThreshold = crConsoleSeverityThresholdDefault;
  }
  return self;
}

#pragma mark - LogHandler

- (void)logMessage:(CR_LogMessage *)message {
  if (message.severity <= self.severityThreshold) {
    [self logMessageToConsole:message];
  }
}

- (CR_ConsoleLogHandler *)consoleLogHandler {
  return self;
}

- (void)setSeverityThreshold:(CR_LogSeverity)severityThreshold {
  _severityThreshold = severityThreshold;
}

#pragma mark - Private

- (void)logMessageToConsole:(CR_LogMessage *)logMessage {
  NSString *filename = logMessage.file.lastPathComponent;
  if (logMessage.exception) {
    NSLog(@"[CriteoSdk][%@][%@] (%@:%lu) [%@] %@"
           "\n--- Exception: %@\n--- Stack: %@\n--- User info: %@",
          logMessage.severityLabel, logMessage.tag, filename, (unsigned long)logMessage.line,
          logMessage.exception.name, logMessage.message, logMessage.exception,
          logMessage.exception.callStackSymbols, logMessage.exception.userInfo);
  } else {
    NSLog(@"[CriteoSdk][%@][%@] (%@:%lu) %@", logMessage.severityLabel, logMessage.tag, filename,
          (unsigned long)logMessage.line, logMessage.message);
  }
}

@end

@implementation CR_MultiplexLogHandler

#pragma mark - Lifecycle

- (instancetype)initWithLogHandlers:(NSArray *)logHandlers {
  if (self = [super init]) {
    _logHandlers = logHandlers;
  }
  return self;
}

#pragma mark - LogHandler

- (void)logMessage:(CR_LogMessage *)message {
  for (id<CR_LogHandler> handler in self.logHandlers) {
    @try {
      [handler logMessage:message];
    } @catch (NSException *exception) {
      NSLog(@"[Logging] Exception occurred: %@, %@", exception, [exception userInfo]);
    }
  }
}

- (CR_ConsoleLogHandler *)consoleLogHandler {
  for (id<CR_LogHandler> logHandler in self.logHandlers) {
    if (logHandler.consoleLogHandler) {
      return logHandler.consoleLogHandler;
    }
  }
  return nil;
}

@end
