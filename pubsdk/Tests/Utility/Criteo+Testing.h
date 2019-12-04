//
// Created by Aleksandr Pakhmutov on 26/11/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteo.h"

@class CR_NetworkCaptor;

FOUNDATION_EXPORT NSString *const CriteoTestingPublisherId;
FOUNDATION_EXPORT NSString *const DemoBannerAdUnitId;
FOUNDATION_EXPORT NSString *const DemoInterstitialAdUnitId;

@interface Criteo (Testing)

@property(nonatomic, readonly) CR_NetworkCaptor *testing_networkCaptor;

+ (Criteo *)testing_criteoWithNetworkCaptor;
/**
 Register an intertitial.
*/
- (void)testing_register;
- (void)testing_registerWithAdUnits:(NSArray<CRAdUnit *> *)adUnits;
/**
 Register a banner.
*/
- (void)testing_registerBanner;
/**
 Return YES if all the HTTP calls have finished before a timeout.
 */
- (BOOL)testing_waitForRegisterHTTPResponses;
/**
 Register a banner, wait and assert if the registration fails or after a timeout
 */
- (void)testing_registerBannerAndWaitForHTTPResponses;
/**
 Register an interstitial, wait and assert if the registration fails or after a timeout.
*/
- (void)testing_registerAndWaitForHTTPResponses;
- (void)testing_registerWithAdUnitsAndWaitForHTTPResponse:(NSArray<CRAdUnit *> *)adUnits;

@end
