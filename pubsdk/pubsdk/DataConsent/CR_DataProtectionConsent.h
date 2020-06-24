//
//  CR_DataProtectionConsent.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_Ccpa.h"

@class CR_Gdpr;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const CR_DataProtectionConsentMopubConsentKey;

/**
 Aggregate logics regarding the privacy of the user.

 e.g GDPR, CCPA, Mopub consent, Criteo consent
 */
@interface CR_DataProtectionConsent : NSObject

/**
 Object that handle all the GDPR logic.
 */
@property(strong, nonatomic, readonly) CR_Gdpr *gdpr;

@property(readonly, nonatomic) BOOL isAdTrackingEnabled;

/**
 Store dedicated consent for mopub.
 Spec: https://confluence.criteois.com/display/PUBSDK/GDPR+for+Mopub+CMP
 CDB: https://confluence.criteois.com/display/PUB/CDB+-+Mopub+Consent+support
 */
@property(nonatomic, copy) NSString *mopubConsent;

/**
 Send events if the user didn't opt out from the Us Privacy or from MoPub.
 US Privacy:
 https://confluence.criteois.com/display/PP/CCPA+Buying+Policy?focusedCommentId=532758801#comment-532758801
 Mopub:        https://confluence.criteois.com/display/PUBSDK/Mopub+consent+on+PubSDK
 */
@property(nonatomic, assign, readonly) BOOL shouldSendAppEvent;

#pragma mark CCPA

@property(nonatomic, copy, readonly, nullable) NSString *usPrivacyIabConsentString;
@property(nonatomic, assign) CR_CcpaCriteoState usPrivacyCriteoState;

- (instancetype)init;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
