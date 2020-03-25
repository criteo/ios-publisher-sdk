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

#pragma mark - VendorConsent

+ (NSString *)gdprOnlyCriteoConsentAllowedString {
    NSRange range = (NSRange) { NSStringGdprCriteoIdentifierInVendorList - 1, 1 };
    return [self.gdprAllVendorConsentDeniedString stringByReplacingCharactersInRange:range
                                                                          withString:@"1"];
}

+ (NSString *)gdprOnlyCriteoConsentDeniedString {
    NSRange range = (NSRange) { NSStringGdprCriteoIdentifierInVendorList - 1, 1 };
    return [self.gdprAllVendorConsentAllowedString stringByReplacingCharactersInRange:range
                                                                          withString:@"0"];
}

+ (NSString *)gdprAllVendorConsentAllowedString {
    return [@"" stringByPaddingToLength:NSStringGdprCriteoIdentifierInVendorList
                             withString:@"1"
                        startingAtIndex:0];
}

+ (NSString *)gdprAllVendorConsentDeniedString {
    return [@"" stringByPaddingToLength:NSStringGdprCriteoIdentifierInVendorList
                             withString:@"0"
                        startingAtIndex:0];
}

+ (NSString *)gdprVendorConsentShortString {
    return [@"" stringByPaddingToLength:NSStringGdprCriteoIdentifierInVendorList / 2
                             withString:@"1"
                        startingAtIndex:0];
}

#pragma mark - ConsentString

+ (NSString *)gdprConsentStringForTcf1_1 {
    return @"blabla";
}

+ (NSString *)gdprConsentStringForTcf2_0 {
    return self.gdprConsentStringForTcf1_1;
}

@end
