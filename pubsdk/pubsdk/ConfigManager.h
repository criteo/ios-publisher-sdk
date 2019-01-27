//
//  ConfigManager.h
//  pubsdk
//
//  Created by Paul Davis on 1/26/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef ConfigManager_h
#define ConfigManager_h

#import <Foundation/Foundation.h>
#import "ApiHandler.h"
#import "Config.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigManager : NSObject

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithApiHandler:(ApiHandler*)apiHandler NS_DESIGNATED_INITIALIZER;
- (void) refreshConfig:(Config*)config;

@end

NS_ASSUME_NONNULL_END

#endif /* ConfigManager_h */
