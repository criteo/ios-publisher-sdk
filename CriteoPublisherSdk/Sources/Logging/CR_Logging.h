//
//  CR_Logging.h
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

#import "CR_LogHandler.h"
#import "CR_LogMessage.h"

#define CRLog(severity, tag, args...) [CR_Logging logMessage:CRLogMessage(tag, severity, nil, args)]
#define CRLogException(tag, exception, args...) \
  [CR_Logging logMessage:CRLogMessage(tag, CR_LogSeverityError, exception, args)]

#define CRLogError(tag, args...) CRLog(CR_LogSeverityError, tag, args)
#define CRLogInfo(tag, args...) CRLog(CR_LogSeverityInfo, tag, args)
#define CRLogWarn(tag, args...) CRLog(CR_LogSeverityWarning, tag, args)
#define CRLogDebug(tag, args...) CRLog(CR_LogSeverityDebug, tag, args)

NS_ASSUME_NONNULL_BEGIN

@interface CR_Logging : NSObject <CR_LogHandler>

- (instancetype)initWithLogHandler:(id<CR_LogHandler>)handler;

+ (void)logMessage:(CR_LogMessage *)message;
+ (instancetype)sharedInstance;

+ (CR_LogSeverity)consoleLogSeverityThreshold;
+ (void)setConsoleSeverityThreshold:(CR_LogSeverity)severity;

@end

NS_ASSUME_NONNULL_END
