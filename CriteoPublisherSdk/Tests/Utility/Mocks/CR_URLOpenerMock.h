//
//  CR_URLOpenerMock.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_URLOpening.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_URLOpenerMock : NSObject <CR_URLOpening>

@property(assign, nonatomic) BOOL successInCompletion;
@property(assign, nonatomic) NSUInteger openExternalURLCount;

@end

NS_ASSUME_NONNULL_END
