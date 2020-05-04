//
//  CR_NetworkWaiterBuilder.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_NetworkWaiter;
@class CR_NetworkCaptor;
@class CR_Config;

NS_ASSUME_NONNULL_BEGIN

@interface CR_NetworkWaiterBuilder : NSObject

@property (nonatomic, weak, readonly) CR_NetworkWaiterBuilder *withConfig;
@property (nonatomic, weak, readonly) CR_NetworkWaiterBuilder *withLaunchAppEvent;
@property (nonatomic, weak, readonly) CR_NetworkWaiterBuilder *withBid;
@property (nonatomic, weak, readonly) CR_NetworkWaiterBuilder *withFeedbackMessageSent;
@property (nonatomic, weak, readonly) CR_NetworkWaiterBuilder *withFinishedRequestsIncluded;
@property (nonatomic, weak, readonly) CR_NetworkWaiter *build;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfig:(CR_Config *)config
                 networkCaptor:(CR_NetworkCaptor *)captor NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
