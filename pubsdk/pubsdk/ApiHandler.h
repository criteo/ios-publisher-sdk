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
#import "AdUnit.h"
#import "CdbBid.h"
#import "Config.h"
#import "GdprUserConsent.h"

typedef void (^AHCdbResponse)(NSArray<CdbBid*> *cdbBids);
typedef void (^AHConfigResponse)(NSDictionary *configValues);

@interface ApiHandler : NSObject
@property (strong, nonatomic) NetworkManager *networkManager;

/*
 * Calls CDB and get the bid & creative for the adUnit
 * adUnit must have an Id, width and length
 */
- (void) callCdb: (AdUnit *) adUnit
     gdprConsent:(GdprUserConsent *) gdprConsent
          config:(Config *) config
 ahCdbResponseHandler: (AHCdbResponse) ahCdbResponseHandler;

/*
 * Calls the pub-sdk config endpoint and gets the config values for the publisher
 * NetworkId, AppId/BundleId, sdkVersion must be present in the config
 */
- (void) getConfig: (Config *) config
   ahConfigHandler:(AHConfigResponse) ahConfigHandler;

@end

#endif /* ApiHandler_h */
