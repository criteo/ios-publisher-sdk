//
//  CR_BidManagerBuilder+Testing.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_BidManagerBuilder+Testing.h"
#import "CR_Config.h"
#import "CR_FeedbackFileManager.h"
#import "CR_InMemoryUserDefaults.h"
#import "CR_NetworkManagerDecorator.h"
#import "Criteo+Testing.h"
#import "pubsdkTests-Swift.h"

@implementation CR_BidManagerBuilder (Testing)

+ (instancetype)testing_bidManagerBuilder {
    return CR_BidManagerBuilder.new .withIsolatedUserDefaults
                                    .withIsolatedDeviceInfo
                                    .withPreprodConfiguration
                                    .withListenedNetworkManager
                                    .withIsolatedNotificationCenter
                                    .withIsolatedFeedbackStorage;
}

- (CR_BidManagerBuilder *)withListenedNetworkManager {
    CR_NetworkManagerDecorator *decorator = [CR_NetworkManagerDecorator decoratorFromConfiguration:self.config];
    self.networkManager = [decorator decorateNetworkManager:self.networkManager];
    return self;
}

- (CR_BidManagerBuilder *)withPreprodConfiguration {
    CR_Config *config = [CR_Config configForTestWithCriteoPublisherId:CriteoTestingPublisherId
                                                            userDefaults:self.userDefaults];
    self.config = config;
    return self;
}

- (CR_BidManagerBuilder *)withIsolatedDeviceInfo {
    self.deviceInfo = [[CR_DeviceInfoMock alloc] init];
    return self;
}

- (CR_BidManagerBuilder *)withIsolatedNotificationCenter {
    self.notificationCenter = [[NSNotificationCenter alloc] init];
    return self;
}

- (CR_BidManagerBuilder *)withIsolatedFeedbackStorage {
    CR_FeedbackFileManagingMock *feedbackFileManagingMock = [[CR_FeedbackFileManagingMock alloc] init];
    feedbackFileManagingMock.useReadWriteDictionary = YES;
    CASInMemoryObjectQueue *feedbackSendingQueue = [[CASInMemoryObjectQueue alloc] init];
    CR_FeedbackStorage *feedbackStorage = [[CR_FeedbackStorage alloc] initWithFileManager:feedbackFileManagingMock
                                                                                withQueue:feedbackSendingQueue];
    self.feedbackStorage = feedbackStorage;
    return self;
}

- (CR_BidManagerBuilder *)withIsolatedUserDefaults {
    self.userDefaults = [[CR_InMemoryUserDefaults alloc] init];
    return self;
}

@end
