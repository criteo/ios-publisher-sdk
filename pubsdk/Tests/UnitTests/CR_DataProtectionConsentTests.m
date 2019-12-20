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


#define CR_AssertShouldSendEvent(consentString, usPrivacyCriteoState, shouldSendAppEvent) \
do { \
    [self _checkShouldSendAppEvent:shouldSendAppEvent \
          withUsPrivacyCriteoState:usPrivacyCriteoState \
                  iabConsentString:consentString \
                            atLine:__LINE__]; \
} while (0)

@interface CR_DataProtectionConsentTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, assign) BOOL defaultGdprApplies;
@property (nonatomic, strong) NSString *defaultConsentString;

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
    CR_DataProtectionConsent *consent1 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
    CR_DataProtectionConsent *consent2 = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    consent1.usPrivacyCriteoState = CR_UsPrivacyCriteoStateOptOut;

    XCTAssertEqual(consent2.usPrivacyCriteoState, CR_UsPrivacyCriteoStateOptOut);
}

#pragma mark - ShouldSendAppEvent

- (void)testShouldSendAppEvent {
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateOptIn, YES);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateOptOut, NO);
    CR_AssertShouldSendEvent(nil, CR_UsPrivacyCriteoStateUnset, YES);

    CR_AssertShouldSendEvent(@"", CR_UsPrivacyCriteoStateUnset, YES);
    CR_AssertShouldSendEvent(@"", CR_UsPrivacyCriteoStateOptOut, NO);

    // Not-empty consent string takes over the criteo state.
    CR_AssertShouldSendEvent(@"random string", CR_UsPrivacyCriteoStateOptIn, YES);
    CR_AssertShouldSendEvent(@"random string", CR_UsPrivacyCriteoStateOptOut, YES);

    // Opt-in consent strings
    CR_AssertShouldSendEvent(@"1---", CR_UsPrivacyCriteoStateUnset, YES);
    CR_AssertShouldSendEvent(@"1YNY", CR_UsPrivacyCriteoStateUnset, YES);
    CR_AssertShouldSendEvent(@"1YnY", CR_UsPrivacyCriteoStateUnset, YES);
    CR_AssertShouldSendEvent(@"1Ynn", CR_UsPrivacyCriteoStateUnset, YES);

    // Opt-in Consent string takes over CriteoState.
    CR_AssertShouldSendEvent(@"1YNY", CR_UsPrivacyCriteoStateOptOut, YES);
    CR_AssertShouldSendEvent(@"1YNN", CR_UsPrivacyCriteoStateOptOut, YES);
    CR_AssertShouldSendEvent(@"1YnY", CR_UsPrivacyCriteoStateOptOut, YES);
    CR_AssertShouldSendEvent(@"1Ynn", CR_UsPrivacyCriteoStateOptOut, YES);

    // Opt-out consent strings including priorities checks
    CR_AssertShouldSendEvent(@"1YYY", CR_UsPrivacyCriteoStateOptIn, NO);
    CR_AssertShouldSendEvent(@"1YYN", CR_UsPrivacyCriteoStateOptIn, NO);
    CR_AssertShouldSendEvent(@"1yyy", CR_UsPrivacyCriteoStateUnset, NO);
    CR_AssertShouldSendEvent(@"1yyn", CR_UsPrivacyCriteoStateUnset, NO);
}

#pragma mark Private for ShouldSendAppEvent

- (void)_checkShouldSendAppEvent:(BOOL)shouldSendAppEvent
        withUsPrivacyCriteoState:(CR_UsPrivacyCriteoState)usPrivacyCriteoState
                iabConsentString:(NSString *)iabConsentString
                          atLine:(NSUInteger)lineNumber {
    if (iabConsentString) {
        [self.userDefaults setObject:iabConsentString
                              forKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
    }
    [self.userDefaults setInteger:usPrivacyCriteoState
                           forKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];

    CR_DataProtectionConsent *consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];

    if (consent.shouldSendAppEvent != shouldSendAppEvent) {
        NSString *desc = [[NSString alloc] initWithFormat:@"usPrivacyCriteoState = %ld & iabConsentString = %@ => shouldSendAppEvent %d", (long)usPrivacyCriteoState, iabConsentString, shouldSendAppEvent];
        NSString *file = [[NSString alloc] initWithCString:__FILE__ encoding:NSUTF8StringEncoding];
        [self recordFailureWithDescription:desc
                                    inFile:file
                                    atLine:lineNumber
                                  expected:YES];
    }

    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
}

@end
