//
//  NSError+CRErrorsTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSError+CRErrors.h"

@interface NSError_CRErrorsTests : XCTestCase

@end

@implementation NSError_CRErrorsTests

- (NSError *)expectedErrorWithCode:(CRErrorCode)errorCode description:(NSString *)description {
    return [NSError errorWithDomain:@"com.criteo.pubsdk"
                               code:errorCode
                           userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]];
}

- (void)testErrorCodesWithDefaultDescription {
    NSError *internalError = [self expectedErrorWithCode:CRErrorCodeInternalError
                                             description:@"Ad request failed due to an internal error."];
    XCTAssertEqualObjects(internalError, [NSError CRErrors_errorWithCode:CRErrorCodeInternalError]);

    NSError *noFillError = [self expectedErrorWithCode:CRErrorCodeNoFill
                                           description:@"Ad request succeeded but no ads are available."];
    XCTAssertEqualObjects(noFillError, [NSError CRErrors_errorWithCode:CRErrorCodeNoFill]);

    NSError *invalidRequestError = [self expectedErrorWithCode:CRErrorCodeInvalidRequest
                                                   description:@"Invalid ad request."];
    XCTAssertEqualObjects(invalidRequestError, [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest]);

    NSError *networkError = [self expectedErrorWithCode:CRErrorCodeNetworkError description:@"Ad request failed due to network error."];
    XCTAssertEqualObjects(networkError, [NSError CRErrors_errorWithCode:CRErrorCodeNetworkError]);

    NSError *invalidParameterError = [self expectedErrorWithCode:CRErrorCodeInvalidParameter
                                                     description:@"Invalid ad request parameter."];
    XCTAssertEqualObjects(invalidParameterError, [NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter]);

    NSError *invalidErrorCodeError = [self expectedErrorWithCode:CRErrorCodeInvalidErrorCode description:@"An unknown error occured."];
    XCTAssertEqualObjects(invalidErrorCodeError, [NSError CRErrors_errorWithCode:CRErrorCodeInvalidErrorCode]);
}

- (void)testErrorCodeWithCustomDescription {
    NSError *errorWithCustomDescription = [self expectedErrorWithCode:CRErrorCodeInvalidParameter description:@"Invalid ad request parameter. TestParameter"];
    XCTAssertEqualObjects(errorWithCustomDescription, [NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter description:@"TestParameter"]);
}

// test every error code has a non-default description
- (void)testValidResponseForAllErrorCodes {
    for(NSInteger errorCode = 0;errorCode < CRErrorCodeInvalidErrorCode; errorCode++) {
        XCTAssertNotEqual([NSError descriptionForCRErrorCode:errorCode], @"An unknown error occured.");
    }
}

//default ErrorCode is CRErrorCodeInternalError
- (void)testDefaultAndNotInEnumErrorCodes {
    NSError *defaultError = [self expectedErrorWithCode:CRErrorCodeInternalError
                                            description:@"Ad request failed due to an internal error."];
    NSInteger defaultErrorCode = 0;
    XCTAssertEqualObjects(defaultError, [NSError CRErrors_errorWithCode:defaultErrorCode]);
    NSInteger errorCodeNotInEnum = NSIntegerMax;
    NSError *notInEnumError = [self expectedErrorWithCode:NSIntegerMax description:@"An unknown error occured."];
    XCTAssertEqualObjects(notInEnumError, [NSError CRErrors_errorWithCode:errorCodeNotInEnum]);
}

@end
