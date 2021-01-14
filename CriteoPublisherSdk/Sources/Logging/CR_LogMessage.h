//
//  CR_LogMessage.h
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

#import <Foundation/Foundation.h>

#define CRLogMessage(TAG, SEVERITY, EXCEPTION, ARGS...) \
  [CR_LogMessage messageWithTag:TAG                     \
                       severity:SEVERITY                \
                           file:__FILE__                \
                           line:__LINE__                \
                       function:__PRETTY_FUNCTION__     \
                      exception:EXCEPTION               \
                         format:ARGS]

// Note: Values are following syslog protocol: https://www.rfc-editor.org/info/rfc5424, extended
// with None
typedef NS_ENUM(NSInteger, CR_LogSeverity) {
  /// Logging is deactivated
  CR_LogSeverityNone = -1,
  /// Error: error conditions
  CR_LogSeverityError = 3,
  /// Warning: warning conditions
  CR_LogSeverityWarning = 4,
  /// Informational: informational messages
  CR_LogSeverityInfo = 6,
  /// Debug: debug-level messages
  CR_LogSeverityDebug = 7,
};

NS_ASSUME_NONNULL_BEGIN

@interface CR_LogMessage : NSObject

@property(nonatomic, readonly, copy) NSString *tag;
@property(nonatomic, readonly, assign) CR_LogSeverity severity;
@property(nonatomic, readonly, copy) NSString *severityLabel;
@property(nonatomic, readonly, copy) NSString *file;
@property(nonatomic, readonly, assign) NSUInteger line;
@property(nonatomic, readonly, copy) NSString *function;
@property(nonatomic, readonly, copy) NSDate *timestamp;
@property(nonatomic, readonly, copy, nullable) NSException *exception;
@property(nonatomic, readonly, copy) NSString *message;

- (instancetype)initWithTag:(NSString *)tag
                   severity:(CR_LogSeverity)severity
                       file:(NSString *)file
                       line:(NSUInteger)line
                   function:(NSString *)function
                  timestamp:(NSDate *)timestamp
                  exception:(NSException *_Nullable)exception
                    message:(NSString *)message;

+ (instancetype)messageWithTag:(NSString *)tag
                      severity:(CR_LogSeverity)severity
                          file:(const char *)file
                          line:(int)line
                      function:(const char *)function
                     exception:(NSException *_Nullable)exception
                        format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
