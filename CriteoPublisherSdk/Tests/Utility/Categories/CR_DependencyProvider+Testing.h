//
//  CR_DependencyProvider+Testing.h
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

#import "CR_DependencyProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_DependencyProvider (Testing)

#pragma mark - Utils for configuring dependencies

// ⚠️ Call those methods in this order to have a good dependency management.
@property(weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedUserDefaults;
@property(weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedDeviceInfo;
@property(weak, nonatomic, readonly) CR_DependencyProvider *withWireMockConfiguration;
@property(weak, nonatomic, readonly) CR_DependencyProvider *withListenedNetworkManager;
@property(weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedNotificationCenter;
@property(weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedFeedbackStorage;
@property(weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedIntegrationRegistry;
@property(weak, nonatomic, readonly) CR_DependencyProvider *withShortLiveBidTimeBudget;

+ (instancetype)testing_dependencyProvider;

- (CR_DependencyProvider *)withListenedNetworkManagerWithDelay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
