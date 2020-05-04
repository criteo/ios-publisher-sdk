//
//  CR_GdprTests.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_Gdpr.h"
#import "NSString+GDPR.h"
#import "NSUserDefaults+GDPR.h"

@interface CR_GdprTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) CR_Gdpr *gdpr;

@end

@implementation CR_GdprTests

- (void)setUp {
    self.userDefaults = [[NSUserDefaults alloc] init];
    self.gdpr = [[CR_Gdpr alloc] initWithUserDefaults:self.userDefaults];

    [self.userDefaults clearGdpr];
}

#pragma mark - TCF Version

- (void)testVersionUnknown {
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersionUnknown);
}

- (void)testVersion1_1WithConsentString {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion1_1);
}

- (void)testVersion1_1WithGdprApplies {
    [self.userDefaults setGdprTcf1_1GdprApplies:@NO];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion1_1);
}

- (void)testVersion2_0WithConsentString {
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0WithGdprApplies {
    [self.userDefaults setGdprTcf2_0GdprApplies:@NO];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithConsentString {
    [self.userDefaults setGdprTcf1_1GdprApplies:@YES];
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithGdprApplies {
    [self.userDefaults setGdprTcf1_1GdprApplies:@YES];
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0GdprApplies:@YES];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

#pragma mark - Consent String

- (void)testConsentStringWithTcf1_1 {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    XCTAssertEqualObjects(self.gdpr.consentString, NSString.gdprConsentStringForTcf1_1);
}

- (void)testConsentStringTcf2_0 {
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    XCTAssertEqualObjects(self.gdpr.consentString, NSString.gdprConsentStringForTcf2_0);
}

- (void)testConsentString_TCF1_TCF2 {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    XCTAssertEqualObjects(self.gdpr.consentString, NSString.gdprConsentStringForTcf2_0);
}

#pragma mark - applies

- (void)testGdprAppliesSimpleCases {
#define AssertGdprApply(tcfVersion, grpApply, expected) \
do { \
    [self.userDefaults clearGdpr]; \
    [self.userDefaults setGdprTcf ## tcfVersion ## GdprApplies:grpApply]; \
    XCTAssertEqualObjects(self.gdpr.applies, expected); \
} while (0);

    AssertGdprApply(1_1, nil, nil);
    AssertGdprApply(1_1, @"malformed", @NO);
    AssertGdprApply(1_1, @"1", @YES);
    AssertGdprApply(1_1, @"0", @NO);
    AssertGdprApply(2_0, nil, nil);
    AssertGdprApply(2_0, @YES, @YES);
    AssertGdprApply(2_0, @NO, @NO);
    AssertGdprApply(2_0, @"malformed", @NO);

#undef AssertGdprApply
}

- (void)testGDPRApplyWithNoContentString {
    XCTAssertNil(self.gdpr.applies);
}

- (void)testGDPRApplyEmptyWithContentStringForTcf1_1 {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    XCTAssertNil(self.gdpr.applies);
}

- (void)testGDPRApplyEmptyWithContentStringForTcf2_0 {
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    XCTAssertNil(self.gdpr.applies);
}

#pragma mark TCF2/TCF2

- (void)testGDPRApplyWithContentStringForTcf1_1andTcf2_0 {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    [self.userDefaults setGdprTcf2_0GdprApplies:@YES];
    XCTAssertEqualObjects(self.gdpr.applies, @YES);
}

- (void)testGDPRApplyTCF1WithContentStringForTcf1_1andTcf2_0 {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    [self.userDefaults setGdprTcf1_1GdprApplies:@YES];
    XCTAssertNil(self.gdpr.applies);
}


#pragma mark - Bad Userdefaults value

- (void)testBadConsentStringTypeInUserDefaultsTcf1_1 {
    [self.userDefaults setObject:[NSDate dateWithTimeIntervalSince1970:0]
                          forKey:NSString.gdprConsentStringUserDefaultsKeyTcf1_1];
    XCTAssertNoThrow(self.gdpr.consentString);
    XCTAssertNil(self.gdpr.consentString);
}

- (void)testBadConsentStringTypeInUserDefaultsTcf2_0 {
    [self.userDefaults setObject:[NSDate dateWithTimeIntervalSince1970:0]
                          forKey:NSString.gdprConsentStringUserDefaultsKeyTcf2_0];
    XCTAssertNoThrow(self.gdpr.consentString);
    XCTAssertNil(self.gdpr.consentString);
}

@end
