//
//  CRBidResponseTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRBidResponse+Internal.h"
#import "CRBidToken+Internal.h"

@interface CRBidResponseTests : XCTestCase

@end

@implementation CRBidResponseTests

- (void)testBidResponseInitialization {
  CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CRBidResponse *testBidResponse = [[CRBidResponse alloc] initWithPrice:5.5
                                                             bidSuccess:YES
                                                               bidToken:bidToken];
  XCTAssertEqual(5.5, testBidResponse.price);
  XCTAssertEqual(YES, testBidResponse.bidSuccess);
  XCTAssertEqual(bidToken, testBidResponse.bidToken);
}

@end
