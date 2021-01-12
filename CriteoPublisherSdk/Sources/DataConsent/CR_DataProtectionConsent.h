//
//  CR_DataProtectionConsent.h
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

#import <Foundation/Foundation.h>
#import "CR_Ccpa.h"

@class CR_Gdpr;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const CR_DataProtectionConsentMopubConsentKey;
FOUNDATION_EXTERN NSString *const CR_DataProtectionConsentGivenKey;

/**
 Aggregate logics regarding the privacy of the user.

 e.g GDPR, CCPA, Mopub consent, Criteo consent
 */
@interface CR_DataProtectionConsent : NSObject

/**
 Object that handle all the GDPR logic.
 */
@property(strong, nonatomic, readonly) CR_Gdpr *gdpr;

/**
 * Nullable ATTrackingManagerAuthorizationStatus
 *
 * Device before iOS 14 returns nil
 */
@property(readonly, nonatomic, nullable) NSNumber *trackingAuthorizationStatus;

/**
 Store dedicated consent for mopub.
 Spec: https://go.crto.in/publisher-sdk-gdpr-mopub-cmp
 CDB: https://go.crto.in/publisher-sdk-cdb-mopub-consent
 */
@property(nonatomic, copy) NSString *mopubConsent;

/**
 Send events if the user didn't opt out from the Us Privacy or from MoPub.
 US Privacy: https://go.crto.in/publisher-sdk-ccpa
 Mopub:      https://go.crto.in/publisher-sdk-mopub-consent
 */
@property(nonatomic, assign, readonly) BOOL shouldSendAppEvent;

#pragma mark CCPA

@property(nonatomic, copy, readonly, nullable) NSString *usPrivacyIabConsentString;
@property(nonatomic, assign) CR_CcpaCriteoState usPrivacyCriteoState;

#pragma mark - Criteo

/**
 * Provides if backend assume we have consent from provided data above, Gdpr and others
 * Information is persisted in userDefaults
 */
@property(nonatomic, assign, getter=isConsentGiven) BOOL consentGiven;

#pragma mark - Lifecycle

- (instancetype)init;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
