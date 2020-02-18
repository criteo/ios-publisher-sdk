//
//  CR_CCPConsent.h
//  pubsdk
//
//  Created by Romain Lofaso on 1/24/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const CR_CCPAIabConsentStringKey;
FOUNDATION_EXTERN NSString * const CR_CCPAConsentCriteoStateKey;

/** CCPA consent within a custom Criteo format. */
typedef NS_ENUM(NSInteger, CR_CCPACriteoState) {
    CR_CCPACriteoStateUnset = 0,
    CR_CCPACriteoStateOptOut,
    CR_CCPACriteoStateOptIn
};

/** CCPA is the Privacy Consent Management for the US. */
@interface CR_CCPAConsent : NSObject

/* Consent string in the IAB format fetched from the User Defaults */
@property (nonatomic, copy, readonly, nullable) NSString *iabConsentString;
/* Consent state in a homemade Criteo format. */
@property (nonatomic, assign) CR_CCPACriteoState criteoState;
/* YES if the user is opt in according to specified constraints with IAB and Criteo formats */
@property (nonatomic, assign, readonly) BOOL isOptIn;

- (instancetype)init;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
