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
#import "CR_IntegrationRegistry.h"
#import "CR_DependencyProvider.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_ThreadManager.h"
#import "CR_SynchronousThreadManager.h"
#import "CR_AppEvents.h"
#import "CR_BidManager.h"
#import "CR_UserDataHolder.h"
#import "CRUserData+Internal.h"
#import "CR_CdbBidBuilder.h"
#import "CR_Logging.h"
#import "CRBannerAdUnit.h"
#import "XCTestCase+Criteo.h"
#import "CR_AdUnitHelper.h"
#import "CR_NetworkManagerMock.h"
#import "CR_ApiQueryKeys.h"

@interface CriteoTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_IntegrationRegistry *integrationRegistry;
@property(strong, nonatomic) CR_UserDataHolder *userDataHolder;
@property(strong, nonatomic) CR_NetworkManagerMock *networkManagerMock;
@property(strong, nonatomic) id loggingMock;
@end

@implementation CriteoTests

#pragma mark - Lifecycle

- (void)setUp {
  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;

  self.networkManagerMock = [CR_NetworkManagerMock new];
  dependencyProvider.networkManager = self.networkManagerMock;

  self.integrationRegistry = dependencyProvider.integrationRegistry;
  self.userDataHolder = dependencyProvider.userDataHolder;
  self.loggingMock = OCMPartialMock(CR_Logging.sharedInstance);

  self.criteo = OCMPartialMock([[Criteo alloc] initWithDependencyProvider:dependencyProvider]);
}

- (void)tearDown {
  [self.loggingMock stopMocking];
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
    OCMExpect([config isPrefetchOnInitEnabled]);
  }];
}

- (void)testRegister_GivenNilPublisherId_LogError {
  CR_DependencyProvider *dependencyProviderMock = OCMClassMock(CR_DependencyProvider.class);
  Criteo *criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProviderMock];
  NSString *nilPublisherId = nil;
  [criteo registerCriteoPublisherId:nilPublisherId withAdUnits:@[]];

  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return logMessage.severity == CR_LogSeverityError &&
                                       [logMessage.tag isEqualToString:@"Registration"] &&
                                       [logMessage.message containsString:@"Invalid"] &&
                                       [logMessage.message containsString:@"\"(null)\""];
                              }]]);
}

- (void)testRegister_GivenEmptyPublisherId_LogError {
  CR_DependencyProvider *dependencyProviderMock = OCMClassMock(CR_DependencyProvider.class);
  Criteo *criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProviderMock];
  NSString *emptyPublisherId = @"";
  [criteo registerCriteoPublisherId:emptyPublisherId withAdUnits:@[]];

  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return logMessage.severity == CR_LogSeverityError &&
                                       [logMessage.tag isEqualToString:@"Registration"] &&
                                       [logMessage.message containsString:@"Invalid"] &&
                                       [logMessage.message containsString:@"\"\""];
                              }]]);
}

- (void)testRegister_ShouldRefreshConfig {
  [self registerWithMockedDependencyProvider:^(CR_DependencyProvider *dependencyProviderMock) {
    CR_ConfigManager *configManager = OCMStrictClassMock(CR_ConfigManager.class);
    OCMStub(dependencyProviderMock.configManager).andReturn(configManager);
    OCMExpect([configManager refreshConfig:dependencyProviderMock.config]);
  }];
}

#pragma mark Prefetch

- (void)testRegister_GivenPrefetchEnabled_ShouldPrefetch {
  [self registerWithMockedDependencyProvider:^(CR_DependencyProvider *dependencyProviderMock) {
    CR_Config *config = OCMClassMock(CR_Config.class);
    OCMStub(config.isPrefetchOnInitEnabled).andReturn(YES);
    OCMStub(dependencyProviderMock.config).andReturn(config);

    CR_BidManager *bidManager = OCMStrictClassMock(CR_BidManager.class);
    OCMStub(dependencyProviderMock.bidManager).andReturn(bidManager);
    OCMExpect([bidManager prefetchBidsForAdUnits:OCMArg.any withContext:OCMArg.any]);
  }];
}

