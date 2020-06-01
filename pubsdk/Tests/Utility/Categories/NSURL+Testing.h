//
//  NSURL+Testing.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_Config;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Testing)

- (BOOL)testing_isFeedbackMessageUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isBidUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isAppEventUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isAppLaunchEventUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isConfigEventUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isNativeProductImage;
- (BOOL)testing_isNativeAdvertiserLogoImage;
- (BOOL)testing_isNativeAdChoiceImage;

@end

NS_ASSUME_NONNULL_END
