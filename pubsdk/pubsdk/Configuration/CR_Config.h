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

@interface CR_Config : NSObject

@property (copy, nonatomic, readonly) NSString *criteoPublisherId;
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

- (instancetype) initWithCriteoPublisherId:(NSString *) criteoPublisherId
NS_DESIGNATED_INITIALIZER;

- (instancetype) init NS_UNAVAILABLE;

/*
 * Helper function to convert NSData returned from a network call
 * to an NSDictionary with config values
 */
+ (NSDictionary *) getConfigValuesFromData: (NSData *) data;

@end

#endif /* CR_Config_h */
