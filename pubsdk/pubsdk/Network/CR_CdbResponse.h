//
//  CR_CdbResponse.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 2/12/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CdbResponse_h
#define CdbResponse_h

#import <Foundation/Foundation.h>
#import "CR_CdbBid.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_CdbResponse : NSObject

@property (nonatomic, nullable) NSArray<CR_CdbBid *> *cdbBids;
@property (nonatomic) NSUInteger timeToNextCall;
@property (nonatomic) NSDate *responseTime;

/*
 * Helper function to convert NSData returned from a network call
 * to a CR_CdbResponse object
 */
+ (CR_CdbResponse *) getCdbResponseForData: (NSData *) data
                             receivedAt: (NSDate *) receivedAt;

@end

NS_ASSUME_NONNULL_END

#endif /* CdbResponse_h */
