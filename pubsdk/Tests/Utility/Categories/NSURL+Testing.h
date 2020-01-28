//
//  NSURL+Testing.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/20/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_Config;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Testing)

- (BOOL)testing_isBidUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isAppLaunchEventUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isConfigEventUrlWithConfig:(CR_Config *)config;

@end

NS_ASSUME_NONNULL_END
