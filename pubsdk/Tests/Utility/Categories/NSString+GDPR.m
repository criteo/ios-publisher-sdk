//
//  NSString+GDPRVendorConsent.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
  return @"BOnz814Onz814ABABBFRCP4AAAAFuABAC2A";
}

+ (NSString *)gdprConsentStringDeniedForTcf1_1 {
  return @"BOnz82JOnz82JABABBFRCPgAAAAFuABABAA";
}

+ (NSString *)gdprConsentStringForTcf2_0 {
  return @"COwJDpQOwJDpQIAAAAENAPCgAAAAAAAAAAAAAxQAQAtgAAAA";
}

+ (NSString *)gdprConsentStringDeniedForTcf2_0 {
  return @"COwJDpQOwJDpQIAAAAENAPCgAAAAAAAAAAAAAxQAgAsABiAAAAAA";
}

@end
