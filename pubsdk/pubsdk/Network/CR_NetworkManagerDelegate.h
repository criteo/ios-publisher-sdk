//
//  CR_NetworkManagerDelegate.h
//  pubsdk
//
//  Created by Paul Davis on 2/5/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_NetworkManagerDelegate_h
#define CR_NetworkManagerDelegate_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CR_NetworkManager;

@protocol CR_NetworkManagerDelegate <NSObject>

- (void) networkManager:(CR_NetworkManager*)manager sentRequest:(NSURLRequest*)request;
- (void) networkManager:(CR_NetworkManager*)manager receivedResponse:(NSURLResponse*)response withData:(NSData*)data error:(NSError*)error;

@end

NS_ASSUME_NONNULL_END

#endif /* CR_NetworkManagerDelegate_h */
