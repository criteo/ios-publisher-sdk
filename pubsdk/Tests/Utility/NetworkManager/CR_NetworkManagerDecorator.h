//
//  CR_NetworkManagerDecorator.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_NetworkManager;

NS_ASSUME_NONNULL_BEGIN

/**
 Decorate a network or a simulator of network (for isolated tests)
 with an OCMockObject and a CR_NetworkCaptor.
 */
@interface CR_NetworkManagerDecorator : NSObject

@property (nonatomic, assign, getter=isSimulating) BOOL simulating;
@property (nonatomic, assign, getter=isCapturing) BOOL capturing;

+ (instancetype)decoratorFromConfiguration:(CR_Config *)config;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSimulating:(BOOL)simulating
                         capturing:(BOOL)capturing
                            config:(CR_Config *)config NS_DESIGNATED_INITIALIZER;

- (CR_NetworkManager *)decorateNetworkManager:(CR_NetworkManager *)networkManager;

@end

NS_ASSUME_NONNULL_END
