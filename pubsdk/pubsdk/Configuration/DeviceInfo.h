//
//  DeviceInfo.h
//  pubsdk
//
//  Created by Paul Davis on 1/28/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfo : NSObject

@property (nonatomic,readonly) NSString *userAgent;

- (instancetype) init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
