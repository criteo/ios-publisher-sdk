//
//  CR_BidManagerBuilder.m
//  pubsdk
//
//  Created by Romain Lofaso on 11/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_BidManagerBuilder.h"
#import "CR_ThreadManager.h"
#import "CR_FeedbackController.h"


@implementation CR_BidManagerBuilder

- (NSUserDefaults *)userDefaults {
    if (_userDefaults == nil) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}

- (NSNotificationCenter *)notificationCenter {
    if (_notificationCenter == nil) {
        _notificationCenter = [NSNotificationCenter defaultCenter];
    }
    return _notificationCenter;
}

- (CR_ThreadManager *)threadManager {
    if (_threadManager == nil) {
        _threadManager = [[CR_ThreadManager alloc] init];
    }
    return _threadManager;
}

- (CR_BidFetchTracker *)bidFetchTracker {
    if (_bidFetchTracker == nil) {
        _bidFetchTracker = [[CR_BidFetchTracker alloc] init];
    }
    return _bidFetchTracker;
}

- (CR_NetworkManager *)networkManager {
    if (_networkManager == nil) {
        _networkManager = [[CR_NetworkManager alloc] initWithDeviceInfo:self.deviceInfo];
    }
    return _networkManager;
}

- (CR_ApiHandler *)apiHandler {
    if (_apiHandler == nil) {
        _apiHandler = [[CR_ApiHandler alloc] initWithNetworkManager:self.networkManager
                                                    bidFetchTracker:self.bidFetchTracker
                                                      threadManager:self.threadManager];
    }
    return _apiHandler;
}

- (CR_CacheManager *)cacheManager {
    if (_cacheManager == nil) {
        _cacheManager = [[CR_CacheManager alloc] init];
    }
    return _cacheManager;
}

- (CR_TokenCache *)tokenCache {
    if (_tokenCache == nil) {
        _tokenCache = [[CR_TokenCache alloc] init];
    }
    return _tokenCache;
}

- (CR_Config *)config {
    if (_config == nil) {
        _config = [[CR_Config alloc] initWithUserDefaults:self.userDefaults];
    }
    return _config;
}

- (CR_ConfigManager *)configManager {
    if (_configManager == nil) {
        _configManager = [[CR_ConfigManager alloc] initWithApiHandler:self.apiHandler
                                                          userDefault:self.userDefaults];
    }
    return _configManager;
}

- (CR_DeviceInfo *)deviceInfo {
    if (_deviceInfo == nil) {
        _deviceInfo = [[CR_DeviceInfo alloc] initWithThreadManager:self.threadManager];
    }
    return _deviceInfo;
}

- (CR_DataProtectionConsent *)consent {
    if (_consent == nil) {
        _consent = [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults];
    }
    return _consent;
}

- (CR_AppEvents *)appEvents {
    if (_appEvents == nil) {
        _appEvents = [[CR_AppEvents alloc] initWithApiHandler:self.apiHandler
                                                       config:self.config
                                                      consent:self.consent
                                                   deviceInfo:self.deviceInfo
                                           notificationCenter:self.notificationCenter];
    }
    return _appEvents;
}

- (CR_FeedbackStorage *)feedbackStorage {
    if (_feedbackStorage == nil) {
        _feedbackStorage = [[CR_FeedbackStorage alloc] init];
    }
    return _feedbackStorage;
}

- (id <CR_FeedbackDelegate>)feedbackDelegate {
    if (_feedbackDelegate == nil) {
        _feedbackDelegate = [[CR_FeedbackController alloc] initWithFeedbackStorage:self.feedbackStorage
                                                                        apiHandler:self.apiHandler
                                                                            config:self.config];
    }
    return _feedbackDelegate;
}

- (CR_BidManager *)buildBidManager {
    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:self.apiHandler
                                                             cacheManager:self.cacheManager
                                                               tokenCache:self.tokenCache
                                                                   config:self.config
                                                            configManager:self.configManager
                                                               deviceInfo:self.deviceInfo
                                                                  consent:self.consent
                                                           networkManager:self.networkManager
                                                                appEvents:self.appEvents
                                                           timeToNextCall:self.timeToNextCall
                                                          feedbackDelegate:self.feedbackDelegate];
    return bidManager;
}

@end
