//
//  CR_NetworkWaiterBuilder.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/20/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkWaiterBuilder.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkCaptor.h"
#import "CR_Config.h"
#import "NSURL+Testing.h"

@interface CR_NetworkWaiterBuilder ()

@property (nonatomic, strong) NSMutableArray<CR_HTTPResponseTester> *testers;
@property (nonatomic, strong) CR_Config *config;
@property (nonatomic, strong) CR_NetworkCaptor *captor;
@property (nonatomic, assign) BOOL finishedRequestsIncluded;

@end

@implementation CR_NetworkWaiterBuilder

- (instancetype)initWithConfig:(CR_Config *)config
                 networkCaptor:(CR_NetworkCaptor *)captor {
    if (self = [super init]) {
        _testers = [[NSMutableArray alloc] init];
        _config = config;
        _captor = captor;
        _finishedRequestsIncluded = NO;
    }
    return self;
}

- (CR_NetworkWaiterBuilder *)withBid {
    __weak typeof(self) weakSelf = self;
    [self.testers addObject:^BOOL(CR_HttpContent *_Nonnull httpContent) {
        return [httpContent.url testing_isBidUrlWithConfig:weakSelf.config];
    }];
    return self;
}

- (CR_NetworkWaiterBuilder *)withConfig {
    __weak typeof(self) weakSelf = self;
    [self.testers addObject:^BOOL(CR_HttpContent *_Nonnull httpContent) {
        return [httpContent.url testing_isConfigEventUrlWithConfig:weakSelf.config];
    }];
    return self;
}

- (CR_NetworkWaiterBuilder *)withLaunchAppEvent {
    __weak typeof(self) weakSelf = self;
    [self.testers addObject:^BOOL(CR_HttpContent *_Nonnull httpContent) {
        return  [httpContent.url testing_isAppLaunchEventUrlWithConfig:weakSelf.config];
    }];
    return self;
}

- (CR_NetworkWaiterBuilder *)withFinishedRequestsIncluded
{
    self.finishedRequestsIncluded = YES;
    return self;
}

- (CR_NetworkWaiter *)build {
    CR_NetworkWaiter *waiter =  [[CR_NetworkWaiter alloc] initWithNetworkCaptor:self.captor
                                                                        testers:self.testers];
    waiter.finishedRequestsIncluded = self.finishedRequestsIncluded;
    return waiter;
}

@end
