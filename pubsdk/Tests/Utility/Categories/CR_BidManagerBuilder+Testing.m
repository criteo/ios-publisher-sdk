//
//  CR_BidManagerBuilder+Testing.m
//  pubsdk
//
//  Created by Romain Lofaso on 3/24/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_BidManagerBuilder+Testing.h"
#import "CR_Config.h"
#import "CR_NetworkManagerDecorator.h"
#import "Criteo+Testing.h"

@implementation CR_BidManagerBuilder (Testing)

+ (instancetype)testing_bidManagerWithNetworkCaptor {
    CR_Config *config = [CR_Config configForPreprodWithCriteoPublisherId:CriteoTestingPublisherId];
    CR_NetworkManagerDecorator *decorator = [CR_NetworkManagerDecorator decoratorFromConfiguration:config];

    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    builder.networkManager = [decorator decorateNetworkManager:builder.networkManager];
    builder.notificationCenter = [[NSNotificationCenter alloc] init];
    builder.config = config;
    return builder;
}

@end
