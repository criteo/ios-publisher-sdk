//
//  CR_NetworkWaiterBuilder.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CR_NetworkWaiterBuilder.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkCaptor.h"
#import "CR_Config.h"
#import "NSURL+Testing.h"

@interface CR_NetworkWaiterBuilder ()

@property(nonatomic, strong) NSMutableArray<CR_HTTPResponseTester> *testers;
@property(nonatomic, strong) CR_Config *config;
@property(nonatomic, strong) CR_NetworkCaptor *captor;
@property(nonatomic, assign) BOOL finishedRequestsIncluded;

@end

@implementation CR_NetworkWaiterBuilder

- (instancetype)initWithConfig:(CR_Config *)config networkCaptor:(CR_NetworkCaptor *)captor {
  if (self = [super init]) {
    _testers = [[NSMutableArray alloc] init];
    _config = config;
    _captor = captor;
    _finishedRequestsIncluded = NO;
  }
  return self;
}

- (CR_NetworkWaiterBuilder *)withFeedbackMessageSent {
  __weak typeof(self) weakSelf = self;
  [self.testers addObject:^BOOL(CR_HttpContent *_Nonnull httpContent) {
    return [httpContent.url testing_isFeedbackMessageUrlWithConfig:weakSelf.config];
  }];
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
    return [httpContent.url testing_isAppLaunchEventUrlWithConfig:weakSelf.config];
  }];
  return self;
}

- (CR_NetworkWaiterBuilder *)withFinishedRequestsIncluded {
  self.finishedRequestsIncluded = YES;
  return self;
}

- (CR_NetworkWaiter *)build {
  CR_NetworkWaiter *waiter = [[CR_NetworkWaiter alloc] initWithNetworkCaptor:self.captor
                                                                     testers:self.testers];
  waiter.finishedRequestsIncluded = self.finishedRequestsIncluded;
  return waiter;
}

@end
