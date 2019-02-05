//
//  Config.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/24/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "Config.h"
#import "Logging.h"

@implementation Config

- (instancetype) initWithNetworkId:(NSNumber *)networkId {
    if (self = [super init]) {
        _networkId = networkId;
        _profileId = @(235);
        _cdbUrl = @"https://bidder.criteo.com";
        //_cdbUrl = @"http://directbidder-test-app.par.preprod.crto.in";
        _path = @"inapp/v1";
        _sdkVersion = @"2.0";
        _appId = [[NSBundle mainBundle] bundleIdentifier];;
        _killSwitch = NO;
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
