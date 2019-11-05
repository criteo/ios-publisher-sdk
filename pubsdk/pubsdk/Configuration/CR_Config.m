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
        _path = @"inapp/v2";
        _sdkVersion = @"3.2.2";
        _appId = [[NSBundle mainBundle] bundleIdentifier];
        _killSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:killSwitchKey];
        _deviceModel = [[UIDevice currentDevice] model];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _deviceOs = @"ios";
        _appEventsUrl = @"https://gum.criteo.com/appevent/v1";
        _appEventsSenderId = @"2379";
        _adTagUrlMode = @"<!doctype html><html><head><meta charset=\"utf-8\"><style>body{margin:0;padding:0}</style><meta name=\"viewport\" content=\"width=%%width%%, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\" ></head><body><script src=\"%%displayUrl%%\"></script></body></html>";
        _viewportWidthMacro = @"%%width%%";
        _displayURLMacro = @"%%displayUrl%%";
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
