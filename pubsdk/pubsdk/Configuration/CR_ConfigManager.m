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
    CR_ApiHandler *apiHandler;
}

- (instancetype) initWithApiHandler:(CR_ApiHandler*)apiHandler
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
                    if(configValues[@"iOSAdTagUrlMode"] && [configValues[@"iOSAdTagUrlMode"] isKindOfClass:NSString.class]) {
                        config.adTagUrlMode = (NSString*)configValues[@"iOSAdTagUrlMode"];
                    }
                    if(configValues[@"iOSDisplayUrlMacro"] && [configValues[@"iOSDisplayUrlMacro"] isKindOfClass:NSString.class]) {
                        config.displayURLMacro = (NSString*)configValues[@"iOSDisplayUrlMacro"];
                    }
                    if(configValues[@"iOSWidthMacro"] && [configValues[@"iOSWidthMacro"] isKindOfClass:NSString.class]) {
                        config.viewportWidthMacro = (NSString*)configValues[@"iOSWidthMacro"];
                    }
                }];
}

@end
