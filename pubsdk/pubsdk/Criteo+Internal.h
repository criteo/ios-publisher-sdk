//
//  Criteo+Internal.h
//  pubsdk
//
//  Created by Paul Davis on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef Criteo_Internal_h
#define Criteo_Internal_h

#import "CR_NetworkManagerDelegate.h"
#import "CRCacheAdUnit.h"
@class CR_CdbBid;
@interface Criteo ()

@property (nonatomic) id<CR_NetworkManagerDelegate> networkMangerDelegate;
- (CR_CdbBid *)getBid:(CRCacheAdUnit *)slot;
@end


#endif /* Criteo_Internal_h */
