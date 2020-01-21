//
//  CR_DataProtectionConsent.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const CR_DataProtectionConsentUsPrivacyIabConsentStringKey;
FOUNDATION_EXTERN NSString * const CR_DataProtectionConsentUsPrivacyCriteoStateKey;
FOUNDATION_EXTERN NSString * const CR_DataProtectionConsentMopubConsentKey;

/**
 The US privacy consent within a custom Criteo format (not iAB).
 */
typedef NS_ENUM(NSInteger, CR_UsPrivacyCriteoState) {
    CR_UsPrivacyCriteoStateUnset = 0,
    CR_UsPrivacyCriteoStateOptOut,
    CR_UsPrivacyCriteoStateOptIn
};

/**
 Load the consent strings from the NSUserDefault.

 Note that, for now, the following code loads at the initialization the strings because
 we consider that the Publishers must init the SDK *after* asking the consent. If the publisher
 asks the consent after, the properties won't be updated.
 */
@interface CR_DataProtectionConsent: NSObject

@property (copy, readonly, nonatomic) NSString *consentString;
@property (readonly, nonatomic) BOOL gdprApplies;
@property (readonly, nonatomic) BOOL consentGiven;
@property (readonly, nonatomic) BOOL isAdTrackingEnabled;

/**
 Store dedicated consent for mopub.
 Spec: https://confluence.criteois.com/display/PUBSDK/GDPR+for+Mopub+CMP
 CDB: https://confluence.criteois.com/display/PUB/CDB+-+Mopub+Consent+support
 */
@property (nonatomic, copy) NSString *mopubConsent;

/**
 Send events if the user didn't opt out from the Us Privacy or from MoPub.
 US Privacy: https://confluence.criteois.com/display/PP/CCPA+Buying+Policy?focusedCommentId=532758801#comment-532758801
 Mopub:        https://confluence.criteois.com/display/PUBSDK/Mopub+consent+on+PubSDK
 */
@property (nonatomic, assign, readonly) BOOL shouldSendAppEvent;

#pragma mark CCPA

@property (nonatomic, copy, readonly, nullable) NSString *usPrivacyIabConsentString;
/* Persist over the lifetime of the object. */
@property (nonatomic, assign) CR_UsPrivacyCriteoState usPrivacyCriteoState;

- (instancetype)init;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
