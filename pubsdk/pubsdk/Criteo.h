//
//  Criteo.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/7/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef Criteo_h
#define Criteo_h

#import <Foundation/Foundation.h>

#import "CRAdUnit.h"

@interface Criteo : NSObject

/* @abstract Use sharedInstance */
- (instancetype) init NS_UNAVAILABLE;
+ (nonnull instancetype) sharedCriteo;

- (void) registerNetworkId:(NSUInteger)networkId
               withAdUnits:(NSArray<CRAdUnit*> *) adUnits;

- (void) setBidsForRequest:(id) request
                withAdUnit:(CRAdUnit *) adUnit;

@end

#endif /* Criteo_h */
