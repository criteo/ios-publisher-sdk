//
//  Config.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/11/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef Config_h
#define Config_h

#import <Foundation/Foundation.h>

@interface Config : NSObject

@property (strong, nonatomic, readonly) NSNumber *networkId;
@property (strong, nonatomic, readonly) NSNumber *profileId;
@property (strong, nonatomic, readonly) NSString *cdbUrl;
@property (strong, nonatomic, readonly) NSString *path;
@property (strong, nonatomic, readonly) NSString *sdkVersion;
@property (strong, nonatomic, readonly) NSString *appId;
@property (nonatomic) BOOL killSwitch;
@property (strong, nonatomic, readonly) NSString *appEventsUrl;
@property (strong, nonatomic, readonly) NSString *appEventsSenderId;

- (instancetype) initWithNetworkId:(NSNumber *) networkId
NS_DESIGNATED_INITIALIZER;

- (instancetype) init NS_UNAVAILABLE;

/*
 * Helper function to convert NSData returned from a network call
 * to an NSDictionary with config values
 */
+ (NSDictionary *) getConfigValuesFromData: (NSData *) data;

@end

#endif /* Config_h */
