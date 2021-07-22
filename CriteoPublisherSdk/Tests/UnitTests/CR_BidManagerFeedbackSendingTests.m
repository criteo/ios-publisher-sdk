//
//  CR_BidManagerFeedbackSendingTests.m
//  CriteoPublisherSdkTests
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
#import "CR_BidManager+Testing.h"
#import "CR_DependencyProvider+Testing.h"
#import "CriteoPublisherSdkTests-Swift.h"

@interface CR_BidManagerFeedbackSendingTests : XCTestCase

@property(nonatomic, strong) CR_BidManager *bidManager;
@property(nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property(nonatomic, strong) CR_CASObjectQueue *feedbackSendingQueue;
@property(nonatomic, strong) CR_CacheAdUnit *adUnit;

@end

@implementation CR_BidManagerFeedbackSendingTests

#pragma mark - Lifecycle

- (void)setUp {
  self.adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"id" width:300 height:200];
  self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);
  self.feedbackSendingQueue = [[CR_CASInMemoryObjectQueue alloc] init];
  CR_FeedbackFileManagingMock *fileManagingMock = [[CR_FeedbackFileManagingMock alloc] init];
  CR_FeedbackStorage *feedbackStorage =
      [[CR_FeedbackStorage alloc] initWithFileManager:fileManagingMock
                                            withQueue:self.feedbackSendingQueue];

  CR_DependencyProvider *dependencyProvider = [CR_DependencyProvider testing_dependencyProvider];
  dependencyProvider.apiHandler = self.apiHandlerMock;
  dependencyProvider.feedbackStorage = feedbackStorage;
  self.bidManager = [dependencyProvider bidManager];
}

#pragma mark - Tests

- (void)testEmptySendingQueue_ShouldNotCallSendMethod {
  OCMReject([self.apiHandlerMock sendFeedbackMessages:[OCMArg any]
                                               config:[OCMArg any]
                                            profileId:[OCMArg any]
                                    completionHandler:[OCMArg any]]);

  XCTAssertEqual(self.feedbackSendingQueue.size, 0);
  [self fetchBidForAdUnit:self.adUnit];
}

- (void)testNonEmptySendingQueue_ShouldSendAllMessages {
  XCTAssertEqual(self.feedbackSendingQueue.size, 0);
  CR_FeedbackMessage *message1 = [[CR_FeedbackMessage alloc] init];
  CR_FeedbackMessage *message2 = [[CR_FeedbackMessage alloc] init];
  NSError *error;
  [self.feedbackSendingQueue add:message1 error:&error];
  [self.feedbackSendingQueue add:message2 error:&error];
  [self fetchBidForAdUnit:self.adUnit];

  NSArray *messages = @[ message1, message2 ];
  OCMVerify([self.apiHandlerMock sendFeedbackMessages:messages
                                               config:[OCMArg any]
                                            profileId:[OCMArg any]
                                    completionHandler:[OCMArg any]]);
}

- (void)testMultipleProfileIds_ShouldBeSentSeparatelyGrouped {
  XCTAssertEqual(self.feedbackSendingQueue.size, 0);
  CR_FeedbackMessage *message1 = [[CR_FeedbackMessage alloc] init];
  message1.profileId = @(1);
  CR_FeedbackMessage *message21 = [[CR_FeedbackMessage alloc] init];
  message21.profileId = @(2);
  CR_FeedbackMessage *message22 = [[CR_FeedbackMessage alloc] init];
  message22.profileId = @(2);
  NSError *error;
  [self.feedbackSendingQueue add:message1 error:&error];
  [self.feedbackSendingQueue add:message21 error:&error];
  [self.feedbackSendingQueue add:message22 error:&error];

  NSArray *messages1 = @[ message1 ];
  OCMExpect([self.apiHandlerMock sendFeedbackMessages:messages1
                                               config:[OCMArg any]
                                            profileId:@1
                                    completionHandler:[OCMArg any]]);
  NSArray *messages2 = @[ message21, message22 ];
  OCMExpect([self.apiHandlerMock sendFeedbackMessages:messages2
                                               config:[OCMArg any]
                                            profileId:@2
                                    completionHandler:[OCMArg any]]);
  [self fetchBidForAdUnit:self.adUnit];
  OCMVerifyAll(self.apiHandlerMock);
}

- (void)testSuccessfulSending_ShouldClearSendingQueue {
  OCMStub([self.apiHandlerMock sendFeedbackMessages:[OCMArg any]
                                             config:[OCMArg any]
                                          profileId:[OCMArg any]
                                  completionHandler:[OCMArg invokeBlock]]);
  XCTAssertEqual(self.feedbackSendingQueue.size, 0);
  NSError *error;
  [self.feedbackSendingQueue add:[[CR_FeedbackMessage alloc] init] error:&error];
  [self fetchBidForAdUnit:self.adUnit];

  XCTAssertEqual(self.feedbackSendingQueue.size, 0);
}

- (void)testSendingFailed_ShouldClearSendingQueue {
  NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
  id completeionWithError = [OCMArg invokeBlockWithArgs:error, nil];
  OCMStub([self.apiHandlerMock sendFeedbackMessages:[OCMArg any]
                                             config:[OCMArg any]
                                          profileId:[OCMArg any]
                                  completionHandler:completeionWithError]);
  XCTAssertEqual(self.feedbackSendingQueue.size, 0);
  NSError *addError;
  [self.feedbackSendingQueue add:[[CR_FeedbackMessage alloc] init] error:&addError];
  [self fetchBidForAdUnit:self.adUnit];

  XCTAssertEqual(self.feedbackSendingQueue.size, 1);
}

#pragma mark - Private

- (void)fetchBidsForAdUnits:(CR_CacheAdUnitArray *)adUnits {
  [self.bidManager fetchBidsForAdUnits:adUnits
                           withContext:CRContextData.new
                    cdbResponseHandler:^(CR_CdbResponse *response){
                    }];
}

- (void)fetchBidForAdUnit:(CR_CacheAdUnit *)adUnit {
  [self fetchBidsForAdUnits:@[ adUnit ]];
}

@end
