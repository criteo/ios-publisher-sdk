//
//  CR_Gdpr1_1.m
//  CriteoPublisherSdk
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

#import "CR_GdprVersion.h"
#import "NSString+Tcf.h"

// Vendor ID is declared at IAB and can be found in the vendor list:
// https://vendorlist.consensu.org/v2/vendor-list.json
NSUInteger const CR_CriteoTcfVendorID = 91;
NSString *const CR_GdprAppliesForTcf2_0Key = @"IABTCF_gdprApplies";
NSString *const CR_GdprConsentStringForTcf2_0Key = @"IABTCF_TCString";
NSString *const CR_GdprPurposeConsentsForTcf2_0Key = @"IABTCF_PurposeConsents";
NSString *const CR_GdprPublisherRestrictionsFormatForTcf2_0Key = @"IABTCF_PublisherRestrictions%d";
NSString *const CR_GdprVendorConsentsForTcf2_0Key = @"IABTCF_VendorConsents";
NSString *const CR_GdprLegitimateInterestsForTcf2_0Key = @"IABTCF_VendorLegitimateInterests";

NSString *const CR_GdprSubjectToGdprForTcf1_1Key = @"IABConsent_SubjectToGDPR";
NSString *const CR_GdprConsentStringForTcf1_1Key = @"IABConsent_ConsentString";

@interface CR_GdprVersionWithKeys ()

@property(copy, nonatomic, readonly) NSString *consentStringKey;
@property(copy, nonatomic, readonly) NSString *purposeConsentsKey;
@property(copy, nonatomic, readonly) NSString *publisherRestrictionsKeyFormat;
@property(copy, nonatomic, readonly) NSString *vendorConsentsKey;
@property(copy, nonatomic, readonly) NSString *vendorLegitimateInterestsKey;
@property(copy, nonatomic, readonly) NSString *appliesKey;
@property(strong, nonatomic, readonly) NSUserDefaults *userDefaults;

@property(copy, nonatomic, readonly) NSNumber *appliesObject;

@end

@implementation CR_GdprVersionWithKeys

@synthesize tcfVersion = _tcfVersion;

+ (instancetype)gdprTcf1_1WithUserDefaults:(NSUserDefaults *)userDefaults {
  return [[self.class alloc] initWithConsentStringKey:CR_GdprConsentStringForTcf1_1Key
                                   purposeConsentsKey:nil
                       publisherRestrictionsKeyFormat:nil
                                    vendorConsentsKey:nil
                         vendorLegitimateInterestsKey:nil
                                           appliesKey:CR_GdprSubjectToGdprForTcf1_1Key
                                           tcfVersion:CR_GdprTcfVersion1_1
                                         userDefaults:userDefaults];
}

+ (instancetype)gdprTcf2_0WithUserDefaults:(NSUserDefaults *)userDefaults {
  return [[self.class alloc] initWithConsentStringKey:CR_GdprConsentStringForTcf2_0Key
                                   purposeConsentsKey:CR_GdprPurposeConsentsForTcf2_0Key
                       publisherRestrictionsKeyFormat:CR_GdprPublisherRestrictionsFormatForTcf2_0Key
                                    vendorConsentsKey:CR_GdprVendorConsentsForTcf2_0Key
                         vendorLegitimateInterestsKey:CR_GdprLegitimateInterestsForTcf2_0Key
                                           appliesKey:CR_GdprAppliesForTcf2_0Key
                                           tcfVersion:CR_GdprTcfVersion2_0
                                         userDefaults:userDefaults];
}

#pragma mark - Life cycle

- (instancetype)initWithConsentStringKey:(NSString *)consentStringKey
                      purposeConsentsKey:(NSString *)purposeConsentsKey
          publisherRestrictionsKeyFormat:(NSString *)publisherRestrictionsKeyFormat
                       vendorConsentsKey:(NSString *)vendorConsentsKey
            vendorLegitimateInterestsKey:(NSString *)vendorLegitimateInterestsKey
                              appliesKey:(NSString *)appliesKey
                              tcfVersion:(CR_GdprTcfVersion)tcfVersion
                            userDefaults:(NSUserDefaults *)userDefaults {
  if (self = [super init]) {
    _consentStringKey = [consentStringKey copy];
    _purposeConsentsKey = [purposeConsentsKey copy];
    _publisherRestrictionsKeyFormat = [publisherRestrictionsKeyFormat copy];
    _vendorConsentsKey = [vendorConsentsKey copy];
    _vendorLegitimateInterestsKey = [vendorLegitimateInterestsKey copy];
    _appliesKey = [appliesKey copy];
    _userDefaults = userDefaults;
    _tcfVersion = tcfVersion;
  }
  return self;
}

