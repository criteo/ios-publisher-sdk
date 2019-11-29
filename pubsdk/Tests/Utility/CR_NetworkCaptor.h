//
//  CR_NetworkCaptor.h
//  pubsdkTests
//
//  Created by Romain Lofaso on 11/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

@class CR_HttpContent;

typedef enum {
    GET,
    POST
} CR_HTTPVerb;

typedef void (^CR_HTTPRequestListener)(NSURL *url, CR_HTTPVerb verb, NSDictionary * _Nullable body);
typedef void (^CR_HTTPResponseListener)(CR_HttpContent *httpContent);

/**
 NetworkManager class that is used for a man-in-the-middle approach in the test.
 Note: The name and the approach is similar in Android.
 */
@interface CR_NetworkCaptor : CR_NetworkManager

@property (nonatomic, strong, readonly) CR_NetworkManager *networkManager;
/**
 History from the request perspective.
 */
@property (nonatomic, copy, readonly) NSArray<CR_HttpContent *> *history;
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

/**
 Wrapper for the HTTP request and HTTP the response .
 */
@interface CR_HttpContent: NSObject

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, assign, readonly) CR_HTTPVerb verb;
@property (nonatomic, copy, readonly) NSDictionary * requestBody;
@property (nonatomic, copy, readonly) NSData *responseBody;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, assign, readonly) unsigned counter;

- (instancetype)initWithUrl:(NSURL *)url
                       verb:(CR_HTTPVerb)verb
                requestBody:(nullable NSDictionary *)requestBody
               responseBody:(nullable NSData *)responseBody
                      error:(nullable NSError *)error
                    counter:(unsigned)counter;

@end


NS_ASSUME_NONNULL_END
