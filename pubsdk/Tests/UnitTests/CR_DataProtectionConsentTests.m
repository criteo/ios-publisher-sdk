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

@interface CR_DataProtectionConsentTests : XCTestCase

@end

@implementation CR_DataProtectionConsentTests

- (void) setUp {
}

- (void) tearDown {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"IABConsent_SubjectToGDPR"];
        [userDefaults setObject:nil forKey:@"IABConsent_ConsentString"];
        [userDefaults setObject:nil forKey:@"IABConsent_ParsedVendorConsents"];
}

- (void) testGdprGet {
    NSNumber *gdprApplies = @(1);
    NSString *consentString = @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA";
    //Criteo is at 91
    NSString *vendorString = @"0000000000000010000000000000000000000100000000000000000000000000000000000000000000000000001";

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gdprApplies forKey:@"IABConsent_SubjectToGDPR"];
    [userDefaults setObject:consentString forKey:@"IABConsent_ConsentString"];
    [userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *gdpr = [[CR_DataProtectionConsent alloc] init];
    XCTAssertEqual([gdpr consentGiven], YES);
    XCTAssertTrue([consentString isEqualToString:[gdpr consentString]]);
    XCTAssertEqual([gdpr gdprApplies], (BOOL)gdprApplies.integerValue);
}

- (void) testGdprGetCriteoNotApprovedVendor {
    NSNumber *gdprApplies = @(1);
    NSString *consentString = @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA";
    //Criteo is at 91 but set to 0
    NSString *vendorString = @"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gdprApplies forKey:@"IABConsent_SubjectToGDPR"];
    [userDefaults setObject:consentString forKey:@"IABConsent_ConsentString"];
    [userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *gdpr = [[CR_DataProtectionConsent alloc] init];
    XCTAssertEqual([gdpr consentGiven], NO);
    XCTAssertTrue([consentString isEqualToString:[gdpr consentString]]);
    XCTAssertEqual([gdpr gdprApplies], (BOOL)gdprApplies.integerValue);
}

- (void) testTheTestThatIsnt {
    NSNumber *gdprApplies = @(1);
    NSString *consentString = @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA";
    //Criteo is at 91 but the vendor string is only 81 long
    NSString *vendorString = @"000000000000000000000000000000000000000000000000000000000000000000000000000000000";

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gdprApplies forKey:@"IABConsent_SubjectToGDPR"];
    [userDefaults setObject:consentString forKey:@"IABConsent_ConsentString"];
    [userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *gdpr = [[CR_DataProtectionConsent alloc] init];
    XCTAssertEqual([gdpr consentGiven], NO);
    XCTAssertTrue([consentString isEqualToString:[gdpr consentString]]);
    XCTAssertEqual([gdpr gdprApplies], (BOOL)gdprApplies.integerValue);
}

- (void) testTheTestThatIsnt_2 {
    NSNumber *gdprApplies = @(1);
    NSString *consentString = @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA";
    //Criteo is at 91 but the vendor string is only 90 long
    NSString *vendorString = @"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gdprApplies forKey:@"IABConsent_SubjectToGDPR"];
    [userDefaults setObject:consentString forKey:@"IABConsent_ConsentString"];
    [userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];

    CR_DataProtectionConsent *gdpr = [[CR_DataProtectionConsent alloc] init];
    XCTAssertEqual([gdpr consentGiven], NO);
    XCTAssertTrue([consentString isEqualToString:[gdpr consentString]]);
    XCTAssertEqual([gdpr gdprApplies], (BOOL)gdprApplies.integerValue);
}

@end
