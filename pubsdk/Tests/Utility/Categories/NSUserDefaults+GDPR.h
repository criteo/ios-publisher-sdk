//
//  NSUserDefaults+GDPR.h
//  pubsdk
//
//  Created by Romain Lofaso on 3/25/20.
//  Copyright © 2020 Criteo. All rights reserved.
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

- (void)setGdprTcf1_1GdprApplies:(BOOL)gdprApplies;
- (void)setGdprTcf2_0GdprApplies:(BOOL)gdprApplies;

@end

NS_ASSUME_NONNULL_END
