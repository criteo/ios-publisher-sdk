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
#import "GdprUserConsent.h"

typedef void (^AHCdbResponse)(NSArray<CdbBid*> *cdbBids);

@interface ApiHandler : NSObject
@property (strong, nonatomic) NetworkManager *networkManager;

- (void) callCdb: (AdUnit *) adUnit
     gdprConsent:(GdprUserConsent *) gdprConsent
 ahCdbResponseHandler: (AHCdbResponse) ahCdbResponseHandler;

@end

#endif /* ApiHandler_h */
