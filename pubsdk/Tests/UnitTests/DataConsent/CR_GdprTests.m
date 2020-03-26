//
//  CR_GdprTests.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/19/20.
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
    [self.userDefaults setGdprTcf1_1GdprApplies:NO];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion1_1);
}

- (void)testVersion1_1WithVendorConsents {
    [self.userDefaults setGdprTcf1_1VendorConsents:NSString.gdprAllVendorConsentDeniedString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion1_1);
}

- (void)testVersion2_0WithConsentString {
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0WithGdprApplies {
    [self.userDefaults setGdprTcf2_0GdprApplies:NO];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0WithVendorConsents {
    [self.userDefaults setGdprTcf2_0VendorConsents:NSString.gdprAllVendorConsentDeniedString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithConsentString {
    [self.userDefaults setGdprTcf1_1GdprApplies:YES];
    [self.userDefaults setGdprTcf1_1DefaultVendorConsents];
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithGdprApplies {
    [self.userDefaults setGdprTcf1_1GdprApplies:YES];
    [self.userDefaults setGdprTcf1_1DefaultVendorConsents];
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0GdprApplies:YES];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithVendorConsents {
    [self.userDefaults setGdprTcf1_1GdprApplies:YES];
    [self.userDefaults setGdprTcf1_1DefaultVendorConsents];
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultVendorConsents];
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
#define AssertGdprApply(tcfVersion, grpApply) \
do { \
    [self.userDefaults clearGdpr]; \
    [self.userDefaults setGdprTcf ## tcfVersion ## GdprApplies:grpApply]; \
    XCTAssertEqualObjects(self.gdpr.applies, @(grpApply)); \
} while (0);

    AssertGdprApply(1_1, YES);
    AssertGdprApply(1_1, NO);
    AssertGdprApply(2_0, YES);
    AssertGdprApply(2_0, NO);

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
    [self.userDefaults setGdprTcf2_0GdprApplies:YES];
    XCTAssertEqualObjects(self.gdpr.applies, @YES);
}

- (void)testGDPRApplyTCF1WithContentStringForTcf1_1andTcf2_0 {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    [self.userDefaults setGdprTcf1_1GdprApplies:YES];
    XCTAssertNil(self.gdpr.applies);
}

#pragma mark - ConsentGivenToCriteo

- (void)testConsentGivenNone {
    XCTAssertNil(self.gdpr.consentGivenToCriteo);
}

- (void)testConsentGivenSimpleCases {
#define AssertConsentGiven(tcfVersion, vendorConsentString, expectedConsentGiven) \
do { \
    [self.userDefaults clearGdpr]; \
    [self.userDefaults setGdprTcf ## tcfVersion ## VendorConsents:vendorConsentString]; \
    XCTAssertEqualObjects(self.gdpr.consentGivenToCriteo, @(expectedConsentGiven)); \
} while (0);

    AssertConsentGiven(1_1, NSString.gdprAllVendorConsentAllowedString, YES);
    AssertConsentGiven(2_0, NSString.gdprAllVendorConsentAllowedString, YES);
    AssertConsentGiven(1_1, NSString.gdprOnlyCriteoConsentAllowedString, YES);
    AssertConsentGiven(2_0, NSString.gdprOnlyCriteoConsentAllowedString, YES);
    AssertConsentGiven(1_1, NSString.gdprAllVendorConsentDeniedString, NO);
    AssertConsentGiven(2_0, NSString.gdprAllVendorConsentDeniedString, NO);
    AssertConsentGiven(1_1, NSString.gdprOnlyCriteoConsentDeniedString, NO);
    AssertConsentGiven(2_0, NSString.gdprOnlyCriteoConsentDeniedString, NO);

#undef AssertConsentGiven
}

- (void)testTooShortConsentGivenTCF1_1 {
    [self.userDefaults setGdprTcf1_1VendorConsents:NSString.gdprVendorConsentShortString];
    XCTAssertNil(self.gdpr.consentGivenToCriteo);
}

- (void)testTooShortConsentGivenTCF2_0 {
    [self.userDefaults setGdprTcf2_0VendorConsents:NSString.gdprVendorConsentShortString];
    XCTAssertNil(self.gdpr.consentGivenToCriteo);
}

- (void)testConsentTCF2Priority {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    [self.userDefaults setGdprTcf1_1VendorConsents:NSString.gdprAllVendorConsentDeniedString];
    [self.userDefaults setGdprTcf2_0VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    XCTAssertTrue(self.gdpr.consentGivenToCriteo);
}

- (void)testConsentTCF2PriorityEvenEmpty {
    [self.userDefaults setGdprTcf1_1DefaultConsentString];
    [self.userDefaults setGdprTcf2_0DefaultConsentString];
    [self.userDefaults setGdprTcf1_1VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    XCTAssertFalse(self.gdpr.consentGivenToCriteo);
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

- (void)testBadVendorTypeInUserDefaultsTcf1_1 {
    [self.userDefaults setObject:[NSDate dateWithTimeIntervalSince1970:0]
                          forKey:NSString.gdprVendorConsentsUserDefaultsKeyTcf1_1];
    XCTAssertNoThrow(self.gdpr.consentGivenToCriteo);
    XCTAssertNil(self.gdpr.consentGivenToCriteo);
}

- (void)testBadVendorTypeInUserDefaultsTcf2_0 {
    [self.userDefaults setObject:[NSDate dateWithTimeIntervalSince1970:0]
                          forKey:NSString.gdprVendorConsentsUserDefaultsKeyTcf2_0];
    XCTAssertNoThrow(self.gdpr.consentGivenToCriteo);
    XCTAssertNil(self.gdpr.consentGivenToCriteo);
}

- (void)testGdprAppliesInUserDefaultsTcf1_1 {
    [self.userDefaults setObject:[NSDate dateWithTimeIntervalSince1970:0]
                          forKey:NSString.gdprAppliesUserDefaultsKeyTcf1_1];
    XCTAssertNoThrow(self.gdpr.applies);
    XCTAssertNil(self.gdpr.applies);
}

- (void)testGdprAppliesInUserDefaultsTcf2_0 {
    [self.userDefaults setObject:[NSDate dateWithTimeIntervalSince1970:0]
                          forKey:NSString.gdprAppliesUserDefaultsKeyTcf2_0];
    XCTAssertNoThrow(self.gdpr.applies);
    XCTAssertNil(self.gdpr.applies);
}

@end
