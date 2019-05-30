//
//  NSError+CRErrorsTests.m
//  pubsdkTests
//
//  Created by Sneha Pathrose on 5/21/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSError+CRErrors.h"

@interface NSError_CRErrorsTests : XCTestCase

@end

@implementation NSError_CRErrorsTests

- (void)testErrorCodesWithDefaultDescription {
    NSError *internalError =[NSError errorWithDomain:@"com.criteo.pubsdk"
                                                code:CRErrorCodeInternalError
                                            userInfo:@{@"Description": @"Ad request failed due to an internal error."}];
    XCTAssertEqualObjects(internalError, [NSError CRErrors_errorWithCode:CRErrorCodeInternalError]);

    NSError *noFillError =[NSError errorWithDomain:@"com.criteo.pubsdk"
                                              code:CRErrorCodeNoFill
                                          userInfo:@{@"Description": @"Ad request succeeded but no ads are available."}];
    XCTAssertEqualObjects(noFillError, [NSError CRErrors_errorWithCode:CRErrorCodeNoFill]);

    NSError *invalidRequestError =[NSError errorWithDomain:@"com.criteo.pubsdk"
                                                      code:CRErrorCodeInvalidRequest
                                                  userInfo:@{@"Description": @"Invalid ad request."}];
    XCTAssertEqualObjects(invalidRequestError, [NSError CRErrors_errorWithCode:CRErrorCodeInvalidRequest]);

    NSError *networkError =[NSError errorWithDomain:@"com.criteo.pubsdk"
                                               code:CRErrorCodeNetworkError
                                           userInfo:@{@"Description": @"Ad request failed due to network error."}];
    XCTAssertEqualObjects(networkError, [NSError CRErrors_errorWithCode:CRErrorCodeNetworkError]);

    NSError *invalidParameterError =[NSError errorWithDomain:@"com.criteo.pubsdk"
                                                        code:CRErrorCodeInvalidParameter
                                                    userInfo:@{@"Description": @"Invalid ad request parameter."}];
    XCTAssertEqualObjects(invalidParameterError, [NSError CRErrors_errorWithCode:CRErrorCodeInvalidParameter]);

    NSError *invalidErrorCodeError =[NSError errorWithDomain:@"com.criteo.pubsdk"
                                                        code:CRErrorCodeInvalidErrorCode
                                                    userInfo:@{@"Description": @"An unknown error occured."}];
    XCTAssertEqualObjects(invalidErrorCodeError, [NSError CRErrors_errorWithCode:CRErrorCodeInvalidErrorCode]);
}

- (void)testErrorCodeWithCustomDescription {
    NSError *errorWithCustomDescription =[NSError errorWithDomain:@"com.criteo.pubsdk"
                                                             code:CRErrorCodeInvalidParameter
                                                         userInfo:@{@"Description": @"Invalid ad request parameter. TestParameter"}];
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
    NSError *defaultError = [NSError errorWithDomain:@"com.criteo.pubsdk"
                                                code:CRErrorCodeInternalError
                                            userInfo:@{@"Description": @"Ad request failed due to an internal error."}];
    NSInteger defaultErrorCode = 0;
    XCTAssertEqualObjects(defaultError, [NSError CRErrors_errorWithCode:defaultErrorCode]);
    NSInteger errorCodeNotInEnum = NSIntegerMax;
    NSError *notInEnumError = [NSError errorWithDomain:@"com.criteo.pubsdk"
                                                  code:NSIntegerMax
                                              userInfo:@{@"Description": @"An unknown error occured."}];
    XCTAssertEqualObjects(notInEnumError, [NSError CRErrors_errorWithCode:errorCodeNotInEnum]);
}

@end
