//
//  CR_URLOpenerMock.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_URLOpening.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_URLOpenerMock : NSObject <CR_URLOpening>

@property (assign, nonatomic) BOOL successInCompletion;

@end

NS_ASSUME_NONNULL_END
