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
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider.h"

static NSString *const crLogRecursionDepthKey = @"crLogRecursionDepth";
static NSUInteger const crLogRecursionDepthMax = 3;

@interface CR_Logging ()
@property(atomic, strong) id<CR_LogHandler> logHandler;
@end

@implementation CR_Logging

#pragma mark - Lifecycle

- (instancetype)initWithLogHandler:(id<CR_LogHandler>)handler {
  if (self = [super init]) {
    self.logHandler = handler;
  }
  return self;
}

#pragma mark - Singleton

+ (instancetype)sharedInstance {
  return self.sharedCriteo.dependencyProvider.logging;
}

+ (Criteo *)sharedCriteo {
  return Criteo.sharedCriteo;
}

+ (void)logMessage:(CR_LogMessage *)message {
  [self.sharedInstance logMessage:message];
}

+ (id<CR_LogHandler>)sharedLogHandler {
  return ((CR_Logging *)self.sharedInstance).logHandler;
}

+ (CR_ConsoleLogHandler *)consoleLogHandler {
  return self.sharedLogHandler.consoleLogHandler;
}

+ (void)setConsoleSeverityThreshold:(CR_LogSeverity)severity {
  self.consoleLogHandler.severityThreshold = severity;
}

+ (CR_LogSeverity)consoleLogSeverityThreshold {
  return self.consoleLogHandler.severityThreshold;
}

#pragma mark - LogHandler

- (void)logMessage:(CR_LogMessage *)message {
  NSMutableDictionary *threadDictionary = NSThread.currentThread.threadDictionary;
  NSInteger depth = [threadDictionary[crLogRecursionDepthKey] intValue];
  if (depth >= crLogRecursionDepthMax) {
    return;
  }
  threadDictionary[crLogRecursionDepthKey] = @(depth + 1);
  @try {
    [self.logHandler logMessage:message];
  } @catch (NSException *exception) {
    NSLog(@"Cannot log: %@, %@", exception, [exception userInfo]);
  } @finally {
    threadDictionary[crLogRecursionDepthKey] = @(depth);
  }
}

- (CR_ConsoleLogHandler *)consoleLogHandler {
  return self.logHandler.consoleLogHandler;
}

@end
