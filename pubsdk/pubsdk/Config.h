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

// should be provided when init is called by the publisher
// move to bid manager
@property (strong, nonatomic, readonly) NSNumber *networkId;
@property (strong, nonatomic, readonly) NSNumber *profileId;
@property (strong, nonatomic, readonly) NSString *cdbUrl;
@property (strong, nonatomic, readonly) NSString *path;

@end

#endif /* Config_h */