#pragma mark - Properties

- (BOOL)isValid {
  return (self.consentString != nil) || (self.applies != nil);
}

- (NSString *)consentString {
  return [self.userDefaults stringForKey:self.consentStringKey];
}

- (NSNumber *)applies {
  id object = [self.userDefaults objectForKey:self.appliesKey];
  if (object == nil) {
    return nil;
  }
  BOOL applies = [self.userDefaults boolForKey:self.appliesKey];
  return @(applies);
}

- (BOOL)isConsentGivenForPurpose:(NSUInteger)id {
  if (self.purposeConsentsKey == nil) {
    return YES;
  }
  NSString *purposeConsents = [self.userDefaults stringForKey:self.purposeConsentsKey];
  NSNumber *purposeConsent = [purposeConsents cr_tcfBinaryStringValueAtIndex:id];
  return purposeConsent != nil ? purposeConsent.boolValue : YES;
}

- (CR_GdprTcfPublisherRestrictionType)publisherRestrictionsForPurpose:(NSUInteger)id {
  if (self.publisherRestrictionsKeyFormat == nil) {
    return CR_GdprTcfPublisherRestrictionTypeNone;
  }
  NSString *purposeRestrictionKey =
      [NSString stringWithFormat:self.publisherRestrictionsKeyFormat, id];
  NSString *restrictionsForPurpose = [self.userDefaults stringForKey:purposeRestrictionKey];
  if (restrictionsForPurpose == nil || CR_CriteoTcfVendorID > restrictionsForPurpose.length) {
    return CR_GdprTcfPublisherRestrictionTypeNone;
  }
  unichar criteoRestrictionChar =
      [restrictionsForPurpose characterAtIndex:CR_CriteoTcfVendorID - 1];
  return [self.class publisherRestrictionTypeFromChar:criteoRestrictionChar];
}

+ (CR_GdprTcfPublisherRestrictionType)publisherRestrictionTypeFromChar:(unichar)restrictionChar {
  switch (restrictionChar) {
    case '0':
      return CR_GdprTcfPublisherRestrictionTypeNotAllowed;
    case '1':
      return CR_GdprTcfPublisherRestrictionTypeRequireConsent;
    case '2':
      return CR_GdprTcfPublisherRestrictionTypeRequireLegitimateInterest;
    default:
      return CR_GdprTcfPublisherRestrictionTypeNone;
  }
}

- (BOOL)isVendorConsentGiven {
  if (self.vendorConsentsKey == nil) {
    return YES;
  }
  NSString *vendorConsents = [self.userDefaults stringForKey:self.vendorConsentsKey];
  NSNumber *vendorConsent = [vendorConsents cr_tcfBinaryStringValueAtIndex:CR_CriteoTcfVendorID];
  return vendorConsent != nil ? vendorConsent.boolValue : YES;
}

- (BOOL)hasVendorLegitimateInterest {
  if (self.vendorLegitimateInterestsKey == nil) {
    return YES;
  }
  NSString *legitimateInterests =
      [self.userDefaults stringForKey:self.vendorLegitimateInterestsKey];
  NSNumber *legitimateInterest =
      [legitimateInterests cr_tcfBinaryStringValueAtIndex:CR_CriteoTcfVendorID];
  return legitimateInterest != nil ? legitimateInterest.boolValue : YES;
}

@end

@implementation CR_NoGdpr

- (BOOL)isValid {
  return YES;
}

- (CR_GdprTcfVersion)tcfVersion {
  return CR_GdprTcfVersionUnknown;
}

- (NSString *)consentString {
  return nil;
}

- (NSNumber *)applies {
  return nil;
}

- (BOOL)isConsentGivenForPurpose:(NSUInteger)id {
  return YES;
}

- (CR_GdprTcfPublisherRestrictionType)publisherRestrictionsForPurpose:(NSUInteger)id1 {
  return CR_GdprTcfPublisherRestrictionTypeNone;
}

- (BOOL)isVendorConsentGiven {
  return YES;
}

- (BOOL)hasVendorLegitimateInterest {
  return YES;
}

@end
