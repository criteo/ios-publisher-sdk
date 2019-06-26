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

- (void) registerCriteoPublisherId:(NSString *) criteoPublisherId
                       withAdUnits:(NSArray<CRAdUnit*> *) adUnits;

- (void) setBidsForRequest:(id) request
                withAdUnit:(CRAdUnit *) adUnit;

- (CRBidResponse *)getBidResponseForAdUnit:(CRAdUnit *)adUnit;

@end
NS_ASSUME_NONNULL_END

#endif /* Criteo_h */
