//
//  CR_TokenValue+Testing.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_TokenValue.h"

@interface CR_TokenValue (Testing)

+ (CR_TokenValue *)tokenValueWithDisplayUrl:(NSString *)displayUrl adUnit:(CRAdUnit *)adUnit;

+ (CR_TokenValue *)tokenValueWithDisplayUrl:(NSString *)displayUrl
                                     adUnit:(CRAdUnit *)adUnit
                                    expired:(BOOL)expired;

@end