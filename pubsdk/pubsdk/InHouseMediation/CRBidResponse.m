//
//  CRBidResponse.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRBidResponse.h"

@implementation CRBidResponse

- (instancetype) initWithPrice:(double) price
                    bidSuccess:(BOOL) bidSuccess
                      bidToken:(CRBidToken*)bidToken {
    if (self = [super init]){
        _price = price;
        _bidSuccess = bidSuccess;
        _bidToken = bidToken;
    }
    return self;
}


@end
