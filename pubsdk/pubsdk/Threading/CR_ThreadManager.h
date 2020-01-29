//
//  CR_ThreadManager.h
//  pubsdk
//
//  Created by Romain Lofaso on 1/29/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CR_ThreadManager : NSObject

@property (nonatomic, assign, readonly) BOOL isIdle;
@property (nonatomic, assign, readonly) NSInteger blockInProgressCounter;

- (void)dispatchAsyncOnGlobalQueue:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
