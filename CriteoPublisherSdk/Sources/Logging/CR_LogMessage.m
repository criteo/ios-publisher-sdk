//
//  CR_LogMessage.m
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

#import "CR_LogMessage.h"

@implementation CR_LogMessage

- (instancetype)initWithTag:(NSString *)tag
                   severity:(CR_LogSeverity)severity
                       file:(NSString *)file
                       line:(NSUInteger)line
                   function:(NSString *)function
                  timestamp:(NSDate *)timestamp
                  exception:(NSException *_Nullable)exception
                    message:(NSString *)message {
  self = [super init];
  if (self) {
    _tag = tag;
    _severity = severity;
    _file = file;
    _line = line;
    _function = function;
    _timestamp = timestamp;
    _exception = exception;
    _message = message;
  }

  return self;
}

+ (instancetype)messageWithTag:(NSString *)tag
                      severity:(CR_LogSeverity)severity
                          file:(const char *)file
                          line:(int)line
                      function:(const char *)function
                     exception:(NSException *_Nullable)exception
                        format:(NSString *)format, ... {
  va_list args;
  va_start(args, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
  return [[self alloc] initWithTag:tag
                          severity:severity
                              file:[NSString stringWithUTF8String:file]
                              line:(NSUInteger)line
                          function:[NSString stringWithUTF8String:function]
                         timestamp:[NSDate date]
                         exception:exception
                           message:message];
}

- (NSString *)severityLabel {
  switch (self.severity) {
    case CR_LogSeverityError:
      return @"🔴ERROR";
    case CR_LogSeverityWarning:
      return @"🟠WARN";
    case CR_LogSeverityInfo:
      return @"ℹ️INFO";
    case CR_LogSeverityDebug:
      return @"🐛DEBUG";
    case CR_LogSeverityNone:
      return @"🤦‍♂️NONE";
  }
}

- (NSString *)description {
  NSMutableString *description =
      [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"self.tag=%@", self.tag];
  [description appendFormat:@", self.severity=%@", self.severityLabel];
  [description appendFormat:@", self.file=%@", self.file];
  [description appendFormat:@", self.line=%lu", (unsigned long)self.line];
  [description appendFormat:@", self.function=%@", self.function];
  [description appendFormat:@", self.timestamp=%@", self.timestamp];
  [description appendFormat:@", self.exception=%@", self.exception];
  [description appendFormat:@", self.message=%@", self.message];
  [description appendString:@">"];
  return description;
}

@end
