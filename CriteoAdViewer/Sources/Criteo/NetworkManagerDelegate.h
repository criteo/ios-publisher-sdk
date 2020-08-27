//
//  NetworkManagerDelegate.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef NetworkManagerDelegate_h
#define NetworkManagerDelegate_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NetworkManager;

@protocol NetworkManagerDelegate <NSObject>

- (void)networkManager:(NetworkManager*)manager sentRequest:(NSURLRequest*)request;
- (void)networkManager:(NetworkManager*)manager
      receivedResponse:(NSURLResponse*)response
              withData:(NSData*)data
                 error:(NSError*)error;

@end

NS_ASSUME_NONNULL_END

#endif /* NetworkManagerDelegate_h */
