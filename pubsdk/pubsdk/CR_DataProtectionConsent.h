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

#pragma mark CCPA

@property (nonatomic, copy, readonly, nullable) NSString *usPrivacyIabConsentString;

@end

NS_ASSUME_NONNULL_END
