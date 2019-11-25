//
//  CR_BidManagerBuilder.h
//  pubsdk
//
//  Created by Romain Lofaso on 11/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_BidManager.h"

@class CR_NetworkManager;
@class CR_ApiHandler;
@class CR_CacheManager;
@class CR_TokenCache;
@class CR_Config;
@class CR_ConfigManager;
@class CR_DeviceInfo;
@class CR_GdprUserConsent;
@class CR_AppEvents;

NS_ASSUME_NONNULL_BEGIN

@interface CR_BidManagerBuilder : NSObject

@property (nonatomic, copy) NSString *criteoPublisherId;
@property (nonatomic, strong) CR_BidFetchTracker *bidFetchTracker;
@property (nonatomic, strong) CR_NetworkManager *networkManager;
@property (nonatomic, strong) CR_ApiHandler *apiHandler;
@property (nonatomic, strong) CR_CacheManager *cacheManager;
@property (nonatomic, strong) CR_TokenCache *tokenCache;
@property (nonatomic, strong) CR_Config *config;
@property (nonatomic, strong) CR_ConfigManager *configManager;
@property (nonatomic, strong) CR_DeviceInfo *deviceInfo;
@property (nonatomic, strong) CR_GdprUserConsent *gdprUserConsent;
@property (nonatomic, strong) CR_AppEvents *appEvents;
@property (nonatomic, assign) NSTimeInterval timeToNextCall;

- (CR_BidManager *)buildBidManager;

@end

NS_ASSUME_NONNULL_END
