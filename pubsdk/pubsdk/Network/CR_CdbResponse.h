//
//  CR_CdbResponse.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef CdbResponse_h
#define CdbResponse_h

#import <Foundation/Foundation.h>
#import "CR_CdbBid.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_CdbResponse : NSObject

@property (copy, nonatomic, nullable) NSArray<CR_CdbBid *> *cdbBids;
@property (assign, nonatomic) NSUInteger timeToNextCall;
@property (copy, nonatomic) NSDate *responseTime;

/**
 * Helper function to convert NSData returned from a network call
 * to a CR_CdbResponse object.
 *
 * @return a CR_CdbResponse or nil if the parameters are nil.
 */
+ (nullable CR_CdbResponse *)responseWithData:(nullable NSData *)data
                                   receivedAt:(nullable NSDate *)receivedAt;

@end

NS_ASSUME_NONNULL_END

#endif /* CdbResponse_h */
