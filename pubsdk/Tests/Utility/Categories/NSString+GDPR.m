//
//  NSString+GDPRVendorConsent.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/21/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "NSString+GDPR.h"

const NSUInteger NSStringGdprCriteoIdentifierInVendorList = 91;

@implementation NSString (GDPR)

#pragma mark - UserDefaults

+ (NSString *)gdprConsentStringUserDefaultsKeyTcf1_1 {
    return @"IABConsent_ConsentString";
}

+ (NSString *)gdprConsentStringUserDefaultsKeyTcf2_0 {
    return @"IABTCF_TCString";
}

+ (NSString *)gdprVendorConsentsUserDefaultsKeyTcf1_1 {
    return @"IABConsent_ParsedVendorConsents";
}

+ (NSString *)gdprVendorConsentsUserDefaultsKeyTcf2_0 {
    return @"IABTCF_VendorConsents";
}

+ (NSString *)gdprAppliesUserDefaultsKeyTcf1_1 {
    return @"IABConsent_SubjectToGDPR";
}

+ (NSString *)gdprAppliesUserDefaultsKeyTcf2_0 {
    return @"IABTCF_gdprApplies";
}

#pragma mark - ConsentString

+ (NSString *)gdprConsentStringForTcf1_1 {
    return @"blabla";
}

+ (NSString *)gdprConsentStringForTcf2_0 {
    return self.gdprConsentStringForTcf1_1;
}

@end
