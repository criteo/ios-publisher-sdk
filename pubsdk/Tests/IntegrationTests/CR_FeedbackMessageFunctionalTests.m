//
//  CR_FeedbackMessageFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 4/8/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "NSURL+Testing.h"
#import "XCTestCase+Criteo.h"

@interface CR_FeedbackMessageFunctionalTests : XCTestCase

@property (strong, nonatomic) Criteo *criteo;

@end

@implementation CR_FeedbackMessageFunctionalTests

- (void)setUp {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
}

- (void)testGivenPrefetchedBids_whenBidConsumed_thenFeedbackMessageSent {
    CRBannerAdUnit *adUnitForConsumation = [CR_TestAdUnits preprodBanner320x50];
    NSArray *adUnits = @[adUnitForConsumation, [CR_TestAdUnits preprodInterstitial]];
    [self.criteo testing_registerWithAdUnits:adUnits];
    [self.criteo testing_waitForRegisterHTTPResponses];
    [self.criteo.testing_networkCaptor clear];

    [self.criteo getBidResponseForAdUnit:adUnitForConsumation];

    [self waitFeedbackMessageRequest];
    CR_HttpContent *content = [self feedbackMessageRequest];
    XCTAssertNotNil(content);
    XCTAssertEqual([content.requestBody[@"feedbacks"] count], 1);
    NSDictionary *feedback = content.requestBody[@"feedbacks"][0];
    XCTAssertEqualObjects(feedback[@"cdbCallStartElapsed"], @0);
    XCTAssertNotNil(feedback[@"cdbCallEndElapsed"]);
    XCTAssertNotNil(feedback[@"elapsed"]);
    XCTAssertEqual([feedback[@"slots"] count], 1);
    XCTAssertEqualObjects(feedback[@"slots"][0][@"cachedBidUsed"], @1);
    XCTAssertNotNil(feedback[@"slots"][0][@"impressionId"]);
}

#pragma mark - Private

- (void)waitFeedbackMessageRequest {
    CR_NetworkWaiterBuilder *builder = [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.criteo.config
                                                                         networkCaptor:self.criteo.testing_networkCaptor];
    CR_NetworkWaiter *waiter = builder.withFeedbackMessageSent.withFinishedRequestsIncluded.build;
    const BOOL result = [waiter wait];
    XCTAssert(result);
}

- (CR_HttpContent *)feedbackMessageRequest {
    NSArray<CR_HttpContent *> *requests = self.criteo.testing_networkCaptor.allRequests;
    NSUInteger index = [requests indexOfObjectPassingTest:^BOOL(CR_HttpContent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.url testing_isFeedbackMessageUrlWithConfig:self.criteo.config];
    }];
    CR_HttpContent *feedbackRequest = requests[index];
    return feedbackRequest;
}

@end
