//
//  CR_DependencyProvider+Testing.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//


#import "CR_DependencyProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_DependencyProvider (Testing)

#pragma mark - Utils for configuring dependencies

// ⚠️ Call those methods in this order to have a good dependency management.
@property (weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedUserDefaults;
@property (weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedDeviceInfo;
@property (weak, nonatomic, readonly) CR_DependencyProvider *withPreprodConfiguration;
@property (weak, nonatomic, readonly) CR_DependencyProvider *withListenedNetworkManager;
@property (weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedNotificationCenter;
@property (weak, nonatomic, readonly) CR_DependencyProvider *withIsolatedFeedbackStorage;


+ (instancetype)testing_dependencyProvider;

@end

NS_ASSUME_NONNULL_END
