//
//  CR_DataProtectionConsentTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_DataProtectionConsent.h"
#import "CR_DataProtectionConsentMock.h"

NSString * const CR_DataProtectionConsentTestsApprovedVendorString = @"0000000000000010000000000000000000000100000000000000000000000000000000000000000000000000001";
NSString * const CR_DataProtectionConsentTestsUnapprovedVendorString = @"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
NSString * const CR_DataProtectionConsentTestsMalformed80CharsVendorString = @"000000000000000000000000000000000000000000000000000000000000000000000000000000000";
NSString * const CR_DataProtectionConsentTestsMalformed90CharsVendorString = @"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";


#define CR_AssertShouldSendEvent(consentString, usPrivacyCriteoState, mopubConsentStr, shouldSendAppEvent) \
do { \
    [self _checkShouldSendAppEvent:shouldSendAppEvent \
          withUsPrivacyCriteoState:usPrivacyCriteoState \
                  iabConsentString:consentString \
                      mopubConsent:mopubConsentStr \
                            atLine:__LINE__]; \
} while (0);

@interface CR_DataProtectionConsentTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, assign) BOOL defaultGdprApplies;
@property (nonatomic, strong) NSString *defaultConsentString;

@property (nonatomic, strong) CR_DataProtectionConsent *consent1;
@property (nonatomic, strong) CR_DataProtectionConsent *consent2;

@end

@implementation CR_DataProtectionConsentTests

- (void)setUp
{
    self.defaultGdprApplies = YES;
    self.defaultConsentString = CR_DataProtectionConsentMockDefaultConsentString;

    NSNumber *defaultGdprAppliesNumber = [NSNumber numberWithBool:self.defaultGdprApplies];

    self.userDefaults = [[NSUserDefaults alloc] init];
    [self.userDefaults setObject:defaultGdprAppliesNumber forKey:@"IABConsent_SubjectToGDPR"];
    [self.userDefaults setObject:self.defaultConsentString forKey:@"IABConsent_ConsentString"];
    [self.userDefaults removeObjectForKey:@"IABConsent_ParsedVendorConsents"];
    [self.userDefaults removeObjectForKey:CR_CcpaCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_CcpaIabConsentStringKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentMopubConsentKey];

    self.consent1 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
    self.consent2 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
}

