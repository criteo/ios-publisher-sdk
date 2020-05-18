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

typedef void (^CR_NMResponse)(NSData *data, NSError *error);

@interface CR_NetworkManager : NSObject

@property (nonatomic) id<CR_NetworkManagerDelegate> delegate;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithDeviceInfo:(CR_DeviceInfo*)deviceInfo;
- (instancetype) initWithDeviceInfo:(CR_DeviceInfo *)deviceInfo session:(NSURLSession *)session NS_DESIGNATED_INITIALIZER;

- (void) getFromUrl:(NSURL *) url
    responseHandler:(CR_NMResponse) responseHandler;

// Assumes all POST calls are made via JSON
- (void) postToUrl:(NSURL *) url
          postBody:(NSDictionary *) postBody
   responseHandler:(CR_NMResponse) responseHandler;

@end

#endif /* CR_NetworkManager_h */
