//
//  CR_LoggingTests.m
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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CR_Logging.h"
#import "CR_DependencyProvider+Testing.h"
#import "Criteo+Internal.h"
#import "CR_RemoteLogHandler.h"

@interface CR_LoggingTests : XCTestCase
@property(nonatomic, strong) CR_DependencyProvider *dependencyProvider;
@end

@implementation CR_LoggingTests

- (void)setUp {
  [super setUp];

  self.dependencyProvider = OCMPartialMock(CR_DependencyProvider.testing_dependencyProvider);
  OCMStub([(id)self.dependencyProvider new]).andReturn(self.dependencyProvider);
}

- (void)tearDown {
  [(id)self.dependencyProvider stopMocking];
  [super tearDown];
}

- (void)testLoggingWithSdkNotInitialized {
  CR_ConsoleLogHandler *consoleLogHandler = OCMClassMock(CR_ConsoleLogHandler.class);
  self.dependencyProvider.consoleLogHandler = consoleLogHandler;

  CR_RemoteLogHandler *remoteLogHandler = OCMClassMock(CR_RemoteLogHandler.class);
  self.dependencyProvider.remoteLogHandler = remoteLogHandler;

  [Criteo resetSharedCriteo];

  CRLogInfo(@"tag", @"message");

  OCMVerify(times(1), [consoleLogHandler logMessage:[self checkLogWithMessage:@"message"]]);
  OCMVerify(times(1),
            [consoleLogHandler logMessage:[self checkLogWithMessage:@"Singleton was initialized"]]);

  OCMVerify(times(1), [remoteLogHandler logMessage:[self checkLogWithMessage:@"message"]]);
  OCMVerify(times(1),
            [remoteLogHandler logMessage:[self checkLogWithMessage:@"Singleton was initialized"]]);
}

- (void)testLoggingWithSdkInitialized {
  CR_ConsoleLogHandler *consoleLogHandler = OCMClassMock(CR_ConsoleLogHandler.class);
  self.dependencyProvider.consoleLogHandler = consoleLogHandler;

  CR_RemoteLogHandler *remoteLogHandler = OCMClassMock(CR_RemoteLogHandler.class);
  self.dependencyProvider.remoteLogHandler = remoteLogHandler;

  OCMExpect([consoleLogHandler logMessage:[self checkLogWithMessage:@"Singleton was initialized"]]);
  OCMExpect([remoteLogHandler logMessage:[self checkLogWithMessage:@"Singleton was initialized"]]);

  [Criteo sharedCriteo];

  OCMVerifyAll(consoleLogHandler);
  OCMVerifyAll(remoteLogHandler);

  OCMReject([consoleLogHandler logMessage:[self checkLogWithMessage:@"Singleton was initialized"]]);
  OCMExpect([consoleLogHandler logMessage:[self checkLogWithMessage:@"message"]]);

  OCMReject([remoteLogHandler logMessage:[self checkLogWithMessage:@"Singleton was initialized"]]);
  OCMExpect([remoteLogHandler logMessage:[self checkLogWithMessage:@"message"]]);

  CRLogInfo(@"tag", @"message");

  OCMVerifyAll(consoleLogHandler);
  OCMVerifyAll(remoteLogHandler);
}

- (id)checkLogWithMessage:(NSString *)message {
  return [OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
    return [logMessage.message isEqualToString:message];
  }];
}

@end