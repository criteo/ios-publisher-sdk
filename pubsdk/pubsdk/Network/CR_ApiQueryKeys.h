//
//  CR_ApiQueryKeys.h
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 29/11/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CR_ApiQueryKeys : NSObject

@property (class, nonatomic, readonly) NSString *appId;
@property (class, nonatomic, readonly) NSString *sdkVersion;
@property (class, nonatomic, readonly) NSString *idfa;
@property (class, nonatomic, readonly) NSString *limitedAdTracking;
@property (class, nonatomic, readonly) NSString *eventType;

@end
