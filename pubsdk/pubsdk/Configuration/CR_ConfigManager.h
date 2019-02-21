//
//  CR_ConfigManager.h
//  pubsdk
//
//  Created by Paul Davis on 1/26/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_ConfigManager_h
#define CR_ConfigManager_h

#import <Foundation/Foundation.h>
#import "CR_ApiHandler.h"
#import "CR_Config.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_ConfigManager : NSObject

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithApiHandler:(CR_ApiHandler*)apiHandler NS_DESIGNATED_INITIALIZER;
- (void) refreshConfig:(CR_Config*)config;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_ConfigManager_h */
