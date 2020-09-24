//
//  NSUserDefaults+GDPR.m
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

#import "NSUserDefaults+GDPR.h"
#import "NSString+GDPR.h"

#define TCF2_PURPOSES_COUNT 10

@implementation NSUserDefaults (GDPR)

- (void)clearGdpr {
  [self removeObjectForKey:NSString.gdprAppliesUserDefaultsKeyTcf2_0];
  [self removeObjectForKey:NSString.gdprConsentStringUserDefaultsKeyTcf2_0];
  [self removeObjectForKey:NSString.gdprAppliesUserDefaultsKeyTcf1_1];
  [self removeObjectForKey:NSString.gdprConsentStringUserDefaultsKeyTcf1_1];
  [self removeObjectForKey:NSString.gdprPurposeConsentsStringForTcf2_0];
  for (int purposeId = 0; purposeId <= TCF2_PURPOSES_COUNT; ++purposeId) {
    NSString *restrictionsKey =
        [NSString stringWithFormat:NSString.gdprPublisherRestrictionsKeyFormatForTcf2_0, purposeId];
    [self removeObjectForKey:restrictionsKey];
  }
  [self removeObjectForKey:NSString.gdprVendorConsentsStringForTcf2_0];
}

- (void)setGdprTcf1_1DefaultConsentString {
  [self setGdprTcf1_1ConsentString:NSString.gdprConsentStringForTcf1_1];
}

- (void)setGdprTcf1_1ConsentString:(NSString *)consentString {
  [self setObject:consentString forKey:NSString.gdprConsentStringUserDefaultsKeyTcf1_1];
}

- (void)setGdprTcf2_0DefaultConsentString {
  [self setGdprTcf2_0ConsentString:NSString.gdprConsentStringForTcf2_0];
}

- (void)setGdprTcf2_0ConsentString:(NSString *)consentString {
  [self setObject:consentString forKey:NSString.gdprConsentStringUserDefaultsKeyTcf2_0];
}

- (void)setGdprTcf1_1GdprApplies:(NSObject *)gdprApplies {
  [self setObject:gdprApplies forKey:NSString.gdprAppliesUserDefaultsKeyTcf1_1];
}

- (void)setGdprTcf2_0GdprApplies:(NSObject *)gdprApplies {
  [self setObject:gdprApplies forKey:NSString.gdprAppliesUserDefaultsKeyTcf2_0];
}

- (void)setGdprTcf2_0PurposeConsents:(nullable NSString *)purposeConsents {
  [self setObject:purposeConsents forKey:NSString.gdprPurposeConsentsStringForTcf2_0];
}

- (void)setGdprTcf2_0PublisherRestrictions:(NSObject *)publisherRestrictions
                                forPurpose:(NSUInteger)id {
  NSString *publisherRestrictionsKey =
      [NSString stringWithFormat:NSString.gdprPublisherRestrictionsKeyFormatForTcf2_0, id];
  [self setObject:publisherRestrictions forKey:publisherRestrictionsKey];
}

- (void)setGdprTcf2_0VendorConsents:(nullable NSString *)vendorConsents {
  [self setObject:vendorConsents forKey:NSString.gdprVendorConsentsStringForTcf2_0];
}

@end
