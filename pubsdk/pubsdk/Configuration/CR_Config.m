//
//  CR_Config.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/24/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_Config.h"
#import "Logging.h"
#import <UIKit/UIKit.h>
#import "NSUserDefaults+CRPrivateKeysAndUtils.h"

// Production
NSString * const CR_ConfigCdbUrl = @"https://bidder.criteo.com";
NSString * const CR_ConfigAppEventsUrl = @"https://gum.criteo.com/appevent/v1";
NSString * const CR_ConfigConfigurationUrl = @"https://pub-sdk-cfg.criteo.com/v2.0/api/config";

// Pre-Production
NSString * const CR_ConfigPreprodCdbUrl = @"https://directbidder-test-app.par.preprod.crto.in";
NSString * const CR_ConfigPreprodAppEventsUrl = @"https://pub-sdk-cfg.par.preprod.crto.in";
NSString * const CR_ConfigPreprodConfigurationUrl = @"https://gum.par.preprod.crto.in";

@implementation CR_Config

+ (CR_Config *)configForPreprodWithCriteoPublisherId:(NSString *)criteoPublisherId
{
    // For now, I don't success to make the CR_ConfigPreprodAppEventsUrl & CR_ConfigPreprodConfigurationUrl
    // It requires investigations.
    return [[CR_Config alloc] initWithCriteoPublisherId:criteoPublisherId
                                                 cdbUrl:CR_ConfigPreprodCdbUrl
                                           appEventsUrl:CR_ConfigAppEventsUrl
                                              configUrl:CR_ConfigConfigurationUrl];

}

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
                                   cdbUrl:(NSString *)cdbUrl
                             appEventsUrl:(NSString *)appEventsUrl
                                configUrl:(NSString *)configUrl
{
    if (self = [super init]) {
        _criteoPublisherId = criteoPublisherId;
        _profileId = @(235);
        _cdbUrl = [cdbUrl copy];
        _path = @"inapp/v2";
        _sdkVersion = @"3.3.0";
        _appId = [[NSBundle mainBundle] bundleIdentifier];
        _killSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:NSUserDefaultsKillSwitchKey];
        _deviceModel = [[UIDevice currentDevice] model];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _deviceOs = @"ios";
        _appEventsUrl = [appEventsUrl copy];
        _appEventsSenderId = @"2379";
        _adTagUrlMode = @"<!doctype html><html><head><meta charset=\"utf-8\"><style>body{margin:0;padding:0}</style><meta name=\"viewport\" content=\"width=%%width%%, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\" ></head><body><script src=\"%%displayUrl%%\"></script></body></html>";
        _viewportWidthMacro = @"%%width%%";
        _displayURLMacro = @"%%displayUrl%%";
        _configUrl = [configUrl copy];
    }
    return self;
}

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
{
    return [self initWithCriteoPublisherId:criteoPublisherId
                                    cdbUrl:CR_ConfigCdbUrl
                              appEventsUrl:CR_ConfigAppEventsUrl
                                 configUrl:CR_ConfigConfigurationUrl];
}

- (instancetype)init
{
    return [self initWithCriteoPublisherId:nil
                                    cdbUrl:CR_ConfigCdbUrl
                              appEventsUrl:CR_ConfigAppEventsUrl
                                 configUrl:CR_ConfigConfigurationUrl];
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
