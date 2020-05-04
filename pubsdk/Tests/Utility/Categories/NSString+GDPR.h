//
//  NSString+GDPRVendorConsent.h
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (GDPR)

#pragma mark UserDefaults

@property (copy, nonatomic, class, readonly) NSString *gdprConsentStringUserDefaultsKeyTcf1_1;
@property (copy, nonatomic, class, readonly) NSString *gdprConsentStringUserDefaultsKeyTcf2_0;
@property (copy, nonatomic, class, readonly) NSString *gdprVendorConsentsUserDefaultsKeyTcf1_1;
@property (copy, nonatomic, class, readonly) NSString *gdprVendorConsentsUserDefaultsKeyTcf2_0;
@property (copy, nonatomic, class, readonly) NSString *gdprAppliesUserDefaultsKeyTcf1_1;
@property (copy, nonatomic, class, readonly) NSString *gdprAppliesUserDefaultsKeyTcf2_0;

#pragma mark ConsentString

@property (copy, nonatomic, class, readonly) NSString *gdprConsentStringForTcf1_1;
@property (copy, nonatomic, class, readonly) NSString *gdprConsentStringDeniedForTcf1_1;
@property (copy, nonatomic, class, readonly) NSString *gdprConsentStringForTcf2_0;
@property (copy, nonatomic, class, readonly) NSString *gdprConsentStringDeniedForTcf2_0;

@end

NS_ASSUME_NONNULL_END
