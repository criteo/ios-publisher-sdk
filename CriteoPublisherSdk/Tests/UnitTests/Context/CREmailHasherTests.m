//
//  CREmailHasherTests.m
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
#import "CREmailHasher.h"

@interface CREmailHasherTests : XCTestCase
@end

@implementation CREmailHasherTests

- (void)testHash_GivenExampleWithSpaceAndCaps_ReturnsSameThanWhenTrimmedAndLowered {
  NSString *expected = @"000e3171a5110c35c69d060112bd0ba55d9631c7c2ec93f1840e4570095b263a";

  NSString *hash1 = [CREmailHasher hash:@"john.doe@gmail.com"];
  NSString *hash2 = [CREmailHasher hash:@" john.doe@gmail.com "];
  NSString *hash3 = [CREmailHasher hash:@"John.Doe@gmail.com"];
  NSString *hash4 = [CREmailHasher hash:@" John.Doe@gmail.com "];

  XCTAssertEqualObjects(hash1, expected);
  XCTAssertEqualObjects(hash2, expected);
  XCTAssertEqualObjects(hash3, expected);
  XCTAssertEqualObjects(hash4, expected);
}

- (void)testHash_GivenGermanEmailAddresses_ReturnsSameThanWhenTrimmedAndLowered {
  NSString *hash1 = [CREmailHasher hash:@"Dörte@Sörensen.example.com"];
  NSString *hash2 = [CREmailHasher hash:@" dörte@sÖrensen.example.com "];

  XCTAssertEqualObjects(hash1, hash2);
}

- (void)testHash_GivenRussianEmailAddresses_ReturnsSameThanWhenTrimmedAndLowered {
  NSString *hash1 = [CREmailHasher hash:@"коля@пример.рф"];
  NSString *hash2 = [CREmailHasher hash:@" КОЛЯ@ПРИМЕР.РФ "];

  XCTAssertEqualObjects(hash1, hash2);
}

- (void)testHash_GivenGreekEmailAddresses_ReturnsSameThanWhenTrimmedAndLowered {
  NSString *hash1 = [CREmailHasher hash:@"χρήστης@παράδειγμα.ελ"];
  NSString *hash2 = [CREmailHasher hash:@" ΧΡήστΗς@πΑράδειγμΑ.ελ "];

  XCTAssertEqualObjects(hash1, hash2);
}

@end