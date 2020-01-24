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
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
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
                          forKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    NSString *actualUspIab = consent.usPrivacyIabConsentString;
    XCTAssertEqualObjects(actualUspIab, CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)testGetUsPrivacyCriteoStateUnset
{
    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_UsPrivacyCriteoStateUnset);
}

- (void)testGetUsPrivacyCriteoStateOptIn
{
    [self.userDefaults setInteger:CR_UsPrivacyCriteoStateOptIn
                           forKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_UsPrivacyCriteoStateOptIn);
}

- (void)testGetUsPrivacyCriteoStateOptOut
{
    [self.userDefaults setInteger:CR_UsPrivacyCriteoStateOptOut
                           forKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    XCTAssertEqual(consent.usPrivacyCriteoState, CR_UsPrivacyCriteoStateOptOut);
}

- (void)testSetUsPrivacyCriteoStateOptOut
{
    self.consent1.usPrivacyCriteoState = CR_UsPrivacyCriteoStateOptOut;

    XCTAssertEqual(self.consent2.usPrivacyCriteoState, CR_UsPrivacyCriteoStateOptOut);
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
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateOptIn, nil, YES);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateOptOut, nil, NO);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, nil, YES);

    CR_AssertShouldSendEvent(@"", CR_UsPrivacyCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"", CR_UsPrivacyCriteoStateOptOut, nil, NO);

    // Mopub Consent only
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, @"", YES);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, @"random string", YES);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, @"EXPLICIT_YES", YES);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, @"UNKNOWN", YES);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, @"EXPLICIT_NO", NO);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, @"POTENTIAL_WHITELIST", NO);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, @"DNT", NO);

    // Not-empty consent string takes over the criteo state.
    CR_AssertShouldSendEvent(@"random string", CR_UsPrivacyCriteoStateOptIn, nil, YES);
    CR_AssertShouldSendEvent(@"random string", CR_UsPrivacyCriteoStateOptOut, nil, YES);

    // Opt-in consent strings
    CR_AssertShouldSendEvent(@"1---", CR_UsPrivacyCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1YNY", CR_UsPrivacyCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1YnY", CR_UsPrivacyCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1Ynn", CR_UsPrivacyCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1Yn-", CR_UsPrivacyCriteoStateUnset, nil, YES);
    CR_AssertShouldSendEvent(@"1-n-", CR_UsPrivacyCriteoStateUnset, nil, YES);

    // Opt-in Consent string takes over CriteoState.
    CR_AssertShouldSendEvent(@"1YNY", CR_UsPrivacyCriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1YNN", CR_UsPrivacyCriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1YnY", CR_UsPrivacyCriteoStateOptOut, nil, YES);
    CR_AssertShouldSendEvent(@"1Ynn", CR_UsPrivacyCriteoStateOptOut, nil, YES);

    // Opt-out consent strings including priorities checks
    CR_AssertShouldSendEvent(@"1YYY", CR_UsPrivacyCriteoStateOptIn, nil, NO);
    CR_AssertShouldSendEvent(@"1YYN", CR_UsPrivacyCriteoStateOptIn, nil, NO);
    CR_AssertShouldSendEvent(@"1yyy", CR_UsPrivacyCriteoStateUnset, nil, NO);
    CR_AssertShouldSendEvent(@"1yyn", CR_UsPrivacyCriteoStateUnset, nil, NO);

    // False if Mopub Consent is declined
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateOptIn, @"EXPLICIT_NO", NO);
    CR_AssertShouldSendEvent(@"1Ynn", CR_UsPrivacyCriteoStateUnset, @"EXPLICIT_NO", NO);
}

#pragma mark Private for ShouldSendAppEvent

- (void)_checkShouldSendAppEvent:(BOOL)shouldSendAppEvent
        withUsPrivacyCriteoState:(CR_UsPrivacyCriteoState)usPrivacyCriteoState
                iabConsentString:(NSString *)iabConsentString
                    mopubConsent:(NSString *)mopubConsent
                          atLine:(NSUInteger)lineNumber {
    if (iabConsentString) {
        [self.userDefaults setObject:iabConsentString
                              forKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
    }
    [self.userDefaults setInteger:usPrivacyCriteoState
                           forKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];

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

    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentMopubConsentKey];
}

@end
