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

#import "AdUnit.h"

@interface Criteo : NSObject

/* @abstract Use sharedInstance */
- (instancetype) init NS_UNAVAILABLE;
+ (nonnull instancetype) sharedCriteo;

- (void) registerNetworkId:(NSUInteger)networkId
               withAdUnits:(NSArray<AdUnit*> *) adUnits;

- (void) setBidsForRequest:(id) request
                withAdUnit:(AdUnit *) adUnit;

@end

#endif /* Criteo_h */
