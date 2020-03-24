//
//  CR_Gdpr.h
//  pubsdk
//
//  Created by Romain Lofaso on 2/18/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Versions of the Transparency and Consent Framework (TCF).
 */
typedef NS_ENUM(NSInteger, CR_GdprTcfVersion) {
    CR_GdprTcfVersionUnknown = 0,
    CR_GdprTcfVersion1_1,
    CR_GdprTcfVersion2_0,
};

/**
 The IAB implementation of  the European General Data Protection Regulation (GDPR).

 Specification: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework
 */
@interface CR_Gdpr : NSObject

/**
 TCF version that is found in the NSUserDefault.

 If two versions co-exist, we take the highest one.
 */
@property (nonatomic, readonly, assign) CR_GdprTcfVersion tcfVersion;

/**
 String specified by IAB that content all elements regarding the consent
 */
@property (copy, nonatomic, readonly, nullable) NSString *consentString;

/**
 YES if the GDPR is applied on this device.
 */
@property (assign, nonatomic, readonly, getter=isApplied) BOOL applied;

/**
 YES if the consent has been given specifically to Criteo.
 */
@property (assign, nonatomic, readonly) BOOL consentGivenToCriteo;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
