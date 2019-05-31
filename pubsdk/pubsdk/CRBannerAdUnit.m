//
//  CRBannerAdUnit.m
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"

@implementation CRBannerAdUnit

- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                             size:(CGSize)size {
    if(self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeBanner]) {
        _size = size;
    }
    return self;
}

@end
