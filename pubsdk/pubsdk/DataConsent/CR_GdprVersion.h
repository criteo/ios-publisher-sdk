//
//  CR_GdprVersion.h
//  pubsdk
//
//  Created by Romain Lofaso on 3/24/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_Gdpr.h"

NS_ASSUME_NONNULL_BEGIN

// TCF v2.0 keys
// Specifications: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#what-does-the-gdprapplies-value-mean
extern NSString * const CR_GdprAppliesForTcf2_0Key;
extern NSString * const CR_GdprConsentStringForTcf2_0Key;

// TCF v1.1 keys
// Specifications: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#cmp-internal-structure-defined-api-
extern NSString * const CR_GdprSubjectToGdprForTcf1_1Key;
extern NSString * const CR_GdprConsentStringForTcf1_1Key;

@protocol CR_GdprVersion <NSObject>

@required

@property (assign, nonatomic, readonly, getter=isValid) BOOL valid;
@property (assign, nonatomic, readonly) CR_GdprTcfVersion tcfVersion;
@property (copy, nonatomic, readonly, nullable) NSString *consentString;
/**
 @return a boxed boolean that can be nil if the value doesn't exist or cannot be converted to a NSNumber.
 */
@property (strong, nonatomic, readonly, nullable) NSNumber *applies;

@end

@interface CR_GdprVersionWithKeys : NSObject <CR_GdprVersion>

+ (instancetype)gdprTcf1_1WithUserDefaults:(NSUserDefaults *)userDefaults;
+ (instancetype)gdprTcf2_0WithUserDefaults:(NSUserDefaults *)userDefaults;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConsentStringKey:(NSString *)constantStringKey
                              appliesKey:(NSString *)appliesKey
                              tcfVersion:(CR_GdprTcfVersion)tcfVersion
                            userDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

@interface CR_NoGdpr : NSObject <CR_GdprVersion>

@end

NS_ASSUME_NONNULL_END
