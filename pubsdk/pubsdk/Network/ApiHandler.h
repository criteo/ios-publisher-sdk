//
//  ApiHandler.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/6/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef ApiHandler_h
#define ApiHandler_h

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "CRAdUnit.h"
#import "CdbResponse.h"
#import "CR_Config.h"
#import "GdprUserConsent.h"
#import "CR_DeviceInfo.h"

typedef void (^AHCdbResponse)(CdbResponse *cdbResponse);
typedef void (^AHConfigResponse)(NSDictionary *configValues);
typedef void (^AHAppEventsResponse)(NSDictionary *appEventValues, NSDate *receivedAt);

@interface ApiHandler : NSObject
@property (strong, nonatomic) NetworkManager *networkManager;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithNetworkManager:(NetworkManager*)networkManager NS_DESIGNATED_INITIALIZER;

/*
 * Calls CDB and get the bid & creative for the adUnit
 * adUnit must have an Id, width and length
 */
- (void) callCdb: (CRAdUnit *) adUnit
     gdprConsent:(GdprUserConsent *) gdprConsent
          config:(CR_Config *) config
      deviceInfo:(CR_DeviceInfo *) deviceInfo
ahCdbResponseHandler: (AHCdbResponse) ahCdbResponseHandler;

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
          gdprConsent:(GdprUserConsent *)gdprConsent
               config:(CR_Config *) config
           deviceInfo:(CR_DeviceInfo *) deviceInfo
       ahEventHandler:(AHAppEventsResponse) ahEventHandler;

@end

#endif /* ApiHandler_h */
