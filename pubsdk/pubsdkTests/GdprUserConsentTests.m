//
//  GdprUserConsentTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "../pubsdk/GdprUserConsent.h"

@interface GdprUserConsentTests : XCTestCase

@end

@implementation GdprUserConsentTests

- (void) testGdprGet {
    NSNumber *gdprApplies = @(1);
    NSString *consentString = @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA";
    //Criteo is at 91
    NSString *vendorString = @"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gdprApplies forKey:@"IABConsent_SubjectToGDPR"];
    [userDefaults setObject:consentString forKey:@"IABConsent_ConsentString"];
    [userDefaults setObject:vendorString forKey:@"IABConsent_ParsedVendorConsents"];
    
    GdprUserConsent *gdpr = [[GdprUserConsent alloc] init];
    XCTAssertEqual([gdpr consentGiven], YES);
    XCTAssertTrue([consentString isEqualToString:[gdpr consentString]]);
    XCTAssertEqual([gdpr gdprApplies], (BOOL)gdprApplies);
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
    
    GdprUserConsent *gdpr = [[GdprUserConsent alloc] init];
    XCTAssertEqual([gdpr consentGiven], NO);
    XCTAssertTrue([consentString isEqualToString:[gdpr consentString]]);
    XCTAssertEqual([gdpr gdprApplies], (BOOL)gdprApplies);
}


@end
