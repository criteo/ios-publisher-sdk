//
//  CR_NetworkManager.h
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

/**
 * Send POST request with JSON body
 * @param url Request URL
 * @param body Object to serialize and post as JSON
 * @param logTag If not nil, logs request / response payloads
 * @param responseHandler Response handler
 */
- (void)postToUrl:(NSURL *)url
               body:(id)body
         logWithTag:(NSString *_Nullable)logTag
    responseHandler:(nullable CR_NMResponse)responseHandler;

- (void)postToUrl:(NSURL *)url
               body:(id)body
    responseHandler:(nullable CR_NMResponse)responseHandler;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_NetworkManager_h */
