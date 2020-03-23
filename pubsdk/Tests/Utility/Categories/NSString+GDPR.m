//
//  NSString+GDPRVendorConsent.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/21/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "NSString+GDPR.h"
#import "CR_Gdpr.h"

@implementation NSString (GDPR)

#pragma mark - Keys

+ (NSString *)gdprConsentKey {
    return @"gdprConsent";
}

+ (NSString *)gdprAppliesKey {
    return @"gdprApplies";
}

+ (NSString *)gdprVersionKey {
    return @"version";
}

+ (NSString *)gdprConsentGivenKey {
    return @"consentGiven";
}

+ (NSString *)gdprConsentDataKey {
    return @"consentData";
}

#pragma mark - VendorConsent

+ (NSString *)gdprOnlyCriteoConsentAllowedString {
    NSRange range = (NSRange) { CR_GDPRConsentCriteoIdentifierInVendorList - 1, 1 };
    return [self.gdprAllVendorConsentDeniedString stringByReplacingCharactersInRange:range
                                                                          withString:@"1"];
}

+ (NSString *)gdprOnlyCriteoConsentDeniedString {
    NSRange range = (NSRange) { CR_GDPRConsentCriteoIdentifierInVendorList - 1, 1 };
    return [self.gdprAllVendorConsentAllowedString stringByReplacingCharactersInRange:range
                                                                          withString:@"0"];
}

+ (NSString *)gdprAllVendorConsentAllowedString {
    return [@"" stringByPaddingToLength:CR_GDPRConsentCriteoIdentifierInVendorList
                             withString:@"1"
                        startingAtIndex:0];
}

+ (NSString *)gdprAllVendorConsentDeniedString {
    return [@"" stringByPaddingToLength:CR_GDPRConsentCriteoIdentifierInVendorList
                             withString:@"0"
                        startingAtIndex:0];
}

+ (NSString *)gdprVendorConsentShortString {
    return [@"" stringByPaddingToLength:CR_GDPRConsentCriteoIdentifierInVendorList / 2
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
