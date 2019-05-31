//
//  CRAdUnit.m
//  pubsdk
//
//  Created by Robert Aung Hein Oo on 5/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"


@implementation CRAdUnit

- (instancetype) initWithAdUnitId:(NSString *)adUnitId
                       adUnitType:(CRAdUnitType)adUnitType {
    if(self = [super init]) {
        _adUnitId = adUnitId;
        _adUnitType = adUnitType;
    }
    return self;
}

@end
