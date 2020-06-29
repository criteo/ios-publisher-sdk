//
//  CR_NetworkManager.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
//  Handles all network calls for pub-sdk code

#ifndef CR_NetworkManager_h
#define CR_NetworkManager_h

#import <Foundation/Foundation.h>

#import "CR_DeviceInfo.h"
#import "CR_NetworkManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CR_NMResponse)(NSData *_Nullable data, NSError *_Nullable error);

@interface CR_NetworkManager : NSObject

@property(nonatomic) id<CR_NetworkManagerDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo;
- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo
                           session:(NSURLSession *)session
                     threadManager:(CR_ThreadManager *)threadManager NS_DESIGNATED_INITIALIZER;

- (void)getFromUrl:(NSURL *)url responseHandler:(nullable CR_NMResponse)responseHandler;

// Assumes all POST calls are made via JSON
- (void)postToUrl:(NSURL *)url
           postBody:(NSDictionary *)postBody
    responseHandler:(nullable CR_NMResponse)responseHandler;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_NetworkManager_h */