- (void)testRegister_GivenPrefetchDisabled_ShouldNotPrefetch {
  [self registerWithMockedDependencyProvider:^(CR_DependencyProvider *dependencyProviderMock) {
    CR_Config *config = OCMClassMock(CR_Config.class);
    OCMStub(config.isPrefetchOnInitEnabled).andReturn(NO);
    OCMStub(dependencyProviderMock.config).andReturn(config);

    CR_BidManager *bidManager = OCMStrictClassMock(CR_BidManager.class);
    OCMStub(dependencyProviderMock.bidManager).andReturn(bidManager);
    OCMReject([bidManager prefetchBidsForAdUnits:OCMArg.any withContext:OCMArg.any]);
  }];
}

- (void)testLoadBidForAdUnit_GivenNoBid_ReturnNil {
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"adUnit"
                                                               size:CGSizeMake(320, 50)];
  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  [self mockBidManagerWithAdUnit:cacheAdUnit respondBid:nil];

  XCTestExpectation *expectation = XCTestExpectation.new;
  [self.criteo loadBidForAdUnit:adUnit
                responseHandler:^(CRBid *bid) {
                  if (!bid) {
                    [expectation fulfill];
                  }
                }];
  [self cr_waitShortlyForExpectations:@[ expectation ]];

  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"Bidding"] &&
                                       [logMessage.message containsString:@"Loaded bid"] &&
                                       [logMessage.message containsString:@"(null)"];
                              }]]);
}

- (void)testLoadBidForAdUnit_GivenBid_ReturnBid {
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"adUnit"
                                                               size:CGSizeMake(320, 50)];
  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  CR_CdbBid *cdbBid = CR_CdbBidBuilder.new.adUnit(cacheAdUnit).cpm(@"42").build;
  [self mockBidManagerWithAdUnit:cacheAdUnit respondBid:cdbBid];

  XCTestExpectation *expectation = XCTestExpectation.new;
  __block CRBid *bid;
  [self.criteo loadBidForAdUnit:adUnit
                responseHandler:^(CRBid *bid_) {
                  bid = bid_;
                  if (bid.price == 42) {
                    [expectation fulfill];
                  }
                }];
  [self cr_waitShortlyForExpectations:@[ expectation ]];

  OCMVerify([self.loggingMock logMessage:[OCMArg checkWithBlock:^BOOL(CR_LogMessage *logMessage) {
                                return [logMessage.tag isEqualToString:@"Bidding"] &&
                                       [logMessage.message containsString:@"Loaded bid"] &&
                                       [logMessage.message containsString:bid.description];
                              }]]);
}

- (void)testLoadBidForAdUnit_GivenNoContext_UseEmptyOne {
  CRAdUnit *adUnit = OCMClassMock(CRAdUnit.class);
  id contextDataMock = OCMClassMock(CRContextData.class);
  OCMStub([contextDataMock new]).andReturn(contextDataMock);

  [self.criteo loadBidForAdUnit:adUnit
                responseHandler:^(CRBid *bid){
                }];

  OCMVerify([self.criteo loadBidForAdUnit:adUnit
                              withContext:contextDataMock
                          responseHandler:OCMArg.any]);
}

- (void)testChildDirectedTreatment {
  // case nil - undefined
  XCTAssertNil(self.criteo.childDirectedTreatment);
  XCTAssertNil([self.criteo bidManager].childDirectedTreatment);

  // case false
  self.criteo.childDirectedTreatment = @NO;
  XCTAssertFalse([[self.criteo bidManager].childDirectedTreatment boolValue]);

  // case true
  self.criteo.childDirectedTreatment = @YES;
  XCTAssertTrue([[self.criteo bidManager].childDirectedTreatment boolValue]);
}

- (void)testChildDirectedTreatmentNilCdbCall {
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"adUnit"
                                                               size:CGSizeMake(320, 50)];

  XCTAssertNil(self.criteo.childDirectedTreatment);
  XCTestExpectation *expectationNil =
      [self expectationWithDescription:
                [NSString stringWithFormat:@"CDB call should not have a %@ key in the body.",
                                           CR_ApiQueryKeys.regs]];
  [self.criteo loadBidForAdUnit:adUnit
                responseHandler:^(CRBid *_Nullable bid) {
                  XCTAssertFalse([self.networkManagerMock.lastPostBody.allKeys
                      containsObject:CR_ApiQueryKeys.regs]);
                  [expectationNil fulfill];
                }];

  [self cr_waitForExpectations:@[ expectationNil ]];
}

