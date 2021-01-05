//
//  CR_LogHandler.h
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

#import "CR_LogMessage.h"

@class CR_ConsoleLogHandler;

@protocol CR_LogHandler <NSObject>
@property(nonatomic, readonly) CR_ConsoleLogHandler *consoleLogHandler;
- (void)logMessage:(CR_LogMessage *)message;
@end

@protocol CR_LogHandlerWithThreshold <CR_LogHandler>
@property(nonatomic, assign) CR_LogSeverity severityThreshold;
@end

@interface CR_ConsoleLogHandler : NSObject <CR_LogHandlerWithThreshold>
@end

@interface CR_ConsoleLogHandler (Testing)
- (void)logMessageToConsole:(CR_LogMessage *)logMessage;
@end

@interface CR_MultiplexLogHandler : NSObject <CR_LogHandler>
@property(nonatomic, readonly) NSArray<id<CR_LogHandler>> *logHandlers;
- (instancetype)initWithLogHandlers:(NSArray *)logHandlers;
@end
