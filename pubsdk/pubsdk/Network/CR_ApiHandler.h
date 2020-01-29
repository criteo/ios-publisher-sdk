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

typedef void (^AHCdbResponse)(CR_CdbResponse *cdbResponse);
typedef void (^AHConfigResponse)(NSDictionary *configValues);
typedef void (^AHAppEventsResponse)(NSDictionary *appEventValues, NSDate *receivedAt);

FOUNDATION_EXTERN NSString * const CR_ApiHandlerUspIabStringKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerUserKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerUspCriteoOptoutKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerMopubConsentKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerBidSlotsKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerBidSlotsPlacementIdKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerBidSlotsSizesKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerBidSlotsIsNativeKey;
FOUNDATION_EXTERN NSString * const CR_ApiHandlerBidSlotsIsInterstitialKey;

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
- (void)        callCdb:(CR_CacheAdUnitArray *)adUnits
                consent:(CR_DataProtectionConsent *)consent
                 config:(CR_Config *)config
             deviceInfo:(CR_DeviceInfo *)deviceInfo
   ahCdbResponseHandler:(AHCdbResponse)ahCdbResponseHandler;

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
