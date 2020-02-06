//
//  CR_NetworkManagerDecorator.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/18/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_NetworkManager;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CR_NetworkManagerDecoratorStrategy) {
    CR_NetworkManagerDecoratorStrategySimulating,
    CR_NetworkManagerDecoratorStrategyCapturing,
    CR_NetworkManagerDecoratorStrategyCapturingAndRecording
};

@interface CR_NetworkManagerDecorator : NSObject

@property (nonatomic, assign, getter=isSimulating) BOOL simulating;
@property (nonatomic, assign, getter=isCapturing) BOOL capturing;

+ (instancetype)decoratorFromConfiguration:(CR_Config *)config;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSimulating:(BOOL)simulating
                         capturing:(BOOL)capturing
                            config:(CR_Config *)config NS_DESIGNATED_INITIALIZER;

/** Should be called in the same thread of the test method. */
- (CR_NetworkManager *)decorateNetworkManager:(CR_NetworkManager *)networkManager;

@end

NS_ASSUME_NONNULL_END
