//
//  CRGoogleMediationParametersTests.m
//  CriteoGoogleAdapterTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
//  in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the License for the specific language governing permissions and
//  limitations under the License.

#import <XCTest/XCTest.h>
#import "CRGoogleMediationParameters.h"
@import GoogleMobileAds;

@interface CRGoogleMediationParametersTests : XCTestCase

@end

@implementation CRGoogleMediationParametersTests

// Normal case
- (void)testGoogleMediationParametersNormal {
  NSError *error;
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:
          @"{\"cpId\":\"B-056946\", \"adUnitId\": \"/140800857/Endeavour_320x50\"}"
                         error:&error];
  XCTAssertNotNil(gmp);
  XCTAssertEqualObjects(gmp.publisherId, @"B-056946");
  XCTAssertEqualObjects(gmp.adUnitId, @"/140800857/Endeavour_320x50");
}

// Normal case - check that the error is set to nil
- (void)testGoogleMediationParametersErrorSetToNil {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:
          @"{\"cpId\":\"B-056946\", \"adUnitId\": \"/140800857/Endeavour_320x50\"}"
                         error:&error];
  XCTAssertNil(error);
}

// Normal case with nil error
- (void)testGoogleMediationParametersNilError {
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:
          @"{\"cpId\":\"B-056946\", \"adUnitId\": \"/140800857/Endeavour_320x50\"}"
                         error:nil];
  XCTAssertNotNil(gmp);
  XCTAssertEqualObjects(gmp.publisherId, @"B-056946");
  XCTAssertEqualObjects(gmp.adUnitId, @"/140800857/Endeavour_320x50");
}

// Nil input string
- (void)testGoogleMediationParametersErrorNilInputString {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters parametersFromJSONString:nil
                                                                                     error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

// Blank cpid
- (void)testGoogleMediationParametersBlankCpid {
  NSError *error;
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:@"{\"cpId\":\"\", \"adUnitId\": \"/140800857/Endeavour_320x50\"}"
                         error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

// Nil cpid
- (void)testGoogleMediationParametersNilCpid {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:
          @"{\"cpidx\":\"B-056946\", \"adUnitId\": \"/140800857/Endeavour_320x50\"}"
                         error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

// Non-string cpId
- (void)testGoogleMediationParametersNonStringCpid {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:@"{\"cpId\":1, \"adUnitID\": \"/140800857/Endeavour_320x50\"}"
                         error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

// Blank ad unit id
- (void)testGoogleMediationParametersBlankAdUnitId {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:@"{\"cpId\":\"B-056946\", \"adUnitId\": \"\"}"
                         error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

// Nil ad unit id
- (void)testGoogleMediationParametersNilAdUnitId {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:
          @"{\"cpId\":\"B-056946\", \"adUnitIDx\": \"/140800857/Endeavour_320x50\"}"
                         error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

// Non-string ad unit id
- (void)testGoogleMediationParametersNonStringAdUnitId {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:@"{\"cpId\":\"B-056946\", \"adUnitID\": 2}"
                         error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

// Pass nil as an error on failure case
- (void)testGoogleMediationParametersFailureWithNilErrorPtr {
  CRGoogleMediationParameters *gmp = [CRGoogleMediationParameters
      parametersFromJSONString:
          @"{\"cpId\":\"B-056946\", \"adUnitIDx\": \"/140800857/Endeavour_320x50\"}"
                         error:nil];
  XCTAssertNil(gmp);
}

// Completely farkakte JSON
- (void)testGoogleMediationParametersTotallyBadJson {
  NSError *error = [NSError new];
  CRGoogleMediationParameters *gmp =
      [CRGoogleMediationParameters parametersFromJSONString:@"ASFQ$RT @#VSDVC " error:&error];
  XCTAssertNil(gmp);
  XCTAssertEqual(error.code, kGADErrorInvalidArgument);
}

@end
