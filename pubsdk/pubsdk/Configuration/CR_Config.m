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

// FIXME EE-1001
// Test (using Pre-Production or Local)
// #define HIT_LOCAL_CDB // Uncomment to use local CDB instead of preprod
#ifdef HIT_LOCAL_CDB
// This is the default configuration if you follow the CDB readme.
NSString * const CR_ConfigTestCdbUrl = @"http://127.0.0.1:9991";
#else
NSString * const CR_ConfigTestCdbUrl = @"https://directbidder-test-app.par.preprod.crto.in";
#endif
#undef HIT_LOCAL_CDB
NSString * const CR_ConfigTestAppEventsUrl = @"https://pub-sdk-cfg.par.preprod.crto.in";
NSString * const CR_ConfigTestConfigurationUrl = @"https://gum.par.preprod.crto.in";

@implementation CR_Config

+ (CR_Config *)configForTestWithCriteoPublisherId:(NSString *)criteoPublisherId
                                        userDefaults:(NSUserDefaults *)userDefaults
{
    // For now, I don't success to make the CR_ConfigTestAppEventsUrl & CR_ConfigTestConfigurationUrl
    // It requires investigations.
    return [[CR_Config alloc] initWithCriteoPublisherId:criteoPublisherId
                                                 cdbUrl:CR_ConfigTestCdbUrl
                                           appEventsUrl:CR_ConfigAppEventsUrl
                                              configUrl:CR_ConfigConfigurationUrl
                                           userDefaults:userDefaults];

}

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
                                   cdbUrl:(NSString *)cdbUrl
                             appEventsUrl:(NSString *)appEventsUrl
                                configUrl:(NSString *)configUrl
                             userDefaults:(NSUserDefaults *)userDefaults
{
    if (self = [super init]) {
        _criteoPublisherId = criteoPublisherId;
        _profileId = @(235);
        _cdbUrl = [cdbUrl copy];
        _path = @"inapp/v2";
        _csmPath = @"csm";
        _sdkVersion = @"3.4.0";
        _appId = [[NSBundle mainBundle] bundleIdentifier];
        _killSwitch = [userDefaults boolForKey:NSUserDefaultsKillSwitchKey];
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
                                 configUrl:CR_ConfigConfigurationUrl
                              userDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)init
{
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    return [self initWithCriteoPublisherId:nil
                                    cdbUrl:CR_ConfigCdbUrl
                              appEventsUrl:CR_ConfigAppEventsUrl
                                 configUrl:CR_ConfigConfigurationUrl
                              userDefaults:userDefaults];
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
