//
//  CR_GdprVersion.h
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

#import "CR_Gdpr.h"

NS_ASSUME_NONNULL_BEGIN

// TCF v2.0 keys
// Specifications:
// https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#what-does-the-gdprapplies-value-mean
extern NSString *const CR_GdprAppliesForTcf2_0Key;
extern NSString *const CR_GdprConsentStringForTcf2_0Key;

// TCF v1.1 keys
// Specifications:
// https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#cmp-internal-structure-defined-api-
extern NSString *const CR_GdprSubjectToGdprForTcf1_1Key;
extern NSString *const CR_GdprConsentStringForTcf1_1Key;

@protocol CR_GdprVersion <NSObject>

@required

@property(assign, nonatomic, readonly, getter=isValid) BOOL valid;
@property(assign, nonatomic, readonly) CR_GdprTcfVersion tcfVersion;
@property(copy, nonatomic, readonly, nullable) NSString *consentString;

/**
 * A boxed boolean that can be nil if the value doesn't exist or cannot coerces certain ”truthy”
 * values.
 *
 * Like NSUserDefaults API,  ”truthy” values can be "0", "1", 0, 1, "true", "false", true , false,
 * In TCF1, the applies value is a string (e.g "0" or "1").
 * In TCF2, the applies value is a integer.
 * So we manage both case this here.
 */
@property(strong, nonatomic, readonly, nullable) NSNumber *applies;

/**
 * Gives the status of a purpose consent from NSUserDefaults
 * Note: As this is a TCF 2 only feature, it will be true for TCF 1
 *
 * @param id the purpose id
 * @return consent for purpose
 */
- (BOOL)isConsentGivenForPurpose:(NSUInteger)id;

@end

@interface CR_GdprVersionWithKeys : NSObject <CR_GdprVersion>

+ (instancetype)gdprTcf1_1WithUserDefaults:(NSUserDefaults *)userDefaults;
+ (instancetype)gdprTcf2_0WithUserDefaults:(NSUserDefaults *)userDefaults;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConsentStringKey:(NSString *)consentStringKey
                      purposeConsentsKey:(nullable NSString *)purposeConsentsKey
                              appliesKey:(NSString *)appliesKey
                              tcfVersion:(CR_GdprTcfVersion)tcfVersion
                            userDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

@interface CR_NoGdpr : NSObject <CR_GdprVersion>

@end

NS_ASSUME_NONNULL_END
