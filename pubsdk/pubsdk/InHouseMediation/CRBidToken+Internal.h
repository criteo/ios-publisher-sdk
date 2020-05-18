//
//  CRBidToken+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef CRBidToken_Internal_h
#define CRBidToken_Internal_h

#import <Foundation/Foundation.h>
#import "CRBidToken.h"

@interface CRBidToken ()

@property (nonatomic, readonly) NSUUID* bidTokenUUID;

- (instancetype) initWithUUID:(NSUUID *)uuid NS_DESIGNATED_INITIALIZER;

@end


#endif /* CRBidToken_Internal_h */
