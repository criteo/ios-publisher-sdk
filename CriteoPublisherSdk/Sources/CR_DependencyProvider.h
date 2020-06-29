//
//  CR_DependencyProvider.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CR_FeedbackDelegate;
@class CR_FeedbackStorage;
@class CR_ThreadManager;
@class CR_HeaderBidding;
@class CR_AppEvents;
@class CR_DataProtectionConsent;
@class CR_DeviceInfo;
@class CR_ConfigManager;
@class CR_Config;
@class CR_TokenCache;
@class CR_CacheManager;
@class CR_ApiHandler;
@class CR_NetworkManager;
@class CR_BidFetchTracker;
@class CR_BidManager;
@class CR_ImageCache;
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
@property(nonatomic, strong) CR_TokenCache *tokenCache;
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

@end

NS_ASSUME_NONNULL_END
