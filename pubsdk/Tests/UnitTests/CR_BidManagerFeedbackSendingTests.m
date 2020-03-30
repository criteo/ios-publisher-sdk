//
//  CR_BidManagerFeedbackSendingTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 28/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CR_BidManager.h"
#import "CR_BidManagerBuilder.h"
#import "pubsdkTests-Swift.h"

@interface CR_BidManagerFeedbackSendingTests : XCTestCase

@property (nonatomic, strong) CR_BidManager *bidManager;
@property (nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property (nonatomic, strong) CASObjectQueue *feedbackSendingQueue;
@property (nonatomic, strong) CR_CacheAdUnit *adUnit;

@end

@implementation CR_BidManagerFeedbackSendingTests

- (void)setUp {
    self.adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"id" width:300 height:200];
    self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);
    self.feedbackSendingQueue = [[CASInMemoryObjectQueue alloc] init];
    CR_FeedbackFileManagingMock *fileManagingMock = [[CR_FeedbackFileManagingMock alloc] init];
    CR_FeedbackStorage *feedbackStorage = [[CR_FeedbackStorage alloc] initWithFileManager:fileManagingMock
                                                                                withQueue:self.feedbackSendingQueue];

    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    builder.apiHandler = self.apiHandlerMock;
    builder.feedbackStorage = feedbackStorage;
    self.bidManager = [builder buildBidManager];
}

- (void)testEmptySendingQueue_ShouldNotCallSendMethod {
    OCMReject([self.apiHandlerMock sendFeedbackMessages:[OCMArg any]
                                                 config:[OCMArg any]
                                      completionHandler:[OCMArg any]]);

    XCTAssertEqual(self.feedbackSendingQueue.size, 0);
    [self.bidManager prefetchBid:self.adUnit];
}

- (void)testNonEmptySendingQueue_ShouldSendAllMessages {
    XCTAssertEqual(self.feedbackSendingQueue.size, 0);
    CR_FeedbackMessage *message1 = [[CR_FeedbackMessage alloc] init];
    CR_FeedbackMessage *message2 = [[CR_FeedbackMessage alloc] init];
    [self.feedbackSendingQueue add:message1];
    [self.feedbackSendingQueue add:message2];
    [self.bidManager prefetchBid:self.adUnit];

    NSArray *messages = @[message1, message2];
    OCMVerify([self.apiHandlerMock sendFeedbackMessages:messages
                                                 config:[OCMArg any]
                                      completionHandler:[OCMArg any]]);
}

- (void)testSuccessfulSending_ShouldClearSendingQueue {
    OCMStub([self.apiHandlerMock sendFeedbackMessages:[OCMArg any]
                                               config:[OCMArg any]
                                    completionHandler:[OCMArg invokeBlock]]);
    XCTAssertEqual(self.feedbackSendingQueue.size, 0);
    [self.feedbackSendingQueue add:[[CR_FeedbackMessage alloc] init]];
    [self.bidManager prefetchBid:self.adUnit];

    XCTAssertEqual(self.feedbackSendingQueue.size, 0);
}

- (void)testSendingFailed_ShouldClearSendingQueue {
    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
    id completeionWithError = [OCMArg invokeBlockWithArgs:error, nil];
    OCMStub([self.apiHandlerMock sendFeedbackMessages:[OCMArg any]
                                               config:[OCMArg any]
                                    completionHandler:completeionWithError]);
    XCTAssertEqual(self.feedbackSendingQueue.size, 0);
    [self.feedbackSendingQueue add:[[CR_FeedbackMessage alloc] init]];
    [self.bidManager prefetchBid:self.adUnit];

    XCTAssertEqual(self.feedbackSendingQueue.size, 1);
}

@end
