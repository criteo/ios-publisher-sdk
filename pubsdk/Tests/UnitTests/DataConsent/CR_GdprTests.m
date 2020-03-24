//
//  CR_GdprTests.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/19/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_Gdpr.h"
#import "CR_GdprVersion.h"
#import "NSString+GDPR.h"

@interface CR_GdprTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) CR_Gdpr *gdpr;

@end

@implementation CR_GdprTests

- (void)setUp {
    self.userDefaults = [[NSUserDefaults alloc] init];
    self.gdpr = [[CR_Gdpr alloc] initWithUserDefaults:self.userDefaults];

    [self clearUserDefaults];
}

#pragma mark - TCF Version

- (void)testVersionUnknown {
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersionUnknown);
}

- (void)testVersion1_1WithConsentString {
    [self setupConsentStringForTcf1_1];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion1_1);
}

- (void)testVersion1_1WithGdprApplies {
    [self setupTcf1_1GdprApplies:NO];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion1_1);
}

- (void)testVersion1_1WithVendorConsents {
    [self setupTcf1_1VendorConsents:NSString.gdprAllVendorConsentDeniedString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion1_1);
}

- (void)testVersion2_0WithConsentString {
    [self setupConsentStringForTcf2_0];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0WithGdprApplies {
    [self setupTcf2_0GdprApplies:NO];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0WithVendorConsents {
    [self setupTcf2_0VendorConsents:NSString.gdprAllVendorConsentDeniedString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithConsentString {
    [self setupTcf1_1GdprApplies:YES];
    [self setupTcf1_1VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    [self setupConsentStringForTcf1_1];
    [self setupConsentStringForTcf2_0];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithGdprApplies {
    [self setupTcf1_1GdprApplies:YES];
    [self setupTcf1_1VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    [self setupConsentStringForTcf1_1];
    [self setupTcf2_0GdprApplies:YES];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

- (void)testVersion2_0and1_1WithVendorConsents {
    [self setupTcf1_1GdprApplies:YES];
    [self setupTcf1_1VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    [self setupConsentStringForTcf1_1];
    [self setupTcf2_0VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    XCTAssertEqual(self.gdpr.tcfVersion, CR_GdprTcfVersion2_0);
}

#pragma mark - Consent String

- (void)testConsentStringWithTcf1_1 {
    [self setupConsentStringForTcf1_1];
    XCTAssertEqualObjects(self.gdpr.consentString, NSString.gdprConsentStringForTcf1_1);
}

- (void)testConsentStringTcf2_0 {
    [self setupConsentStringForTcf2_0];
    XCTAssertEqualObjects(self.gdpr.consentString, NSString.gdprConsentStringForTcf2_0);
}

- (void)testConsentString_TCF1_TCF2 {
    [self setupConsentStringForTcf1_1];
    [self setupConsentStringForTcf2_0];
    XCTAssertEqualObjects(self.gdpr.consentString, NSString.gdprConsentStringForTcf2_0);
}

#pragma mark - isApplied

- (void)testGdprAppliesSimpleCases {
#define AssertGdprApply(tcfVersion, grpApply) \
do { \
    [self clearUserDefaults]; \
    [self setupConsentStringForTcf ## tcfVersion]; \
    [self setupTcf ## tcfVersion ## GdprApplies:grpApply]; \
    XCTAssertEqual(self.gdpr.isApplied, grpApply); \
} while (0);

    AssertGdprApply(1_1, YES);
    AssertGdprApply(1_1, NO);
    AssertGdprApply(2_0, YES);
    AssertGdprApply(2_0, NO);

#undef AssertGdprApply
}

#pragma mark TCF1

- (void)testGDPRApplyWithNoContentString {
    XCTAssertTrue(self.gdpr.isApplied);
}

- (void)testGDPRApplyEmptyWithContentStringForTcf1_1 {
    [self setupConsentStringForTcf1_1];
    XCTAssertFalse(self.gdpr.isApplied);
}

#pragma mark TCF2


- (void)testGDPRApplyEmptyWithContentStringForTcf2_0 {
    [self setupConsentStringForTcf2_0];
    XCTAssertFalse(self.gdpr.isApplied);
}

#pragma mark TCF2/TCF2

- (void)testGDPRApplyWithContentStringForTcf1_1andTcf2_0 {
    [self setupConsentStringForTcf1_1];
    [self setupConsentStringForTcf2_0];
    [self setupTcf2_0GdprApplies:YES];
    XCTAssertTrue(self.gdpr.isApplied);
}

- (void)testGDPRApplyTCF1WithContentStringForTcf1_1andTcf2_0 {
    [self setupConsentStringForTcf1_1];
    [self setupConsentStringForTcf2_0];
    [self setupTcf1_1GdprApplies:YES];
    XCTAssertFalse(self.gdpr.isApplied);
}

#pragma mark - ConsentGivenToCriteo

- (void)testConsentGivenNone {
    XCTAssertFalse(self.gdpr.consentGivenToCriteo);
}

- (void)testConsentGivenSimpleCases {
#define AssertConsentGiven(tcfVersion, vendorConsentString, expectedConsentGiven) \
do { \
    [self clearUserDefaults]; \
    [self setupConsentStringForTcf ## tcfVersion]; \
    [self setupTcf ## tcfVersion ## VendorConsents:vendorConsentString]; \
    XCTAssertEqual(self.gdpr.consentGivenToCriteo, expectedConsentGiven); \
} while (0);

    AssertConsentGiven(1_1, NSString.gdprAllVendorConsentAllowedString, YES);
    AssertConsentGiven(2_0, NSString.gdprAllVendorConsentAllowedString, YES);
    AssertConsentGiven(1_1, NSString.gdprOnlyCriteoConsentAllowedString, YES);
    AssertConsentGiven(2_0, NSString.gdprOnlyCriteoConsentAllowedString, YES);
    AssertConsentGiven(1_1, NSString.gdprAllVendorConsentDeniedString, NO);
    AssertConsentGiven(2_0, NSString.gdprAllVendorConsentDeniedString, NO);
    AssertConsentGiven(1_1, NSString.gdprOnlyCriteoConsentDeniedString, NO);
    AssertConsentGiven(2_0, NSString.gdprOnlyCriteoConsentDeniedString, NO);
    AssertConsentGiven(1_1, NSString.gdprVendorConsentShortString, NO);
    AssertConsentGiven(2_0, NSString.gdprVendorConsentShortString, NO);

#undef AssertConsentGiven
}

- (void)testConsentTCF2Priority {
    [self setupConsentStringForTcf1_1];
    [self setupConsentStringForTcf2_0];
    [self setupTcf1_1VendorConsents:NSString.gdprAllVendorConsentDeniedString];
    [self setupTcf2_0VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    XCTAssertTrue(self.gdpr.consentGivenToCriteo);
}

- (void)testConsentTCF2PriorityEvenEmpty {
    [self setupConsentStringForTcf1_1];
    [self setupConsentStringForTcf2_0];
    [self setupTcf1_1VendorConsents:NSString.gdprAllVendorConsentAllowedString];
    XCTAssertFalse(self.gdpr.consentGivenToCriteo);
}

#pragma mark - Test Utils

- (void)clearUserDefaults {
    [self.userDefaults removeObjectForKey:CR_GdprAppliesForTcf2_0Key];
    [self.userDefaults removeObjectForKey:CR_GdprConsentStringForTcf2_0Key];
    [self.userDefaults removeObjectForKey:CR_GdprVendorConsentsForTcf2_0Key];
    [self.userDefaults removeObjectForKey:CR_GdprSubjectToGdprForTcf1_1Key];
    [self.userDefaults removeObjectForKey:CR_GdprConsentStringForTcf1_1Key];
    [self.userDefaults removeObjectForKey:CR_GdprVendorConsentsForTcf1_1Key];
}

- (void)setupConsentStringForTcf1_1 {
    [self.userDefaults setObject:NSString.gdprConsentStringForTcf1_1
                          forKey:CR_GdprConsentStringForTcf1_1Key];
}

- (void)setupConsentStringForTcf2_0 {
    [self.userDefaults setObject:NSString.gdprConsentStringForTcf2_0
                          forKey:CR_GdprConsentStringForTcf2_0Key];
}


- (void)setupTcf1_1GdprApplies:(BOOL)gdprApplies {
    [self.userDefaults setBool:gdprApplies
                        forKey:CR_GdprSubjectToGdprForTcf1_1Key];
}

- (void)setupTcf2_0GdprApplies:(BOOL)gdprApplies {
    [self.userDefaults setBool:gdprApplies
                        forKey:CR_GdprAppliesForTcf2_0Key];
}

- (void)setupTcf1_1VendorConsents:(NSString *)vendorConsents {
    [self.userDefaults setObject:vendorConsents
                          forKey:CR_GdprVendorConsentsForTcf1_1Key];
}

- (void)setupTcf2_0VendorConsents:(NSString *)vendorConsents {
    [self.userDefaults setObject:vendorConsents
                          forKey:CR_GdprVendorConsentsForTcf2_0Key];
}

@end
