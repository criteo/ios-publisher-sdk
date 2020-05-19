//
//  NSError+Criteo.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSError+Criteo.h"

@interface NSError_CriteoTests : XCTestCase

@end

@implementation NSError_CriteoTests

- (NSError *)expectedErrorWithCode:(CRErrorCode)errorCode description:(NSString *)description {
    return [NSError errorWithDomain:@"com.criteo.pubsdk" code:errorCode
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

- (void)testErrorCodesWithDefaultDescription {
    NSError *internalError = [self expectedErrorWithCode:CRErrorCodeInternalError
                                             description:@"Ad request failed due to an internal error."];
    XCTAssertEqualObjects(internalError, [NSError cr_errorWithCode:CRErrorCodeInternalError]);

    NSError *noFillError = [self expectedErrorWithCode:CRErrorCodeNoFill
                                           description:@"Ad request succeeded but no ads are available."];
    XCTAssertEqualObjects(noFillError, [NSError cr_errorWithCode:CRErrorCodeNoFill]);

    NSError *invalidRequestError = [self expectedErrorWithCode:CRErrorCodeInvalidRequest
                                                   description:@"Invalid ad request."];
    XCTAssertEqualObjects(invalidRequestError, [NSError cr_errorWithCode:CRErrorCodeInvalidRequest]);

    NSError *networkError = [self expectedErrorWithCode:CRErrorCodeNetworkError
                                            description:@"Ad request failed due to network error."];
    XCTAssertEqualObjects(networkError, [NSError cr_errorWithCode:CRErrorCodeNetworkError]);

    NSError *invalidParameterError = [self expectedErrorWithCode:CRErrorCodeInvalidParameter
                                                     description:@"Invalid ad request parameter."];
    XCTAssertEqualObjects(invalidParameterError, [NSError cr_errorWithCode:CRErrorCodeInvalidParameter]);

    NSError *invalidErrorCodeError = [self expectedErrorWithCode:CRErrorCodeInvalidErrorCode
                                                     description:@"An unknown error occurred."];
    XCTAssertEqualObjects(invalidErrorCodeError, [NSError cr_errorWithCode:CRErrorCodeInvalidErrorCode]);
}

- (void)testErrorCodeWithCustomDescription {
    NSError *errorWithCustomDescription = [self expectedErrorWithCode:CRErrorCodeInvalidParameter
                                                          description:@"Invalid ad request parameter. TestParameter"];
    XCTAssertEqualObjects(errorWithCustomDescription, [NSError cr_errorWithCode:CRErrorCodeInvalidParameter
                                                                    description:@"TestParameter"]);
}

// test every error code has a non-default description
- (void)testValidResponseForAllErrorCodes {
    for (NSInteger errorCode = 0; errorCode < CRErrorCodeInvalidErrorCode; errorCode++) {
        XCTAssertNotEqual([NSError cr_descriptionForCode:errorCode], @"An unknown error occurred.");
    }
}

//default ErrorCode is CRErrorCodeInternalError
- (void)testDefaultAndNotInEnumErrorCodes {
    NSError *defaultError = [self expectedErrorWithCode:CRErrorCodeInternalError
                                            description:@"Ad request failed due to an internal error."];
    NSInteger defaultErrorCode = 0;
    XCTAssertEqualObjects(defaultError, [NSError cr_errorWithCode:defaultErrorCode]);
    NSInteger errorCodeNotInEnum = NSIntegerMax;
    NSError *notInEnumError = [self expectedErrorWithCode:NSIntegerMax description:@"An unknown error occurred."];
    XCTAssertEqualObjects(notInEnumError, [NSError cr_errorWithCode:errorCodeNotInEnum]);
}

@end
