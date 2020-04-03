//
//  CR_BidManagerBuilder+Testing.h
//  pubsdk
//
//  Created by Romain Lofaso on 3/24/20.
//  Copyright © 2020 Criteo. All rights reserved.
//


#import "CR_BidManagerBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_BidManagerBuilder (Testing)

#pragma mark - Utils for configuring builder

// ⚠️ Call those methods in this order to have a good dependency management.
@property (weak, nonatomic, readonly) CR_BidManagerBuilder *withIsolatedUserDefaults;
@property (weak, nonatomic, readonly) CR_BidManagerBuilder *withPreprodConfiguration;
@property (weak, nonatomic, readonly) CR_BidManagerBuilder *withListenedNetworkManager;
@property (weak, nonatomic, readonly) CR_BidManagerBuilder *withIsolatedNotificationCenter;
@property (weak, nonatomic, readonly) CR_BidManagerBuilder *withIsolatedFeedbackStorage;


+ (instancetype)testing_bidManagerBuilder;

@end

NS_ASSUME_NONNULL_END
