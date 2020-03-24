//
//  CR_Gdpr.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/18/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_Gdpr.h"

NSString * const CR_GdprAppliesForTcf2_0Key = @"IABTCF_gdprApplies";
NSString * const CR_GdprConsentStringForTcf2_0Key = @"IABTCF_TCString";
NSString * const CR_GdprVendorConsentsForTcf2_0Key = @"IABTCF_VendorConsents";

NSString * const CR_GdprSubjectToGdprForTcf1_1Key = @"IABConsent_SubjectToGDPR";
NSString * const CR_GdprConsentStringForTcf1_1Key = @"IABConsent_ConsentString";
NSString * const CR_GdprVendorConsentsForTcf1_1Key = @"IABConsent_ParsedVendorConsents";

const NSUInteger CR_GDPRConsentCriteoIdentifierInVendorList = 91;

@interface CR_Gdpr ()

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;

@property (nonatomic, copy, readonly) NSString *consentStringV1;
@property (nonatomic, copy, readonly) NSString *consentStringV2;

@property (copy, nonatomic, readonly) NSString *vendorConsentsV1;
@property (copy, nonatomic, readonly) NSString *vendorConsentsV2;


@property (assign, nonatomic, readonly) NSNumber *appliedV1;
@property (assign, nonatomic, readonly) NSNumber *appliedV2;

@property (assign, nonatomic, readonly) BOOL isTcf2_0;
@property (assign, nonatomic, readonly) BOOL isTcf1_1;

@end

@implementation CR_Gdpr

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    if (self = [super init]) {
        _userDefaults = userDefaults;
    }
    return self;
}

#pragma mark - Custom Accessors

- (CR_GdprTcfVersion)tcfVersion {
    if (self.isTcf2_0) {
        return CR_GdprTcfVersion2_0;
    } else if (self.isTcf1_1) {
        return CR_GdprTcfVersion1_1;
    } else {
        return CR_GdprTcfVersionUnknown;
    }
}

- (NSString *)consentString {
    return self.consentStringV2 ?: self.consentStringV1;
}

- (BOOL)isApplied {
    if (self.isTcf2_0) {
        return [self.appliedV2 boolValue];
    } else if (self.isTcf1_1) {
        return [self.userDefaults boolForKey:CR_GdprSubjectToGdprForTcf1_1Key];
    } else {
        return NO;
    }
}

- (BOOL)consentGivenToCriteo {
    NSString *key = (self.tcfVersion == 2) ? CR_GdprVendorConsentsForTcf2_0Key : CR_GdprVendorConsentsForTcf1_1Key;
    NSString *vendorConsents = [self.userDefaults stringForKey:key];
    const NSUInteger criteoId = CR_GDPRConsentCriteoIdentifierInVendorList;
    const NSUInteger criteoIndex = criteoId - 1;
    return  (vendorConsents.length > criteoIndex) &&
            ([vendorConsents characterAtIndex:criteoIndex] == '1');
}

#pragma mark - Private

- (BOOL)isTcf2_0 {
    return  (self.consentStringV2 != nil) ||
            (self.appliedV2 != nil) ||
            (self.vendorConsentsV2 != nil);
}

- (BOOL)isTcf1_1 {
    return  !self.isTcf2_0 &&
            ((self.consentStringV1 != nil) ||
            (self.appliedV1 != nil) ||
            (self.vendorConsentsV1 != nil));
}

- (NSString *)vendorConsentsV2 {
    return [self.userDefaults stringForKey:CR_GdprVendorConsentsForTcf2_0Key];
}

- (NSString *)vendorConsentsV1 {
    return [self.userDefaults stringForKey:CR_GdprVendorConsentsForTcf1_1Key];
}

- (NSNumber *)appliedV2 {
    return [self.userDefaults objectForKey:CR_GdprAppliesForTcf2_0Key];
}

- (NSNumber *)appliedV1 {
    return [self.userDefaults objectForKey:CR_GdprSubjectToGdprForTcf1_1Key];
}

- (NSString *)consentStringV2 {
    return [self.userDefaults stringForKey:CR_GdprConsentStringForTcf2_0Key];
}

- (NSString *)consentStringV1 {
    return [self.userDefaults stringForKey:CR_GdprConsentStringForTcf1_1Key];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<%@: %p, tcfVersion: %ld, isApplied: %d, consentString: %@, consentGivenToCriteo: %d >",
            NSStringFromClass(self.class),
            self,
            (long)self.tcfVersion,
            self.isApplied,
            self.consentString,
            self.consentGivenToCriteo
            ];
}

@end
