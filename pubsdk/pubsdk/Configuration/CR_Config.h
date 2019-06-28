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

@property (strong, nonatomic, readonly) NSString *criteoPublisherId;
@property (strong, nonatomic, readonly) NSNumber *profileId;
@property (strong, nonatomic, readonly) NSString *cdbUrl;
@property (strong, nonatomic, readonly) NSString *path;
@property (strong, nonatomic, readonly) NSString *sdkVersion;
@property (strong, nonatomic, readonly) NSString *appId;
@property (nonatomic) BOOL killSwitch;
@property (strong, nonatomic) NSString *adTagUrlMode;
@property (strong, nonatomic) NSString *viewportWidthMacro;
@property (strong, nonatomic) NSString *displayURLMacro;
@property (strong, nonatomic, readonly) NSString *appEventsUrl;
@property (strong, nonatomic, readonly) NSString *appEventsSenderId;
@property (strong, nonatomic, readonly) NSString *deviceModel;
@property (strong, nonatomic, readonly) NSString *osVersion;
@property (strong, nonatomic, readonly) NSString *deviceOs;

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
