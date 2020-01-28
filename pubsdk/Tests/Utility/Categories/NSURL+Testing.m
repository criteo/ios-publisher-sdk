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

- (BOOL)testing_isBidUrlWithConfig:(CR_Config *)config {
    return [self.absoluteString containsString:config.cdbUrl];
}

- (BOOL)testing_isAppLaunchEventUrlWithConfig:(CR_Config *)config {
    return  [self.absoluteString containsString:config.appEventsUrl] &&
            [self.absoluteString containsString:@"eventType=Launch"];
}

- (BOOL)testing_isConfigEventUrlWithConfig:(CR_Config *)config {
    return [self.absoluteString containsString:config.configUrl];
}

@end
