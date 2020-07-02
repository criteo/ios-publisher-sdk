//
//  CR_NetworkCaptor.h
//  CriteoPublisherSdkTests
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

#import "CR_NetworkManager.h"
#import "CR_HttpContent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CR_HTTPRequestListener)(NSURL *url, CR_HTTPVerb verb, NSDictionary *_Nullable body);
typedef void (^CR_HTTPResponseListener)(CR_HttpContent *httpContent);

/**
 NetworkManager class that is used for a man-in-the-middle approach in the test.
 Note: The name and the approach is similar in Android.
 */
@interface CR_NetworkCaptor : CR_NetworkManager

@property(nonatomic, strong, readonly) CR_NetworkManager *networkManager;

@property(nonatomic, copy, readonly) NSArray<CR_HttpContent *> *allRequests;
@property(nonatomic, copy, readonly) NSArray<CR_HttpContent *> *finishedRequests;
@property(nonatomic, copy, readonly) NSArray<CR_HttpContent *> *pendingRequests;
/**
 Listener that is called each time that the NetworkManager launch a request.
 */
@property(nonatomic, copy, nullable) CR_HTTPRequestListener requestListener;
/**
 Listener that is called each time that the NetworkManager get a response and store in the history.
 */
@property(nonatomic, copy, nullable) CR_HTTPResponseListener responseListener;

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo NS_UNAVAILABLE;

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo
                           session:(NSURLSession *)session
                     threadManager:(CR_ThreadManager *)threadManager NS_UNAVAILABLE;

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
    NS_DESIGNATED_INITIALIZER;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
