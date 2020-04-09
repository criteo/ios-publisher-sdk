//
//  CR_NetworkManagerDecorator.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/18/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <OCMock/OCMock.h>
#import "CR_Config.h"
#import "CR_NetworkManagerDecorator.h"
#import "CR_NetworkManagerSimulator.h"
#import "CR_NetworkCaptor.h"

@interface CR_NetworkManagerDecorator ()

@property (nonatomic, strong, readonly) CR_Config *config;

@end

@implementation CR_NetworkManagerDecorator

+ (BOOL)shouldRunTestsInIsolationFormNetwork
{
    static BOOL inInsolation = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *env = NSProcessInfo.processInfo.environment;
        inInsolation = [env[@"RUN_TESTS_IN_ISOLATION_FROM_NETWORK"] boolValue];
        NSLog(@"RUN_TESTS_IN_ISOLATION_FROM_NETWORK = %d", inInsolation);
    });
    return inInsolation;
}

+ (instancetype)decoratorFromConfiguration:(CR_Config *)config {
    if ([self shouldRunTestsInIsolationFormNetwork]) {
        return [[CR_NetworkManagerDecorator alloc] initWithSimulating:YES
                                                            capturing:YES
                                                              config:config];
    } else {
        return [[CR_NetworkManagerDecorator alloc] initWithSimulating:NO
                                                            capturing:YES
                                                               config:config];
    }
}

- (instancetype)initWithSimulating:(BOOL)simulating
                         capturing:(BOOL)capturing
                            config:(CR_Config *)config {
    if (self = [super init]) {
        _simulating = simulating;
        _capturing = capturing;
        _config = config;
    }
    return self;
}

- (CR_NetworkManager *)decorateNetworkManager:(CR_NetworkManager *)networkManager {
    CR_NetworkManager *result = networkManager;
    if (self.isSimulating) {
        result = [[CR_NetworkManagerSimulator alloc] initWithConfig:self.config];
    }

    result = OCMPartialMock(result);

    if (self.isCapturing) {
        result = [[CR_NetworkCaptor alloc] initWithNetworkManager:result];
    }
    return result;
}

@end
