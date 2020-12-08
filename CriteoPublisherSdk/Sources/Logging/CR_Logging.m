//
//  CR_Logging.m
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

#import "CR_Logging.h"

@implementation CR_Logging

static const CR_LogSeverity crConsoleMinimumLogSeverityDefault = CR_LogSeverityWarning;
static CR_LogSeverity crConsoleMinimumLogSeverity = crConsoleMinimumLogSeverityDefault;

+ (void)logMessage:(CR_LogMessage *)logMessage {
  if (logMessage.severity <= crConsoleMinimumLogSeverity) {
    [self logMessageToConsole:logMessage];
  }
}

+ (void)setConsoleMinimumLogSeverity:(CR_LogSeverity)severity {
  crConsoleMinimumLogSeverity = severity;
}

+ (void)setConsoleMinimumLogSeverityToDefault {
  [self setConsoleMinimumLogSeverity:crConsoleMinimumLogSeverityDefault];
}

+ (CR_LogSeverity)consoleMinimumLogSeverity {
  return crConsoleMinimumLogSeverity;
}

#pragma mark - Private

+ (void)logMessageToConsole:(CR_LogMessage *)logMessage {
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