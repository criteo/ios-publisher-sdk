//
//  CR_AppEvents.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_AppEvents_h
#define CR_AppEvents_h

#import "CR_ApiHandler.h"
#import "CR_GdprUserConsent.h"
#import "CR_Config.h"
#import "CR_DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_AppEvents : NSObject

@property (readonly, nonatomic) NSUInteger throttleSec;
@property (readonly, nonatomic) NSDate *latestEventSent;
@property (readonly, nonatomic) BOOL throttleExpired;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithApiHandler: (CR_ApiHandler *) apiHandler
                             config: (CR_Config *) config
                               gdpr: (CR_GdprUserConsent *) gdpr
                         deviceInfo: (CR_DeviceInfo *) deviceInfo;
- (void) sendLaunchEvent;
- (void) sendActiveEvent:(NSNotification *) notification;
- (void) sendInactiveEvent:(NSNotification *) notification;

NS_ASSUME_NONNULL_END

@end

#endif /* CR_AppEvents_h */
