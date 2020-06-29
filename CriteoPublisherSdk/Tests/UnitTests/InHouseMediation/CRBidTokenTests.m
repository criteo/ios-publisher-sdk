//
//  CRBidTokenTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
  XCTAssertEqualObjects(firstToken, secondToken);
  XCTAssertEqual(firstToken.bidTokenUUID, secondToken.bidTokenUUID);
}

- (void)testDifferentBidTokens {
  NSUUID *uuid = [NSUUID UUID];
  NSUUID *otherUuid = [NSUUID UUID];
  CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
  CRBidToken *secondToken = [[CRBidToken alloc] initWithUUID:otherUuid];
  XCTAssertNotEqualObjects(firstToken, secondToken);
  XCTAssertNotEqual(firstToken.bidTokenUUID, secondToken.bidTokenUUID);
}

- (void)testNilBidToken {
  NSUUID *uuid = [NSUUID UUID];
  CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
  CRBidToken *randomToken = [[CRBidToken alloc] initWithUUID:nil];
  XCTAssertNotEqualObjects(firstToken, randomToken);
  XCTAssertNotNil(randomToken.bidTokenUUID);
  XCTAssertNotEqual(firstToken.bidTokenUUID, randomToken.bidTokenUUID);
}

- (void)testNonBidTokenObject {
  NSUUID *uuid = [NSUUID UUID];
  CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
  NSUUID *randomObject = [NSUUID UUID];
  XCTAssertNotEqualObjects(firstToken, randomObject);
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

- (void)testCopyBidToken {
  NSUUID *uuid = [NSUUID UUID];
  CRBidToken *firstToken = [[CRBidToken alloc] initWithUUID:uuid];
  CRBidToken *secondToken = [firstToken copy];
  XCTAssertEqualObjects(firstToken, secondToken);
  XCTAssertEqual([firstToken hash], [secondToken hash]);
}

@end
