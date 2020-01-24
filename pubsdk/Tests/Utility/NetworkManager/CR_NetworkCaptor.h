//
//  CR_NetworkCaptor.h
//  pubsdkTests
//
//  Created by Romain Lofaso on 11/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"
#import "CR_HttpContent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CR_HTTPRequestListener)(NSURL *url, CR_HTTPVerb verb, NSDictionary * _Nullable body);
typedef void (^CR_HTTPResponseListener)(CR_HttpContent *httpContent);

/**
 NetworkManager class that is used for a man-in-the-middle approach in the test.
 Note: The name and the approach is similar in Android.
 */
@interface CR_NetworkCaptor : CR_NetworkManager

@property (nonatomic, strong, readonly) CR_NetworkManager *networkManager;

@property (nonatomic, copy, readonly) NSArray<CR_HttpContent *> *allRequests;
@property (nonatomic, copy, readonly) NSArray<CR_HttpContent *> *finishedRequests;
@property (nonatomic, copy, readonly) NSArray<CR_HttpContent *> *pendingRequests;
/**
 Listener that is called each time that the NetworkManager launch a request.
 */
@property (nonatomic, copy, nullable) CR_HTTPRequestListener requestListener;
/**
 Listener that is called each time that the NetworkManager get a response and store in the history.
 */
@property (nonatomic, copy, nullable) CR_HTTPResponseListener responseListener;

- (instancetype)initWithDeviceInfo:(CR_DeviceInfo*)deviceInfo NS_UNAVAILABLE;
- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
