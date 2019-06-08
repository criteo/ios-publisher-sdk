//
//  CRBidResponse+Internal.h
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 6/10/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRBidResponse_Internal_h
#define CRBidResponse_Internal_h

#import "CRBidResponse.h"

@interface CRBidResponse ()

- (instancetype) initWithPrice:(double) price
                    bidSuccess:(BOOL) bidSuccess
                      bidToken:(CRBidToken*)bidToken;

@end

#endif /* CRBidResponse_Internal_h */
