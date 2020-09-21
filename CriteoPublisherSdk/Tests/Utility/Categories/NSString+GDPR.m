//
//  NSString+GDPRVendorConsent.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NSString+GDPR.h"

// Vendor ID is declared at IAB and can be found in the vendor list:
// https://vendorlist.consensu.org/v2/vendor-list.json
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

+ (NSString *)gdprPurposeConsentsStringForTcf2_0 {
  return @"IABTCF_PurposeConsents";
}

+ (NSString *)gdprPublisherRestrictionsKeyFormatForTcf2_0 {
  return @"IABTCF_PublisherRestrictions%d";
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
