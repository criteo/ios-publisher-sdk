//
//  CR_TokenValueTests.m
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
#import "CR_TokenValue.h"
#import "CR_CdbBid.h"
#import "OCMock.h"

@interface CR_TokenValueTests : XCTestCase

@end

@implementation CR_TokenValueTests

- (void)testTokenValueExpired {
  CR_CdbBid *cdbBid = OCMClassMock([CR_CdbBid class]);
  OCMStub(cdbBid.isExpired).andReturn(YES);

  CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];

  CR_TokenValue *tokenValue = [[CR_TokenValue alloc] initWithCdbBid:cdbBid adUnit:adUnit];

  XCTAssertTrue([tokenValue isExpired]);
}

- (void)testTokenValueNotExpired {
  CR_CdbBid *cdbBid = OCMClassMock([CR_CdbBid class]);
  OCMStub(cdbBid.isExpired).andReturn(NO);

  CRAdUnit *adUnit = [[CRAdUnit alloc] initWithAdUnitId:@"Helios" adUnitType:CRAdUnitTypeBanner];

  CR_TokenValue *tokenValue = [[CR_TokenValue alloc] initWithCdbBid:cdbBid adUnit:adUnit];

  XCTAssertFalse([tokenValue isExpired]);
}

@end
