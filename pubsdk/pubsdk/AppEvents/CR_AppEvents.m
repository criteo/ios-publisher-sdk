//
//  CR_AppEvents.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CR_AppEvents.h"

@implementation CR_AppEvents
{
    CR_ApiHandler *apiHandler;
    CR_DataProtectionConsent *gdpr;
    CR_Config *config;
    CR_DeviceInfo *deviceInfo;
}

- (instancetype) initWithApiHandler:(CR_ApiHandler *)apiHandler
                             config:(CR_Config *)config
                               gdpr:(CR_DataProtectionConsent *)gdpr
                         deviceInfo:(CR_DeviceInfo *)deviceInfo {
    if (self = [super init]) {
        self->apiHandler = apiHandler;
        self->config = config;
        self->gdpr = gdpr;
        self->deviceInfo = deviceInfo;
        _throttleSec = 0;
        _latestEventSent = [NSDate date];
        [self registerForIosEvents];
        [self sendLaunchEvent];
    }
    return self;
}

- (void) registerForIosEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendActiveEvent:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendInactiveEvent:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void) sendLaunchEvent {
    [self sendEvent:@"Launch"];
}

- (void) sendActiveEvent:(NSNotification *) notification {
    if([[notification name] isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self sendEvent:@"Active"];
    }
}

- (void) sendInactiveEvent:(NSNotification *) notification {
    if([[notification name] isEqualToString:UIApplicationWillResignActiveNotification]) {
        [self sendEvent:@"Inactive"];
    }
}

- (BOOL) throttleExpired {
    return [[NSDate date]timeIntervalSinceReferenceDate] - [_latestEventSent timeIntervalSinceReferenceDate]
    >= [self throttleSec];
}

- (void) updateAppEventValues:(NSDictionary *) appEventValues
                   receivedAt:(NSDate *) date {
    _latestEventSent = date;
    if(appEventValues && appEventValues[@"throttleSec"]
       && [appEventValues[@"throttleSec"] isKindOfClass:[NSNumber class]]) {
        _throttleSec = [appEventValues[@"throttleSec"] integerValue];
    }
}

- (void) sendEvent:(NSString *) event {
    if([self throttleExpired]) {
        [apiHandler sendAppEvent:event
                     gdprConsent:gdpr
                          config:config
                      deviceInfo:deviceInfo
                  ahEventHandler:^(NSDictionary *appEventValues, NSDate *receivedAt) {
                      [self updateAppEventValues:appEventValues receivedAt:receivedAt];
                  }];
    }
}

- (void) dealloc {
    [self deRegisterForIosEvents];
}

- (void) deRegisterForIosEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}

@end
