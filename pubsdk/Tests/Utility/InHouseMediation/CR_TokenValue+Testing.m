//
//  CR_TokenValue+Testing.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <OCMock.h>
#import "CR_TokenValue+Testing.h"
#import "CR_CdbBid.h"
#import "CR_CdbBidBuilder.h"

@implementation CR_TokenValue (Testing)

+ (CR_TokenValue *)tokenValueWithDisplayUrl:(NSString *)displayUrl adUnit:(CRAdUnit *)adUnit {
    return [CR_TokenValue tokenValueWithDisplayUrl:displayUrl adUnit:adUnit expired:NO];
}

+ (CR_TokenValue *)tokenValueWithDisplayUrl:(NSString *)displayUrl adUnit:(CRAdUnit *)adUnit expired:(BOOL)expired {
    CR_CdbBidBuilder *builder = CR_CdbBidBuilder.new.displayUrl(displayUrl);

    if (expired) {
        builder = builder.expiredInsertTime();
    }

    CR_CdbBid *cdbBid = builder.build;

    return [CR_TokenValue.alloc initWithCdbBid:cdbBid adUnit:adUnit];
}


@end