- (void)testGetUsPrivacyIABContent
{
    [self.userDefaults setObject:CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString
                          forKey:CR_CcpaIabConsentStringKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    NSString *actualUspIab = consent.usPrivacyIabConsentString;
    XCTAssertEqualObjects(actualUspIab, CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)testGetUsPrivacyCriteoStateUnset
{
    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_CcpaCriteoStateUnset);
}

- (void)testGetUsPrivacyCriteoStateOptIn
{
    [self.userDefaults setInteger:CR_CcpaCriteoStateOptIn
                           forKey:CR_CcpaCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_CcpaCriteoStateOptIn);
}

- (void)testGetUsPrivacyCriteoStateOptOut
{
    [self.userDefaults setInteger:CR_CcpaCriteoStateOptOut
                           forKey:CR_CcpaCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_CcpaCriteoStateOptOut);
}

- (void)testSetUsPrivacyCriteoStateOptOut
{
    self.consent1.usPrivacyCriteoState = CR_CcpaCriteoStateOptOut;

    XCTAssertEqual(self.consent2.usPrivacyCriteoState, CR_CcpaCriteoStateOptOut);
}

#pragma mark - Mopub Consent

- (void)testMopubConsentEmpty
{
    XCTAssertNil(self.consent2.mopubConsent);
}

- (void)testSetMopubConsentInUserDefault
{
    NSString *consentValue = @"EXPLICIT_YES";

    self.consent1.mopubConsent = consentValue;

    XCTAssertEqual(self.consent2.mopubConsent, consentValue);
}

#pragma mark - ShouldSendAppEvent

- (void)testShouldSendAppEventWithUsPrivacy {
    // All cases for the CCPA Criteo State only.
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateOptIn, nil, YES);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateOptOut, nil, NO);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, nil, YES);

    // CCPA Criteo State with IAB Consent empty.
    CR_AssertShouldSendEvent(@"", CR_CcpaCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"", CR_CcpaCriteoStateOptOut, nil, NO);

    // All case for Mopub Consent only
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"", YES);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"random string", YES);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"EXPLICIT_YES", YES);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"UNKNOWN", YES);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"EXPLICIT_NO", NO);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"POTENTIAL_WHITELIST", NO);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"DNT", NO);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"explicit_yes", YES);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"unknown", YES);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"explicit_no", NO);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"potential_whitelist", NO);
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateUnset, @"dnt", NO);

    // Not-empty IAB consent string takes over the criteo state.
    CR_AssertShouldSendEvent(@"random string", CR_CcpaCriteoStateOptIn, nil, YES);
    CR_AssertShouldSendEvent(@"random string", CR_CcpaCriteoStateOptOut, nil, YES);

    // Opt-in IAB consent strings including lowercases.
    CR_AssertShouldSendEvent(@"1---", CR_CcpaCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1YNY", CR_CcpaCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1yny", CR_CcpaCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1Ynn", CR_CcpaCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1Yn-", CR_CcpaCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1-n-", CR_CcpaCriteoStateUnset, nil, YES);

    // Opt-in CCPA IAB Consent string takes over CriteoState.
    CR_AssertShouldSendEvent(@"1---", CR_CcpaCriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1YNY", CR_CcpaCriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1YNN", CR_CcpaCriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1Yn-", CR_CcpaCriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1-n-", CR_CcpaCriteoStateOptOut, nil, YES);

    // Opt-out CCPA IAB Consent string.
    CR_AssertShouldSendEvent(@"1yyy", CR_CcpaCriteoStateUnset, nil, NO);
    CR_AssertShouldSendEvent(@"1yyn", CR_CcpaCriteoStateUnset, nil, NO);

    // Opt-out CCPA IAB Consent string takes over CCPA CriteoState.
    CR_AssertShouldSendEvent(@"1YYY", CR_CcpaCriteoStateOptIn, nil, NO);
    CR_AssertShouldSendEvent(@"1YYN", CR_CcpaCriteoStateOptIn, nil, NO);

    // Opt-out Mopub Consent takes over CCPA Consent.
    CR_AssertShouldSendEvent(nil, CR_CcpaCriteoStateOptIn, @"EXPLICIT_NO", NO);
    CR_AssertShouldSendEvent(@"1YNN", CR_CcpaCriteoStateUnset, @"EXPLICIT_NO", NO);
}

#pragma mark Private for ShouldSendAppEvent

- (void)_checkShouldSendAppEvent:(BOOL)shouldSendAppEvent
        withUsPrivacyCriteoState:(CR_CcpaCriteoState)usPrivacyCriteoState
                iabConsentString:(NSString *)iabConsentString
                    mopubConsent:(NSString *)mopubConsent
                          atLine:(NSUInteger)lineNumber {
    if (iabConsentString) {
        [self.userDefaults setObject:iabConsentString
                              forKey:CR_CcpaIabConsentStringKey];
    }
    [self.userDefaults setInteger:usPrivacyCriteoState
                           forKey:CR_CcpaCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
    consent.mopubConsent = mopubConsent;

    if (consent.shouldSendAppEvent != shouldSendAppEvent) {
        NSString *desc = [[NSString alloc] initWithFormat:@"usPrivacyCriteoState = %ld & iabConsentString = %@, mopubConsent = %@ => shouldSendAppEvent %d", (long)usPrivacyCriteoState, iabConsentString, mopubConsent, shouldSendAppEvent];
        NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
        [self recordFailureWithDescription:desc
                                    inFile:file
                                    atLine:lineNumber
                                  expected:YES];
    }

    [self.userDefaults removeObjectForKey:CR_CcpaCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_CcpaIabConsentStringKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentMopubConsentKey];
}

@end