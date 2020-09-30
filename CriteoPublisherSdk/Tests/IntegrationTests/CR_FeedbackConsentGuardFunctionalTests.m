//
//  CR_FeedbackConsentGuardFunctionalTests.m
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
#import <OCMock/OCMock.h>
#import "CR_FeedbackConsentGuard.h"
#import "CR_DataProtectionConsent.h"
#import "CR_Gdpr.h"
#import "CR_InMemoryUserDefaults.h"

@interface CR_FeedbackConsentGuardFunctionalTests : XCTestCase
@end

@interface CR_FeedbackConsentGuard (Testing)
- (BOOL)hasFeedbackConsent;
@end

@implementation CR_FeedbackConsentGuardFunctionalTests

- (void)testFeedbackConsentFromJSONScenario {
  NSArray *testCases = [self givenConsentTestCasesFromJSON];
  [testCases enumerateObjectsUsingBlock:^(NSDictionary *testCase, NSUInteger idx, BOOL *stop) {
    NSString *given = testCase[@"given"];
    NSDictionary *tcData = testCase[@"tcData"];
    NSUserDefaults *userDefaults = [self userDefaultsWithJSON:tcData];
    BOOL expected = ((NSNumber *)testCase[@"expected"]).boolValue;
    BOOL consent = [self hasConsentForUserDefaults:userDefaults];
    XCTAssertEqual(consent, expected, @"Consent was %@expected given \"%@\":\n%@",
                   expected ? @"" : @"not ", given, tcData);
  }];
}

#pragma mark - Private

- (NSArray *)givenConsentTestCasesFromJSON {
  NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
  NSString *path = [testBundle pathForResource:@"FeedbackConsentTestCases" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSUserDefaults *)userDefaultsWithJSON:(NSDictionary *)json {
  CR_InMemoryUserDefaults *userDefaults = CR_InMemoryUserDefaults.new;
  [json enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
    [userDefaults setObject:value forKey:key];
  }];
  return userDefaults;
}

- (BOOL)hasConsentForUserDefaults:(NSUserDefaults *)userDefaults {
  CR_Gdpr *gdpr = OCMPartialMock([[CR_Gdpr alloc] initWithUserDefaults:userDefaults]);
  CR_DataProtectionConsent *consent = OCMStrictClassMock(CR_DataProtectionConsent.class);
  OCMStub(consent.gdpr).andReturn(gdpr);
  CR_FeedbackConsentGuard *guard = [CR_FeedbackConsentGuard.alloc initWithController:nil
                                                                             consent:consent];
  return guard.hasFeedbackConsent;
}

@end
