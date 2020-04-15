//
//  CR_ThreadManager.m
//  pubsdk
//
//  Created by Romain Lofaso on 1/29/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#include <libkern/OSAtomic.h>
#import "CR_ThreadManager.h"
#import "Logging.h"

@interface CR_ThreadManager ()

@property (nonatomic, assign) NSInteger blockInProgressCounter;

@end

@implementation CR_ThreadManager

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsIdle {
    return [[NSSet alloc] initWithObjects:NSStringFromSelector(@selector(blockInProgressCounter)), nil];
}

- (BOOL)isIdle {
    return (self.blockInProgressCounter == 0);
}

- (void)dispatchAsyncOnGlobalQueue:(dispatch_block_t)block {
    if (block == nil) return;

    @synchronized (self) {
        self.blockInProgressCounter += 1;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            block();
        }
        @catch (NSException *exception) {
            CLogException(exception);
        }
        @finally {
            @synchronized (self) {
                self.blockInProgressCounter -= 1;
            }
        }
    });
}

@end
