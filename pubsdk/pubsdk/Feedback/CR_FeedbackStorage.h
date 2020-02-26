//
//  CR_FeedbackStorage.h
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 25/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_FeedbackFileManager.h"
#import <Cassette.h>

@class CR_FeedbackMessage;
@class CR_CacheAdUnit;

NS_ASSUME_NONNULL_BEGIN

@interface CR_FeedbackStorage : NSObject

- (instancetype)initWithFileManager:(id <CR_FeedbackFileManaging>)fileManaging
                          withQueue:(CASObjectQueue<CR_FeedbackMessage *> *)queue NS_DESIGNATED_INITIALIZER;

- (NSArray<CR_FeedbackMessage *> *)messagesReadyToSend;

- (void)removeMessages:(NSUInteger)amount;

/**
 Applies the updateFunction to the stored FeedbackMessage object associated with given cacheAdUnit.

 In case the object doesn't exists for given cacheAdUnit, it creates a new empty object before updating.
 */
- (void)updateMessageWithAdUnit:(CR_CacheAdUnit *)adUnit by:(void (^)(CR_FeedbackMessage *message))updateFunction;

@end

NS_ASSUME_NONNULL_END
