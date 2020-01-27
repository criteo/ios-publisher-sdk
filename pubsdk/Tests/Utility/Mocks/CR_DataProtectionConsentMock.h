//
//  CR_DataProtectionConsentMock.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/11/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_DataProtectionConsent.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const CR_DataProtectionConsentMockDefaultConsentString;
FOUNDATION_EXTERN NSString * const CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString;

@interface CR_DataProtectionConsentMock : CR_DataProtectionConsent

@property (nonatomic, copy, nullable) NSString *consentString_mock;
@property (nonatomic, assign) BOOL gdprApplies_mock;
@property (nonatomic, assign) BOOL consentGiven_mock;
@property (nonatomic, assign) BOOL isAdTrackingEnabled_mock;
@property (nonatomic, copy, nullable) NSString *usPrivacyIabConsentString_mock;

@end

NS_ASSUME_NONNULL_END
