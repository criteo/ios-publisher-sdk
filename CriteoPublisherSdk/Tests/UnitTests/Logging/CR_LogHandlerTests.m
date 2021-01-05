//
//  CR_LogHandlerTests.m
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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "CR_LogHandler.h"

@interface CR_LogHandlerTests : XCTestCase
@property(nonatomic, strong) id<CR_LogHandler> handler1;
@property(nonatomic, strong) id<CR_LogHandler> handler2;
@property(nonatomic, strong) CR_ConsoleLogHandler *consoleHandler;
@property(nonatomic, strong) CR_MultiplexLogHandler *multiplexHandler;
@property(nonatomic, strong) CR_LogMessage *debugMessage;
@property(nonatomic, strong) CR_LogMessage *infoMessage;
@property(nonatomic, strong) CR_LogMessage *warnMessage;
@property(nonatomic, strong) CR_LogMessage *errorMessage;
@end

@implementation CR_LogHandlerTests

- (void)setUp {
  self.handler1 = OCMProtocolMock(@protocol(CR_LogHandler));
  self.handler2 = OCMProtocolMock(@protocol(CR_LogHandler));
  NSArray *handlers = @[ self.handler1, self.handler2 ];
  self.consoleHandler = OCMPartialMock([[CR_ConsoleLogHandler alloc] init]);
  self.multiplexHandler = [[CR_MultiplexLogHandler alloc] initWithLogHandlers:handlers];
  self.debugMessage = [self messageWithSeverity:CR_LogSeverityDebug];
  self.infoMessage = [self messageWithSeverity:CR_LogSeverityInfo];
  self.warnMessage = [self messageWithSeverity:CR_LogSeverityWarning];
  self.errorMessage = [self messageWithSeverity:CR_LogSeverityError];
}

#pragma mark - Console

- (void)testConsole_GivenDefaultWarningSeverityThreshold_ThenLogWarningAndOver {
  [self.consoleHandler logMessage:self.infoMessage];
  [self.consoleHandler logMessage:self.warnMessage];
  [self.consoleHandler logMessage:self.errorMessage];

  OCMVerify(never(), [self.consoleHandler logMessageToConsole:self.infoMessage]);
  OCMVerify(times(1), [self.consoleHandler logMessageToConsole:self.warnMessage]);
  OCMVerify(times(1), [self.consoleHandler logMessageToConsole:self.errorMessage]);
}

- (void)testConsole_GivenInfoSeverityThreshold_ThenLogInfoAndOver {
  self.consoleHandler.severityThreshold = CR_LogSeverityInfo;

  [self.consoleHandler logMessage:self.debugMessage];
  [self.consoleHandler logMessage:self.infoMessage];
  [self.consoleHandler logMessage:self.errorMessage];

  OCMVerify(never(), [self.consoleHandler logMessageToConsole:self.debugMessage]);
  OCMVerify(times(1), [self.consoleHandler logMessageToConsole:self.infoMessage]);
  OCMVerify(times(1), [self.consoleHandler logMessageToConsole:self.errorMessage]);
}

- (void)testConsole_GivenWarningSeverity_ThenNoLogInfo {
  self.consoleHandler.severityThreshold = CR_LogSeverityWarning;
  [self.consoleHandler logMessage:self.infoMessage];

  OCMVerify(never(), [self.consoleHandler logMessageToConsole:self.infoMessage]);
}

#pragma mark - Multiplex

- (void)testMultiplex_GivenHandlers_InvokeThem {
  [self.multiplexHandler logMessage:self.infoMessage];

  OCMVerify([self.handler1 logMessage:self.infoMessage]);
  OCMVerify([self.handler2 logMessage:self.infoMessage]);
}

- (void)testMultiplex_GivenConsoleHandler_ReturnConsoleHandler {
  self.consoleHandler = [[CR_ConsoleLogHandler alloc] init];
  NSArray *handlers = @[ self.handler1, self.consoleHandler, self.handler2 ];
  self.multiplexHandler = [[CR_MultiplexLogHandler alloc] initWithLogHandlers:handlers];

  XCTAssertEqualObjects(self.multiplexHandler.consoleLogHandler, self.consoleHandler);
}

#pragma mark - Private

- (CR_LogMessage *)messageWithSeverity:(CR_LogSeverity)severity {
  return CRLogMessage(@"tag", severity, nil, @"Hello");
}

@end
