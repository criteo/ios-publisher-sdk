//
//  CR_Ccpa.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const CR_CcpaIabConsentStringKey;
FOUNDATION_EXTERN NSString * const CR_CcpaCriteoStateKey;

/** CCPA consent within a custom Criteo format. */
typedef NS_ENUM(NSInteger, CR_CcpaCriteoState) {
    CR_CcpaCriteoStateUnset = 0,
    CR_CcpaCriteoStateOptOut,
    CR_CcpaCriteoStateOptIn
};

/** CCPA is the Privacy Consent Management for the US. */
@interface CR_Ccpa : NSObject

/* Consent string in the IAB format fetched from the User Defaults */
@property (nonatomic, copy, readonly, nullable) NSString *iabConsentString;
/* Consent state in a homemade Criteo format. */
@property (nonatomic, assign) CR_CcpaCriteoState criteoState;
/* YES if the user is opt in according to specified constraints with IAB and Criteo formats */
@property (nonatomic, assign, readonly) BOOL isOptIn;

- (instancetype)init;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
