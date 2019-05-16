//
//  CR_Config.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/24/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_Config.h"
#import "Logging.h"
#import <AdSupport/ASIdentifierManager.h>
#import <UIKit/UIKit.h>

@implementation CR_Config

- (instancetype) initWithCriteoPublisherId:(NSString *)criteoPublisherId {
    if (self = [super init]) {
        _criteoPublisherId = criteoPublisherId;
        _profileId = @(235);
        _cdbUrl = @"https://bidder.criteo.com";
        //_cdbUrl = @"http://directbidder-test-app.par.preprod.crto.in";
        _path = @"inapp/v1";
        _sdkVersion = @"2.0.0";
        _appId = [[NSBundle mainBundle] bundleIdentifier];;
        _killSwitch = NO;
        _deviceModel = [[UIDevice currentDevice] model];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _deviceOs = @"ios";
        _appEventsUrl = @"https://gum.criteo.com/appevent/v1";
        _appEventsSenderId = @"2379";
    }
    return self;
}

+ (NSDictionary *) getConfigValuesFromData:(NSData *) data {
    NSError *e = nil;
    NSMutableDictionary *configValues = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
    if (!configValues) {
        CLog(@"Error parsing config values: %@", e);
    }
    return configValues;
}

@end
