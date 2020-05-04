//
//  NSUserDefaults+GDPR.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (GDPR)

- (void)clearGdpr;

#pragma mark ConsentString

- (void)setGdprTcf1_1ConsentString:(NSString *)consentString;
- (void)setGdprTcf2_0ConsentString:(NSString *)consentString;

- (void)setGdprTcf1_1DefaultConsentString;
- (void)setGdprTcf2_0DefaultConsentString;

#pragma mark GdprApplies

// For the GDPR applies,
// We usually set "truthy" values (e.g @YES, @NO, @1, "0", "true").
// To be agnostic of the type we use NSObjects in parameters.

- (void)setGdprTcf1_1GdprApplies:(nullable NSObject *)gdprApplies;
- (void)setGdprTcf2_0GdprApplies:(nullable NSObject *)gdprApplies;

@end

NS_ASSUME_NONNULL_END
