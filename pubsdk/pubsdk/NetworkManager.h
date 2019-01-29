//
//  NetworkManager.h
//  pubsdk
//
//  Copyright © 2018 Criteo. All rights reserved.
//
//  Handles all network calls for pub-sdk code

#ifndef NetworkManager_h
#define NetworkManager_h

#import <Foundation/Foundation.h>

#import "DeviceInfo.h"

typedef void (^NMResponse)(NSData *data, NSError *error);

@interface NetworkManager : NSObject

@property (strong, nonatomic) NSURLSessionConfiguration *config;
@property (strong, nonatomic) NSURLSession *session;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithDeviceInfo:(DeviceInfo*)deviceInfo NS_DESIGNATED_INITIALIZER;

- (void) getFromUrl:(NSURL *) url
    responseHandler:(NMResponse) responseHandler;

// Assumes all POST calls are made via JSON
- (void) postToUrl:(NSURL *) url
          postBody:(NSDictionary *) postBody
   responseHandler:(NMResponse) responseHandler;

@end

#endif /* NetworkManager_h */
