//
//  CRCustomEventHelperTests.m
//  CriteoMoPubAdapterTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CRCustomEventHelper.h"

@interface CRCustomEventHelperTests : XCTestCase

@end

@implementation CRCustomEventHelperTests

#pragma mark - checkValidInfo:

- (void)testInfoKeyMissing {
    NSDictionary *info = @{ @"invalidKey" : @"value", @"cpid" : @"i should be uppercase" };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void)testInfoValueMissing {
    NSDictionary *info = @{ @"cpId" : [NSNull null], @"adUnitId" : [NSNull null] };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void)testInfoValueNotString {
    NSDictionary *info = @{ @"cpId" : @21, @"adUnitId" : @48 };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void)testInfoValueEmptyString {
    NSDictionary *info = @{ @"cpId" : @"", @"adUnitId" : @"" };
    XCTAssertFalse([CRCustomEventHelper checkValidInfo:info]);
}

- (void)testValidInfo {
    NSDictionary *info = @{ @"cpId" : @"Publisher Id", @"some Key" : @"some value", @"adUnitId" : @"an adUnitId" };
    XCTAssertTrue([CRCustomEventHelper checkValidInfo:info]);
}

#pragma mark - checkValidInfo:withError:

#define AssertAllKeysErrorForInfo(_info) \
do { \
[self recordFailureForAllKeyMissingOrInvalidWithInfo:_info \
                                              atLine:__LINE__]; \
} while (0);

- (void)testMissingOrInvalidKeysWithError {
    AssertAllKeysErrorForInfo(nil);
    AssertAllKeysErrorForInfo((@{}));
    AssertAllKeysErrorForInfo((@{ @"invalidKey" : @"value", @"cpid" : @"i should be uppercase" }));
    AssertAllKeysErrorForInfo((@{ @"cpId" : [NSNull null], @"adUnitId" : [NSNull null] }));
    AssertAllKeysErrorForInfo((@{ @"cpId" : @21, @"adUnitId" : @48 }));
    AssertAllKeysErrorForInfo((@{ @"cpId" : @"", @"adUnitId" : @"" }));
}

- (void)testMissingCpIdKey {
    NSDictionary *info = @{ @"adUnitId" : @"an adUnitId" };
    NSError *error = nil;
    BOOL isValid = [CRCustomEventHelper checkValidInfo:info
                                             withError:&error];

    NSString *expectedDesc = [self errorDescriptionContainingStrings:@[
        @"The Criteo 'cpId' key is missing or invalid."
    ]];
    XCTAssertFalse(isValid);
    XCTAssertEqualObjects(error.localizedDescription, expectedDesc);
}

- (void)testMissingAdUnitId {
    NSDictionary *info = @{ @"cpId" : @"Publisher Id" };
    NSError *error = nil;
    BOOL isValid = [CRCustomEventHelper checkValidInfo:info
                                             withError:&error];

    NSString *expectedDesc = [self errorDescriptionContainingStrings:@[
        @"The Criteo 'adUnitId' key is missing or invalid."
    ]];
    XCTAssertFalse(isValid);
    XCTAssertEqualObjects(error.localizedDescription, expectedDesc);
}

- (void)testValidInfoStringWithError {
    NSDictionary *info = @{ @"cpId" : @"Publisher Id", @"some Key" : @"some value", @"adUnitId" : @"an adUnitId" };
    NSError *error = nil;

    BOOL isValid = [CRCustomEventHelper checkValidInfo:info
                                             withError:&error];

    XCTAssertTrue(isValid);
    XCTAssertNil(error);
}

#pragma mark - Utils

- (void)recordFailureForAllKeyMissingOrInvalidWithInfo:(NSDictionary *)info
                                                atLine:(NSUInteger)lineNumber {
    NSError *error = nil;
    BOOL isValid = [CRCustomEventHelper checkValidInfo:info
                                             withError:&error];

    if (isValid) {
        NSString *file = [[NSString alloc] initWithCString:__FILE__
                                                  encoding:NSUTF8StringEncoding];
        NSString *desc = [NSString stringWithFormat:
                          @"Given info should be invalid: %@", info];
        [self recordFailureWithDescription:desc
                                    inFile:file
                                    atLine:lineNumber
                                  expected:YES];
    }

    NSString *errDesc = [self errorDescriptionForAllKeysMissingOrInvalid];
    if ((error == nil) || ![error.localizedDescription isEqualToString:errDesc]) {
        NSString *file = [[NSString alloc] initWithCString:__FILE__
                                                  encoding:NSUTF8StringEncoding];
        NSString *desc = [NSString stringWithFormat:
                          @"Passed error description %@ is not equal to %@",
                          error.localizedDescription, errDesc];
        [self recordFailureWithDescription:desc
                                    inFile:file
                                    atLine:lineNumber
                                  expected:YES];
    }
}

- (NSString *)errorDescriptionForAllKeysMissingOrInvalid {
    return [self errorDescriptionContainingStrings:@[
        @"The Criteo 'cpId' key is missing or invalid.",
        @"The Criteo 'adUnitId' key is missing or invalid."
    ]];
}

- (NSString *)errorDescriptionContainingStrings:(NSArray<NSString *> *)strings {
    NSString *joined = [strings componentsJoinedByString:@" "];
    NSString *description = [joined stringByAppendingString:@" No ad request sent. Ensure this key is valid on the MoPub dashboard."];
    return description;
}

@end
