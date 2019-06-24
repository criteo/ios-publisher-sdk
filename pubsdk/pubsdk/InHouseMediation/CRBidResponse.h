//
//  CRBidResponse.h
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 6/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBidToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRBidResponse : NSObject

@property (nonatomic, readonly) double price;
@property (nonatomic, readonly) BOOL bidSuccess;
@property (nonatomic, readonly) CRBidToken *bidToken;

- (instancetype) init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