- (void)testChildDirectedTreatmentFalseCdbCall {
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"adUnit"
                                                               size:CGSizeMake(320, 50)];

  self.criteo.childDirectedTreatment = @NO;
  XCTestExpectation *expectationFalse =
      [self expectationWithDescription:
                [NSString stringWithFormat:@"CDB call should have a %@.%@ key in the body.",
                                           CR_ApiQueryKeys.regs, CR_ApiQueryKeys.coppa]];
  [self.criteo loadBidForAdUnit:adUnit
                responseHandler:^(CRBid *_Nullable bid) {
                  XCTAssertTrue([self.networkManagerMock.lastPostBody.allKeys
                      containsObject:CR_ApiQueryKeys.regs]);
                  NSDictionary *regsDictionary =
                      self.networkManagerMock.lastPostBody[CR_ApiQueryKeys.regs];
                  XCTAssertTrue([regsDictionary.allKeys containsObject:CR_ApiQueryKeys.coppa]);
                  NSNumber *childDirectedTreatmentFromBody = regsDictionary[CR_ApiQueryKeys.coppa];
                  XCTAssertEqual(childDirectedTreatmentFromBody, @NO);
                  [expectationFalse fulfill];
                }];

  [self cr_waitForExpectations:@[ expectationFalse ]];
}

- (void)testChildDirectedTreatmentTrueCdbCall {
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"adUnit"
                                                               size:CGSizeMake(320, 50)];

  self.criteo.childDirectedTreatment = @YES;
  XCTestExpectation *expectationTrue =
      [self expectationWithDescription:
                [NSString stringWithFormat:@"CDB call should have a %@.%@ key in the body.",
                                           CR_ApiQueryKeys.regs, CR_ApiQueryKeys.coppa]];
  [self.criteo loadBidForAdUnit:adUnit
                responseHandler:^(CRBid *_Nullable bid) {
                  XCTAssertTrue([self.networkManagerMock.lastPostBody.allKeys
                      containsObject:CR_ApiQueryKeys.regs]);
                  NSDictionary *regsDictionary =
                      self.networkManagerMock.lastPostBody[CR_ApiQueryKeys.regs];
                  XCTAssertTrue([regsDictionary.allKeys containsObject:CR_ApiQueryKeys.coppa]);
                  NSNumber *childDirectedTreatmentFromBody = regsDictionary[CR_ApiQueryKeys.coppa];
                  XCTAssertEqual(childDirectedTreatmentFromBody, @YES);
                  [expectationTrue fulfill];
                }];

  [self cr_waitForExpectations:@[ expectationTrue ]];
}

#pragma mark - User data

- (void)testSetUserData_GivenNoData_UserDataHolderContainsEmpty {
  // no setUserData

  NSDictionary<NSString *, id> *rawUserData = self.userDataHolder.userData.data;

  XCTAssertEqualObjects(rawUserData, @{});
}

- (void)testSetUserData_GivenSomeData_UserDataHolderContainsIt {
  [self.criteo setUserData:[CRUserData userDataWithDictionary:@{@"foo" : @"bar"}]];

  NSDictionary<NSString *, id> *rawUserData = self.userDataHolder.userData.data;

  XCTAssertEqualObjects(rawUserData, @{@"foo" : @"bar"});
}

#pragma mark - Private

- (void)eregisterWithMockedDependencyProvider:(void (^)(CR_DependencyProvider *))testBlock {
  CR_DependencyProvider *dependencyProviderMock = OCMClassMock(CR_DependencyProvider.class);
  CR_ThreadManager *threadManager = CR_SynchronousThreadManager.new;
  OCMStub(dependencyProviderMock.threadManager).andReturn(threadManager);
  testBlock(dependencyProviderMock);
  Criteo *criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProviderMock];
  [criteo registerCriteoPublisherId:@"testPublisherId" withAdUnits:@[]];
}

- (void)mockBidManagerWithAdUnit:(CR_CacheAdUnit *)adUnit respondBid:(CR_CdbBid *)bid {
  CR_BidManager *bidManager = OCMStrictClassMock(CR_BidManager.class);
  OCMStub(self.criteo.bidManager).andReturn(bidManager);
  OCMStub([bidManager loadCdbBidForAdUnit:adUnit
                              withContext:[OCMArg any]
                          responseHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        CR_CdbBidResponseHandler handler;
        [invocation getArgument:&handler atIndex:4];
        handler(bid);
      });
}

@end
