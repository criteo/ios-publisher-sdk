//
//  CR_DependencyProvider.h
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

#import <Foundation/Foundation.h>

@protocol CR_FeedbackDelegate;
@class CR_FeedbackStorage;
@class CR_ThreadManager;
@class CR_HeaderBidding;
@class CR_AppEvents;
@class CR_DataProtectionConsent;
@class CR_DeviceInfo;
@class CR_IntegrationRegistry;
@class CR_Config;
@class CR_ConfigManager;
@class CR_CacheManager;
@class CR_ApiHandler;
@class CR_NetworkManager;
@class CR_BidFetchTracker;
@class CR_BidManager;
@class CR_ImageCache;
@class CR_DisplaySizeInjector;
@class CR_UserDataHolder;
@class CR_InternalContextProvider;
@class CR_Session;
@class CR_Logging;
@class CR_ConsoleLogHandler;
@class CR_RemoteLogHandler;
@protocol CRMediaDownloader;

NS_ASSUME_NONNULL_BEGIN

@interface CR_DependencyProvider : NSObject

@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) CR_ThreadManager *threadManager;
@property(nonatomic, strong) CR_BidFetchTracker *bidFetchTracker;
@property(nonatomic, strong) CR_NetworkManager *networkManager;
@property(nonatomic, strong) CR_ApiHandler *apiHandler;
@property(nonatomic, strong) CR_CacheManager *cacheManager;
@property(nonatomic, strong) CR_IntegrationRegistry *integrationRegistry;
@property(nonatomic, strong) CR_Config *config;
@property(nonatomic, strong) CR_ConfigManager *configManager;
@property(nonatomic, strong) CR_DeviceInfo *deviceInfo;
@property(nonatomic, strong) CR_DataProtectionConsent *consent;
@property(nonatomic, strong) CR_AppEvents *appEvents;
@property(nonatomic, strong) CR_HeaderBidding *headerBidding;
@property(nonatomic, strong) CR_FeedbackStorage *feedbackStorage;
@property(nonatomic, strong) id<CR_FeedbackDelegate> feedbackDelegate;
@property(nonatomic, strong) CR_BidManager *bidManager;
@property(nonatomic, strong) id<CRMediaDownloader> mediaDownloader;
@property(nonatomic, strong) CR_ImageCache *imageCache;
@property(nonatomic, strong) CR_DisplaySizeInjector *displaySizeInjector;
@property(nonatomic, strong) CR_UserDataHolder *userDataHolder;
@property(nonatomic, strong) CR_InternalContextProvider *internalContextProvider;
@property(nonatomic, strong) CR_Session *session;
@property(nonatomic, strong) CR_Logging *logging;
@property(nonatomic, strong) CR_ConsoleLogHandler *consoleLogHandler;
@property(nonatomic, strong) CR_RemoteLogHandler *remoteLogHandler;

@end

NS_ASSUME_NONNULL_END
