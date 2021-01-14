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
#import "CR_CacheManager.h"
#import "CR_BidManager.h"
#import "CR_DefaultMediaDownloader.h"
#import "CR_ImageCache.h"
#import "CR_DisplaySizeInjector.h"
#import "CR_IntegrationRegistry.h"
#import "CR_UserDataHolder.h"
#import "CR_InternalContextProvider.h"
#import "CR_Session.h"
#import "CR_Logging.h"
#import "CR_RemoteLogHandler.h"
#import "CR_RemoteLogStorage.h"

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
  return CR_LAZY(_apiHandler,
                 [[CR_ApiHandler alloc] initWithNetworkManager:self.networkManager
                                               bidFetchTracker:self.bidFetchTracker
                                                 threadManager:self.threadManager
                                           integrationRegistry:self.integrationRegistry
                                                userDataHolder:self.userDataHolder
                                       internalContextProvider:self.internalContextProvider]);
}

- (CR_CacheManager *)cacheManager {
  return CR_LAZY(_cacheManager, [[CR_CacheManager alloc] init]);
}

- (CR_IntegrationRegistry *)integrationRegistry {
  return CR_LAZY(_integrationRegistry,
                 [[CR_IntegrationRegistry alloc] initWithUserDefaults:self.userDefaults]);
}

- (CR_Config *)config {
  return CR_LAZY(_config, [[CR_Config alloc] initWithUserDefaults:self.userDefaults]);
}

- (CR_ConfigManager *)configManager {
  return CR_LAZY(_configManager,
                 [[CR_ConfigManager alloc] initWithApiHandler:self.apiHandler
                                          integrationRegistry:self.integrationRegistry
                                                   deviceInfo:self.deviceInfo]);
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
                                                               config:self.config
                                                              consent:self.consent]);
}

- (CR_BidManager *)bidManager {
  return CR_LAZY(_bidManager, [[CR_BidManager alloc] initWithApiHandler:self.apiHandler
                                                           cacheManager:self.cacheManager
                                                                 config:self.config
                                                             deviceInfo:self.deviceInfo
                                                                consent:self.consent
                                                         networkManager:self.networkManager
                                                          headerBidding:self.headerBidding
                                                       feedbackDelegate:self.feedbackDelegate
                                                          threadManager:self.threadManager
                                                       remoteLogHandler:self.remoteLogHandler]);
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

- (CR_UserDataHolder *)userDataHolder {
  return CR_LAZY(_userDataHolder, CR_UserDataHolder.new);
}

- (CR_Session *)session {
  return CR_LAZY(_session, [[CR_Session alloc] initWithStartDate:[NSDate date]]);
}

- (CR_InternalContextProvider *)internalContextProvider {
  return CR_LAZY(_internalContextProvider,
                 [[CR_InternalContextProvider alloc] initWithSession:self.session]);
}

- (CR_Logging *)logging {
  return CR_LAZY(_logging, ({
                   [[CR_Logging alloc]
                       initWithLogHandler:[[CR_MultiplexLogHandler alloc] initWithLogHandlers:@[
                         self.consoleLogHandler, self.remoteLogHandler
                       ]]];
                 }));
}

- (CR_ConsoleLogHandler *)consoleLogHandler {
  return CR_LAZY(_consoleLogHandler, CR_ConsoleLogHandler.new);
}

- (CR_RemoteLogHandler *)remoteLogHandler {
  return CR_LAZY(_remoteLogHandler,
                 [[CR_RemoteLogHandler alloc] initWithRemoteLogStorage:CR_RemoteLogStorage.new
                                                                config:self.config
                                                            deviceInfo:self.deviceInfo
                                                   integrationRegistry:self.integrationRegistry
                                                               session:self.session
                                                               consent:self.consent
                                                            apiHandler:self.apiHandler
                                                         threadManager:self.threadManager]);
}

@end

#undef CR_LAZY
