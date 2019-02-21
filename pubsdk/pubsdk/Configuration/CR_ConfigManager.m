//
//  CR_ConfigManager.m
//  pubsdk
//
//  Created by Paul Davis on 1/26/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_ConfigManager.h"

@implementation CR_ConfigManager
{
    ApiHandler *apiHandler;
}

- (instancetype) initWithApiHandler:(ApiHandler*)apiHandler
{
    if (self = [super init]) {
        self->apiHandler = apiHandler;
    }

    return self;
}

- (void) refreshConfig:(CR_Config*)config
{
    [self->apiHandler getConfig:config
                ahConfigHandler:^(NSDictionary *configValues) {
                    if(configValues[@"killSwitch"] && [configValues[@"killSwitch"] isKindOfClass:NSNumber.class]) {
                        config.killSwitch = ((NSNumber*)configValues[@"killSwitch"]).boolValue;
                    }
                }];
}

@end
