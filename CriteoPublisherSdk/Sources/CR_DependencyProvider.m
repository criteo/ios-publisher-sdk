//
//  CR_DependencyProvider.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CR_DependencyProvider.h"
#import "CR_HeaderBidding.h"
#import "CR_FeedbackController.h"
#import "CR_ThreadManager.h"
#import "CR_FeedbackStorage.h"
#import "CR_AppEvents.h"
#import "CR_ConfigManager.h"
#import "CR_TokenCache.h"
#import "CR_CacheManager.h"
#import "CR_BidManager.h"
#import "CR_DefaultMediaDownloader.h"
#import "CR_ImageCache.h"
#import "CR_DisplaySizeInjector.h"
#import "CR_IntegrationRegistry.h"

#define CR_LAZY(object, assignment)  \
  ({                                 \
    @synchronized(self) {            \
      object = object ?: assignment; \
    }                                \
    object;                          \
  })

@implementation CR_DependencyProvider

- (NSUserDefaults *)userDefaults {
  return CR_LAZY(_userDefaults, [NSUserDefaults standardUserDefaults]);
}

- (NSNotificationCenter *)notificationCenter {
  return CR_LAZY(_notificationCenter, [NSNotificationCenter defaultCenter]);
}

- (CR_ThreadManager *)threadManager {
  return CR_LAZY(_threadManager, [[CR_ThreadManager alloc] init]);
}

- (CR_BidFetchTracker *)bidFetchTracker {
  return CR_LAZY(_bidFetchTracker, [[CR_BidFetchTracker alloc] init]);
}

- (CR_NetworkManager *)networkManager {
  return CR_LAZY(_networkManager, ({
                   NSURLSessionConfiguration *configuration =
                       [NSURLSessionConfiguration defaultSessionConfiguration];
                   NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
                   [[CR_NetworkManager alloc] initWithDeviceInfo:self.deviceInfo
                                                         session:session
                                                   threadManager:self.threadManager];
                 }));
}

- (CR_ApiHandler *)apiHandler {
  return CR_LAZY(_apiHandler, [[CR_ApiHandler alloc] initWithNetworkManager:self.networkManager
                                                            bidFetchTracker:self.bidFetchTracker
                                                              threadManager:self.threadManager]);
}

- (CR_CacheManager *)cacheManager {
  return CR_LAZY(_cacheManager, [[CR_CacheManager alloc] init]);
}

- (CR_TokenCache *)tokenCache {
  return CR_LAZY(_tokenCache, [[CR_TokenCache alloc] init]);
}

- (CR_IntegrationRegistry *)integrationRegistry {
  return CR_LAZY(_integrationRegistry,
                 [[CR_IntegrationRegistry alloc] initWithUserDefaults:self.userDefaults]);
}

- (CR_Config *)config {
  return CR_LAZY(_config, [[CR_Config alloc] initWithUserDefaults:self.userDefaults]);
}

- (CR_ConfigManager *)configManager {
  return CR_LAZY(_configManager, [[CR_ConfigManager alloc] initWithApiHandler:self.apiHandler]);
}

- (CR_DeviceInfo *)deviceInfo {
  return CR_LAZY(_deviceInfo, [[CR_DeviceInfo alloc] initWithThreadManager:self.threadManager]);
}

- (CR_DataProtectionConsent *)consent {
  return CR_LAZY(_consent,
                 [[CR_DataProtectionConsent alloc] initWithUserDefaults:self.userDefaults]);
}

- (CR_AppEvents *)appEvents {
  return CR_LAZY(_appEvents, [[CR_AppEvents alloc] initWithApiHandler:self.apiHandler
                                                               config:self.config
                                                              consent:self.consent
                                                           deviceInfo:self.deviceInfo
                                                   notificationCenter:self.notificationCenter]);
}

- (CR_HeaderBidding *)headerBidding {
  return CR_LAZY(_headerBidding,
                 [[CR_HeaderBidding alloc] initWithDevice:self.deviceInfo
                                      displaySizeInjector:self.displaySizeInjector
                                      integrationRegistry:self.integrationRegistry]);
}

- (CR_DisplaySizeInjector *)displaySizeInjector {
  return CR_LAZY(_displaySizeInjector,
                 [[CR_DisplaySizeInjector alloc] initWithDeviceInfo:self.deviceInfo]);
}

- (CR_FeedbackStorage *)feedbackStorage {
  return CR_LAZY(_feedbackStorage, [[CR_FeedbackStorage alloc] init]);
}

- (id<CR_FeedbackDelegate>)feedbackDelegate {
  return CR_LAZY(_feedbackDelegate,
                 [CR_FeedbackController controllerWithFeedbackStorage:self.feedbackStorage
                                                           apiHandler:self.apiHandler
                                                               config:self.config]);
}

- (CR_BidManager *)bidManager {
  return CR_LAZY(_bidManager, [[CR_BidManager alloc] initWithApiHandler:self.apiHandler
                                                           cacheManager:self.cacheManager
                                                             tokenCache:self.tokenCache
                                                                 config:self.config
                                                          configManager:self.configManager
                                                             deviceInfo:self.deviceInfo
                                                                consent:self.consent
                                                         networkManager:self.networkManager
                                                              appEvents:self.appEvents
                                                          headerBidding:self.headerBidding
                                                       feedbackDelegate:self.feedbackDelegate
                                                          threadManager:self.threadManager]);
}

- (id)mediaDownloader {
  return CR_LAZY(_mediaDownloader,
                 [[CR_DefaultMediaDownloader alloc] initWithNetworkManager:self.networkManager
                                                                imageCache:self.imageCache]);
}

- (CR_ImageCache *)imageCache {
  return CR_LAZY(_imageCache, ({
                   NSUInteger sizeLimit = 1024 * 1024 * 32;  // 32Mo
                   [[CR_ImageCache alloc] initWithSizeLimit:sizeLimit];
                 }));
}

@end

#undef CR_LAZY
