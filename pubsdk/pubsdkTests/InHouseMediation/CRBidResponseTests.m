//
//  CRBidResponseTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 6/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRBidResponse+Internal.h"
#import "CRBidToken+Internal.h"

@interface CRBidResponseTests : XCTestCase

@end

@implementation CRBidResponseTests

- (void)testBidResponseInitialization {
    CRBidToken *bidToken = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
    CRBidResponse *testBidResponse = [[CRBidResponse alloc] initWithPrice:5.5 bidSuccess:YES bidToken:bidToken];
    XCTAssertEqual(testBidResponse.price, 5.5);
    XCTAssertEqual(testBidResponse.bidSuccess, YES);
    XCTAssertEqual(testBidResponse.bidToken, bidToken);
}

@end
