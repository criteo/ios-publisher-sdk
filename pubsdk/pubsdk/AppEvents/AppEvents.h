//
//  AppEvents.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef AppEvents_h
#define AppEvents_h

#import "ApiHandler.h"
#import "GdprUserConsent.h"
#import "Config.h"
#import "DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppEvents : NSObject

@property (readonly, nonatomic) NSUInteger throttleSec;
@property (readonly, nonatomic) NSDate *latestEventSent;
@property (readonly, nonatomic) BOOL throttleExpired;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithApiHandler: (ApiHandler *) apiHandler
                             config: (Config *) config
                               gdpr: (GdprUserConsent *) gdpr
                         deviceInfo: (DeviceInfo *) deviceInfo;
- (void) sendLaunchEvent;
- (void) sendActiveEvent:(NSNotification *) notification;
- (void) sendInactiveEvent:(NSNotification *) notification;

NS_ASSUME_NONNULL_END

@end

#endif /* AppEvents_h */
