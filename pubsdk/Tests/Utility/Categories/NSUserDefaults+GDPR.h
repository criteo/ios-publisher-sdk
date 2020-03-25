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
- (void)setGdprTcf1_1DefaultConsentString;
- (void)setGdprTcf1_1ConsentString:(NSString *)consentString;
- (void)setGdprTcf2_0DefaultConsentString;
- (void)setGdprTcf2_0ConsentString:(NSString *)consentString;
- (void)setGdprTcf1_1GdprApplies:(BOOL)gdprApplies;
- (void)setGdprTcf2_0GdprApplies:(BOOL)gdprApplies;
- (void)setGdprTcf1_1DefaultVendorConsents;
- (void)setGdprTcf1_1VendorConsents:(NSString *)vendorConsents;
- (void)setGdprTcf2_0DefaultVendorConsents;
- (void)setGdprTcf2_0VendorConsents:(NSString *)vendorConsents;

@end

NS_ASSUME_NONNULL_END
