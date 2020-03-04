//
//  CR_ApiHandler.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/6/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CR_ApiHandler_h
#define CR_ApiHandler_h

#import <Foundation/Foundation.h>
#import "CR_NetworkManager.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbResponse.h"
#import "CR_Config.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DeviceInfo.h"
#import "CR_BidFetchTracker.h"
@class CR_ThreadManager;

typedef void (^CR_CdbCompletionHandler)(CR_CdbResponse *cdbResponse, NSError *error);
typedef void (^AHConfigResponse)(NSDictionary *configValues);
typedef void (^AHAppEventsResponse)(NSDictionary *appEventValues, NSDate *receivedAt);

extern NSString * const CR_ApiHandlerAppEventAppIdKey;
extern NSString * const CR_ApiHandlerAppEventEventTypeKey;
extern NSString * const CR_ApiHandlerAppEventIdfaKey;
extern NSString * const CR_ApiHandlerAppEventLimitedAdTrackingKey;
extern NSString * const CR_ApiHandlerAppEventGdprAppliesKey;
extern NSString * const CR_ApiHandlerAppEventGdprConsentStringKey;
extern NSString * const CR_ApiHandlerAppEventGdprConsentGivenKey;
extern NSString * const CR_ApiHandlerAppEventGdprVersionKey;
extern NSString * const CR_ApiHandlerBidSlotsIsInterstitialKey;
extern NSString * const CR_ApiHandlerBidSlotsIsNativeKey;
extern NSString * const CR_ApiHandlerBidSlotsKey;
extern NSString * const CR_ApiHandlerBidSlotsPlacementIdKey;
extern NSString * const CR_ApiHandlerBidSlotsSizesKey;
extern NSString * const CR_ApiHandlerBundleIdKey;
extern NSString * const CR_ApiHandlerCpIdKey;
extern NSString * const CR_ApiHandlerDeviceIdTypeKey;
extern NSString * const CR_ApiHandlerDeviceIdTypeValue;
extern NSString * const CR_ApiHandlerDeviceIdKey;
extern NSString * const CR_ApiHandlerDeviceModelKey;
extern NSString * const CR_ApiHandlerDeviceOsKey;
extern NSString * const CR_ApiHandlerGdprKey;
extern NSString * const CR_ApiHandlerGdprVersionKey;
extern NSString * const CR_ApiHandlerGdprConsentGivenKey;
extern NSString * const CR_ApiHandlerGdprConsentStringKey;
extern NSString * const CR_ApiHandlerGdprAppliedKey;
extern NSString * const CR_ApiHandlerMopubConsentKey;
extern NSString * const CR_ApiHandlerUserAgentKey;
extern NSString * const CR_ApiHandlerUserKey;
extern NSString * const CR_ApiHandlerUspCriteoOptoutKey;
extern NSString * const CR_ApiHandlerUspIabStringKey;
extern NSString * const CR_ApiHandlerSdkVersionKey;
extern NSString * const CR_ApiHandlerProfileIdKey;
extern NSString * const CR_ApiHandlerPublisherKey;

@interface CR_ApiHandler : NSObject
@property (strong, nonatomic) CR_NetworkManager *networkManager;
@property (nonatomic, strong) CR_BidFetchTracker *bidFetchTracker;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithNetworkManager:(CR_NetworkManager *)networkManager
                        bidFetchTracker:(CR_BidFetchTracker *)bidFetchTracker
                          threadManager:(CR_ThreadManager *)threadManager NS_DESIGNATED_INITIALIZER;

/*
 * Calls CDB and get the bid & creative for the adUnit
 * adUnit must have an Id, width and length
 */
- (void)  callCdb:(CR_CacheAdUnitArray *)adUnits
          consent:(CR_DataProtectionConsent *)consent
           config:(CR_Config *)config
       deviceInfo:(CR_DeviceInfo *)deviceInfo
completionHandler:(CR_CdbCompletionHandler)completionHandler;

/*
 * Calls the pub-sdk config endpoint and gets the config values for the publisher
 * NetworkId, AppId/BundleId, sdkVersion must be present in the config
 */
- (void) getConfig: (CR_Config *) config
   ahConfigHandler:(AHConfigResponse) ahConfigHandler;

/*
 * Calls the app event endpoint and gets the throttleSec value for the user
 */
- (void) sendAppEvent: (NSString *)event
              consent:(CR_DataProtectionConsent *)consent
               config:(CR_Config *) config
           deviceInfo:(CR_DeviceInfo *) deviceInfo
       ahEventHandler:(AHAppEventsResponse) ahEventHandler;

/*
 * Exposed for testing only
 */
- (CR_CacheAdUnitArray *)filterRequestAdUnitsAndSetProgressFlags:(CR_CacheAdUnitArray *)adUnits;
- (NSMutableDictionary *)postBodyWithConsent:(CR_DataProtectionConsent *)consent
                                      config:(CR_Config *)config
                                  deviceInfo:(CR_DeviceInfo *)deviceInfo;
- (NSArray *)slotsForRequest:(CR_CacheAdUnitArray *)adUnits;

@end

#endif /* CR_ApiHandler_h */
