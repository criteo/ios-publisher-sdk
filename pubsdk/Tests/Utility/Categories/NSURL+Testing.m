//
//  NSURL+Testing.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/20/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "NSURL+Testing.h"

#import "CR_Config.h"

@implementation NSURL (Testing)

- (BOOL)testing_isFeedbackMessageUrlWithConfig:(CR_Config *)config {
    return  [self.absoluteString containsString:config.cdbUrl] &&
            [self.absoluteString containsString:config.csmPath];
}

- (BOOL)testing_isBidUrlWithConfig:(CR_Config *)config {
    return  [self.absoluteString containsString:config.cdbUrl] &&
            [self.absoluteString containsString:config.path];
}

- (BOOL)testing_isAppEventUrlWithConfig:(CR_Config *)config {
    return [self.absoluteString containsString:config.appEventsUrl];
}

- (BOOL)testing_isAppLaunchEventUrlWithConfig:(CR_Config *)config {
    return  [self testing_isAppEventUrlWithConfig:config] &&
            [self.absoluteString containsString:@"eventType=Launch"];
}

- (BOOL)testing_isConfigEventUrlWithConfig:(CR_Config *)config {
    return [self.absoluteString containsString:config.configUrl];
}

@end
