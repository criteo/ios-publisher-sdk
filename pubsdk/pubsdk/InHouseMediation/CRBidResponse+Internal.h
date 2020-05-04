//
//  CRBidResponse+Internal.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef CRBidResponse_Internal_h
#define CRBidResponse_Internal_h

#import "CRBidResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRBidResponse ()

- (instancetype) initWithPrice:(double) price
                    bidSuccess:(BOOL) bidSuccess
                      bidToken:(nullable CRBidToken*)bidToken;

@end

NS_ASSUME_NONNULL_END

#endif /* CRBidResponse_Internal_h */


