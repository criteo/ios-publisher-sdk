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
} while (0)

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
    [self.userDefaults removeObjectForKey:CR_CCPAConsentCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_CCPAIabConsentStringKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentMopubConsentKey];

    self.consent1 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
    self.consent2 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
}


- (void)testGdprGet
{

    NSString *vendorString = CR_DataProtectionConsentTestsApprovedVendorString;
    [self.userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual([consent consentGiven], YES);
    XCTAssertEqualObjects(self.defaultConsentString, consent.consentString);
    XCTAssertEqual([consent gdprApplies], self.defaultGdprApplies);
}

- (void)testGdprGetCriteoNotApprovedVendor
{
    NSString *vendorString = CR_DataProtectionConsentTestsUnapprovedVendorString;
    [self.userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual([consent consentGiven], NO);
    XCTAssertEqualObjects(self.defaultConsentString, consent.consentString);
    XCTAssertEqual([consent gdprApplies], self.defaultGdprApplies);
}

- (void)testTheTestThatIsnt
{
    NSString *vendorString = CR_DataProtectionConsentTestsMalformed80CharsVendorString;
    [self.userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual([consent consentGiven], NO);
    XCTAssertEqualObjects(self.defaultConsentString, consent.consentString);
    XCTAssertEqual([consent gdprApplies], self.defaultGdprApplies);
}

- (void) testTheTestThatIsnt_2
{
    NSString *vendorString = CR_DataProtectionConsentTestsMalformed90CharsVendorString;
    [self.userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual([consent consentGiven], NO);
    XCTAssertEqualObjects(self.defaultConsentString, consent.consentString);
    XCTAssertEqual([consent gdprApplies], self.defaultGdprApplies);
}

- (void)testGetUsPrivacyIABContent
{
    [self.userDefaults setObject:CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString
                          forKey:CR_CCPAIabConsentStringKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    NSString *actualUspIab = consent.usPrivacyIabConsentString;
    XCTAssertEqualObjects(actualUspIab, CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)testGetUsPrivacyCriteoStateUnset
{
    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_CCPACriteoStateUnset);
}

- (void)testGetUsPrivacyCriteoStateOptIn
{
    [self.userDefaults setInteger:CR_CCPACriteoStateOptIn
                           forKey:CR_CCPAConsentCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_CCPACriteoStateOptIn);
}

- (void)testGetUsPrivacyCriteoStateOptOut
{
    [self.userDefaults setInteger:CR_CCPACriteoStateOptOut
                           forKey:CR_CCPAConsentCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_CCPACriteoStateOptOut);
}

- (void)testSetUsPrivacyCriteoStateOptOut
{
    self.consent1.usPrivacyCriteoState = CR_CCPACriteoStateOptOut;

    XCTAssertEqual(self.consent2.usPrivacyCriteoState, CR_CCPACriteoStateOptOut);
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
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateOptIn, nil, YES);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateOptOut, nil, NO);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, nil, YES);

    // CCPA Criteo State with IAB Consent empty.
    CR_AssertShouldSendEvent(@"", CR_CCPACriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"", CR_CCPACriteoStateOptOut, nil, NO);

    // All case for Mopub Consent only
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, @"", YES);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, @"random string", YES);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, @"EXPLICIT_YES", YES);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, @"UNKNOWN", YES);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, @"EXPLICIT_NO", NO);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, @"POTENTIAL_WHITELIST", NO);
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateUnset, @"DNT", NO);

    // Not-empty IAB consent string takes over the criteo state.
    CR_AssertShouldSendEvent(@"random string", CR_CCPACriteoStateOptIn, nil, YES);
    CR_AssertShouldSendEvent(@"random string", CR_CCPACriteoStateOptOut, nil, YES);

    // Opt-in IAB consent strings including lowercases.
    CR_AssertShouldSendEvent(@"1---", CR_CCPACriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1YNY", CR_CCPACriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1yny", CR_CCPACriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1Ynn", CR_CCPACriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1Yn-", CR_CCPACriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1-n-", CR_CCPACriteoStateUnset, nil, YES);

    // Opt-in CCPA IAB Consent string takes over CriteoState.
    CR_AssertShouldSendEvent(@"1---", CR_CCPACriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1YNY", CR_CCPACriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1YNN", CR_CCPACriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1Yn-", CR_CCPACriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1-n-", CR_CCPACriteoStateOptOut, nil, YES);

    // Opt-out CCPA IAB Consent string.
    CR_AssertShouldSendEvent(@"1yyy", CR_CCPACriteoStateUnset, nil, NO);
    CR_AssertShouldSendEvent(@"1yyn", CR_CCPACriteoStateUnset, nil, NO);

    // Opt-out CCPA IAB Consent string takes over CCPA CriteoState.
    CR_AssertShouldSendEvent(@"1YYY", CR_CCPACriteoStateOptIn, nil, NO);
    CR_AssertShouldSendEvent(@"1YYN", CR_CCPACriteoStateOptIn, nil, NO);

    // Opt-out Mopub Consent takes over CCPA Consent.
    CR_AssertShouldSendEvent(nil, CR_CCPACriteoStateOptIn, @"EXPLICIT_NO", NO);
    CR_AssertShouldSendEvent(@"1YNN", CR_CCPACriteoStateUnset, @"EXPLICIT_NO", NO);
}

#pragma mark Private for ShouldSendAppEvent

- (void)_checkShouldSendAppEvent:(BOOL)shouldSendAppEvent
        withUsPrivacyCriteoState:(CR_CCPACriteoState)usPrivacyCriteoState
                iabConsentString:(NSString *)iabConsentString
                    mopubConsent:(NSString *)mopubConsent
                          atLine:(NSUInteger)lineNumber {
    if (iabConsentString) {
        [self.userDefaults setObject:iabConsentString
                              forKey:CR_CCPAIabConsentStringKey];
    }
    [self.userDefaults setInteger:usPrivacyCriteoState
                           forKey:CR_CCPAConsentCriteoStateKey];

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

    [self.userDefaults removeObjectForKey:CR_CCPAConsentCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_CCPAIabConsentStringKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentMopubConsentKey];
}

@end
