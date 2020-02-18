//
//  CR_Gdpr.h
//  pubsdk
//
//  Created by Romain Lofaso on 2/18/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// TCF v2.0 keys
// Specifications: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#what-does-the-gdprapplies-value-mean
extern NSString * const CR_GdprAppliesForTcf2_0Key;
extern NSString * const CR_GdprConsentStringForTcf2_0Key;
extern NSString * const CR_GdprVendorConsentsForTcf2_0Key;

// TCF v1.1 keys
// Specifications: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#cmp-internal-structure-defined-api-
extern NSString * const CR_GdprSubjectToGdprForTcf1_1Key;
extern NSString * const CR_GdprConsentStringForTcf1_1Key;
extern NSString * const CR_GdprVendorConsentsForTcf1_1Key;

/**
 Position of Criteo in the VendorList.

 Vendor List: https://vendorlist.consensu.org/vendorlist.json

 What is a Global Vendor List is: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#what-is-the-global-vendor-list
 */
extern const NSUInteger CR_GDPRConsentCriteoIdentifierInVendorList;

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
