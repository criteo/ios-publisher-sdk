//
//  CR_AppEvents.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CR_AppEvents.h"

@interface CR_AppEvents ()

@property (strong, nonatomic, readonly) NSNotificationCenter *notificationCenter;

@end

@implementation CR_AppEvents
{
    CR_ApiHandler *apiHandler;
    CR_DataProtectionConsent *consent;
    CR_Config *config;
    CR_DeviceInfo *deviceInfo;
    BOOL _shouldThrottle;
}

- (instancetype)initWithApiHandler:(CR_ApiHandler *)apiHandler
                            config:(CR_Config *)config
                           consent:(CR_DataProtectionConsent *)consent
                        deviceInfo:(CR_DeviceInfo *)deviceInfo
                notificationCenter:(NSNotificationCenter *)notificationCenter {
    if (self = [super init]) {
        self->apiHandler = apiHandler;
        self->config = config;
        self->consent = consent;
        self->deviceInfo = deviceInfo;
        _throttleSec = 0;
        _latestEventSent = [NSDate date];
        _shouldThrottle = YES;
        _notificationCenter = notificationCenter;
    }
    return self;
}

- (void)registerForIosEvents {
    [self.notificationCenter addObserver:self
                                selector:@selector(sendActiveEvent:)
                                    name:UIApplicationDidBecomeActiveNotification
                                  object:nil];

    [self.notificationCenter addObserver:self
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
    BOOL expired = [[NSDate date]timeIntervalSinceReferenceDate] - [_latestEventSent timeIntervalSinceReferenceDate]
        >= [self throttleSec];
    return !_shouldThrottle || expired;
}

- (void) updateAppEventValues:(NSDictionary *) appEventValues
                   receivedAt:(NSDate *) date {
    _latestEventSent = date;
    if(appEventValues && appEventValues[@"throttleSec"]
       && [appEventValues[@"throttleSec"] isKindOfClass:[NSNumber class]]) {
        _throttleSec = [appEventValues[@"throttleSec"] integerValue];
    }
}

- (void)sendEvent:(NSString *)event {
    if([self throttleExpired] && self->consent.shouldSendAppEvent) {
        [apiHandler sendAppEvent:event
                         consent:consent
                          config:config
                      deviceInfo:deviceInfo
                  ahEventHandler:^(NSDictionary *appEventValues, NSDate *receivedAt) {
                      [self updateAppEventValues:appEventValues receivedAt:receivedAt];
                  }];
    }
}

- (void) dealloc {
    [_notificationCenter removeObserver:self];
}

- (void)disableThrottling {
    _shouldThrottle = NO;
}

@end
