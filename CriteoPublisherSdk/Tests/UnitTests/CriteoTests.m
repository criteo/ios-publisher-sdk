//
//  CriteoTests.m
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
#import <OCMock.h>
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRInterstitialAdUnit.h"
#import "CR_IntegrationRegistry.h"
#import "CR_DependencyProvider.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_ThreadManager.h"
#import "CR_SynchronousThreadManager.h"
#import "CR_AppEvents.h"
#import "CR_BidManager.h"

@interface CriteoTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CriteoTests

#pragma mark - Lifecycle

- (void)setUp {
  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
  self.integrationRegistry = dependencyProvider.integrationRegistry;

  self.criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProvider];
}

#pragma mark - Tests

- (void)testRegister_ShouldRegisterAndSendAppEvents {
  [self registerWithMockedDependencyProvider:^(CR_DependencyProvider *dependencyProviderMock) {
    CR_AppEvents *appEvents = OCMStrictClassMock(CR_AppEvents.class);
    OCMStub(dependencyProviderMock.appEvents).andReturn(appEvents);
    OCMExpect([appEvents registerForIosEvents]);
    OCMExpect([appEvents sendLaunchEvent]);
  }];
}

- (void)testRegister_ShouldSetPublisherId {
  [self registerWithMockedDependencyProvider:^(CR_DependencyProvider *dependencyProviderMock) {
    CR_Config *config = OCMStrictClassMock(CR_Config.class);
    OCMStub(dependencyProviderMock.config).andReturn(config);
    OCMExpect([config setCriteoPublisherId:@"testPublisherId"];);
    OCMExpect([config isLiveBiddingEnabled]);
  }];
}

- (void)testRegister_ShouldRefreshConfig {
  [self registerWithMockedDependencyProvider:^(CR_DependencyProvider *dependencyProviderMock) {
    CR_ConfigManager *configManager = OCMStrictClassMock(CR_ConfigManager.class);
    OCMStub(dependencyProviderMock.configManager).andReturn(configManager);
    OCMExpect([configManager refreshConfig:dependencyProviderMock.config]);
  }];
}

- (void)testRegister_ShouldPrefetch {
  [self registerWithMockedDependencyProvider:^(CR_DependencyProvider *dependencyProviderMock) {
    CR_BidManager *bidManager = OCMStrictClassMock(CR_BidManager.class);
    OCMStub(dependencyProviderMock.bidManager).andReturn(bidManager);
    OCMExpect([bidManager prefetchBidsForAdUnits:OCMArg.any]);
  }];
}

#pragma mark - Private

- (void)registerWithMockedDependencyProvider:(void (^)(CR_DependencyProvider *))testBlock {
  CR_DependencyProvider *dependencyProviderMock = OCMClassMock(CR_DependencyProvider.class);
  CR_ThreadManager *threadManager = CR_SynchronousThreadManager.new;
  OCMStub(dependencyProviderMock.threadManager).andReturn(threadManager);
  testBlock(dependencyProviderMock);
  Criteo *criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProviderMock];
  [criteo registerCriteoPublisherId:@"testPublisherId" withAdUnits:@[]];
}

@end
