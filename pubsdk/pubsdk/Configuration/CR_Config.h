//
//  CR_Config.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/11/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_Config_h
#define CR_Config_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Production
FOUNDATION_EXTERN NSString * const CR_ConfigCdbUrl;
FOUNDATION_EXTERN NSString * const CR_ConfigAppEventsUrl;
FOUNDATION_EXTERN NSString * const CR_ConfigConfigurationUrl;

// Pre-Production
FOUNDATION_EXTERN NSString * const CR_ConfigPreprodCdbUrl;
FOUNDATION_EXTERN NSString * const CR_ConfigPreprodAppEventsUrl;
FOUNDATION_EXTERN NSString * const CR_ConfigPreprodConfigurationUrl;

@interface CR_Config : NSObject

@property (copy, nonatomic, nullable) NSString *criteoPublisherId;

/**
 ID for differenciate the SDK from other adapters like Publisher tag.
 */
@property (copy, nonatomic, readonly) NSNumber *profileId;
@property (copy, nonatomic, readonly) NSString *cdbUrl;
@property (copy, nonatomic, readonly) NSString *path;
@property (copy, nonatomic, readonly) NSString *sdkVersion;
@property (copy, nonatomic, readonly) NSString *appId;
@property (nonatomic) BOOL killSwitch;
@property (copy, nonatomic) NSString *adTagUrlMode;
@property (copy, nonatomic) NSString *viewportWidthMacro;
@property (copy, nonatomic) NSString *displayURLMacro;
@property (copy, nonatomic, readonly) NSString *appEventsUrl;
@property (copy, nonatomic, readonly) NSString *appEventsSenderId;
@property (copy, nonatomic, readonly) NSString *deviceModel;
@property (copy, nonatomic, readonly) NSString *osVersion;
@property (copy, nonatomic, readonly) NSString *deviceOs;
@property (copy, nonatomic, readonly) NSString *configUrl;

+ (CR_Config *)configForPreprodWithCriteoPublisherId:(nullable NSString *)criteoPublisherId;

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId
                                   cdbUrl:(NSString *)cdbUrl
                             appEventsUrl:(NSString *)appEventsUrl
                                configUrl:(NSString *)configUrl NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCriteoPublisherId:(nullable NSString *)criteoPublisherId;

- (instancetype)init;

/*
 * Helper function to convert NSData returned from a network call
 * to an NSDictionary with config values
 */
+ (NSDictionary *) getConfigValuesFromData: (NSData *) data;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_Config_h */
