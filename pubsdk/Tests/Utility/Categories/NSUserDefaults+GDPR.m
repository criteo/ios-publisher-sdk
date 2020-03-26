//
//  NSUserDefaults+GDPR.m
//  pubsdk
//
//  Created by Romain Lofaso on 3/25/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "NSUserDefaults+GDPR.h"
#import "NSString+GDPR.h"


@implementation NSUserDefaults (GDPR)

- (void)clearGdpr {
    [self removeObjectForKey:NSString.gdprAppliesUserDefaultsKeyTcf2_0];
    [self removeObjectForKey:NSString.gdprConsentStringUserDefaultsKeyTcf2_0];
    [self removeObjectForKey:NSString.gdprVendorConsentsUserDefaultsKeyTcf2_0];
    [self removeObjectForKey:NSString.gdprAppliesUserDefaultsKeyTcf1_1];
    [self removeObjectForKey:NSString.gdprConsentStringUserDefaultsKeyTcf1_1];
    [self removeObjectForKey:NSString.gdprVendorConsentsUserDefaultsKeyTcf1_1];
}

- (void)setGdprTcf1_1DefaultConsentString {
    [self setGdprTcf1_1ConsentString:NSString.gdprConsentStringForTcf1_1];
}

- (void)setGdprTcf1_1ConsentString:(NSString *)consentString {
    [self setObject:consentString
             forKey:NSString.gdprConsentStringUserDefaultsKeyTcf1_1];
}

- (void)setGdprTcf2_0DefaultConsentString {
    [self setGdprTcf2_0ConsentString:NSString.gdprConsentStringForTcf2_0];
}

- (void)setGdprTcf2_0ConsentString:(NSString *)consentString {
    [self setObject:consentString
             forKey:NSString.gdprConsentStringUserDefaultsKeyTcf2_0];
}

- (void)setGdprTcf1_1GdprApplies:(BOOL)gdprApplies {
    [self setBool:gdprApplies
           forKey:NSString.gdprAppliesUserDefaultsKeyTcf1_1];
}

- (void)setGdprTcf2_0GdprApplies:(BOOL)gdprApplies {
    [self setBool:gdprApplies
           forKey:NSString.gdprAppliesUserDefaultsKeyTcf2_0];
}

- (void)setGdprTcf1_1DefaultVendorConsents {
    [self setGdprTcf1_1VendorConsents:NSString.gdprOnlyCriteoConsentAllowedString];
}

- (void)setGdprTcf1_1VendorConsents:(NSString *)vendorConsents {
    [self setObject:vendorConsents
             forKey:NSString.gdprVendorConsentsUserDefaultsKeyTcf1_1];
}

- (void)setGdprTcf2_0DefaultVendorConsents {
    [self setGdprTcf2_0VendorConsents:NSString.gdprOnlyCriteoConsentAllowedString];
}

- (void)setGdprTcf2_0VendorConsents:(NSString *)vendorConsents {
    [self setObject:vendorConsents
             forKey:NSString.gdprVendorConsentsUserDefaultsKeyTcf2_0];
}

@end
