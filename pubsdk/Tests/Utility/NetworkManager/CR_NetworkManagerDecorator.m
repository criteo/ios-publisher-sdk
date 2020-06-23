//
//  CR_NetworkManagerDecorator.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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

+ (instancetype)decoratorFromConfiguration:(CR_Config *)config {
    return [[CR_NetworkManagerDecorator alloc] initWithSimulating:YES
                                                        capturing:YES
                                                           config:config];
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
