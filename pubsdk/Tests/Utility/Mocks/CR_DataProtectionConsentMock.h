//
//  CR_DataProtectionConsentMock.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_DataProtectionConsent.h"

@class CR_GdprMock;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CR_DataProtectionConsentMockDefaultConsentString;
extern NSString * const CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString;

@interface CR_DataProtectionConsentMock : CR_DataProtectionConsent

@property (strong, nonatomic) CR_GdprMock *gdprMock;

@property (nonatomic, assign) BOOL isAdTrackingEnabled_mock;
@property (nonatomic, copy, nullable) NSString *usPrivacyIabConsentString_mock;

@end

NS_ASSUME_NONNULL_END
