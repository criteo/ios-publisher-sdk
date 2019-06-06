//
//  CRBidTokenTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 6/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRBidToken+Internal.h"

@interface CRBidTokenTests : XCTestCase

@end

@implementation CRBidTokenTests

- (void)testSameBidTokens {
    NSUUID *uuid = [NSUUID UUID];
    CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
    CRBidToken *secondToken = [[CRBidToken alloc] initWithUUID:uuid];
    XCTAssertTrue([firstToken isEqual:secondToken]);
}

- (void)testDifferentBidTokens {
    NSUUID *uuid = [NSUUID UUID];
    NSUUID *otherUuid = [NSUUID UUID];
    CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
    CRBidToken *secondToken = [[CRBidToken alloc] initWithUUID:otherUuid];
    XCTAssertFalse([firstToken isEqual:secondToken]);
}

- (void)testNullBidToken {
    NSUUID *uuid = [NSUUID UUID];
    CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
    CRBidToken *randomToken = [[CRBidToken alloc] initWithUUID:NULL];
    XCTAssertFalse([firstToken isEqual:randomToken]);
}

- (void)testNonBidTokenObject {
    NSUUID *uuid = [NSUUID UUID];
    CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
    NSUUID *randomObject = [NSUUID UUID];
    XCTAssertFalse([firstToken isEqual:randomObject]);
}

- (void)testSameHash {
    NSUUID *uuid = [NSUUID UUID];
    CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
    CRBidToken *secondToken = [[CRBidToken alloc] initWithUUID:uuid];
    XCTAssertEqual([firstToken hash], [secondToken hash]);
}

- (void)testDifferentHash {
    NSUUID *uuid = [NSUUID UUID];
    NSUUID *otherUuid = [NSUUID UUID];
    CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
    CRBidToken *secondToken = [[CRBidToken alloc] initWithUUID:otherUuid];
    XCTAssertNotEqual([firstToken hash], [secondToken hash]);
}

- (void) testCopyBidToken {
    NSUUID *uuid = [NSUUID UUID];
    CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
    CRBidToken *secondToken = [firstToken copy];
    XCTAssertTrue([firstToken isEqual:secondToken]);
    XCTAssertEqual([firstToken hash], [secondToken hash]);
}

@end
