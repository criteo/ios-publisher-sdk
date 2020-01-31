//
//  Criteo.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef Criteo_h
#define Criteo_h

#import <Foundation/Foundation.h>
#import "CRAdUnit.h"
#import "CRBidResponse.h"

NS_ASSUME_NONNULL_BEGIN
@interface Criteo : NSObject

/* @abstract Use sharedInstance */
- (instancetype) init NS_UNAVAILABLE;
+ (nonnull instancetype) sharedCriteo;

/** @abstract Set a custom opt-out/opt-in with same behaviour as the CCPA (US Privacy). */
- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut;
/** @abstract Set the privacy consent string owned by the Mopub SDK. */
- (void)setMopubConsent:(NSString *)mopubConsent;

- (void) registerCriteoPublisherId:(NSString *) criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit*> *) adUnits;

- (void) setBidsForRequest:(id) request
                withAdUnit:(CRAdUnit *) adUnit;

- (CRBidResponse *)getBidResponseForAdUnit:(CRAdUnit *)adUnit;

@end
NS_ASSUME_NONNULL_END

#endif /* Criteo_h */
