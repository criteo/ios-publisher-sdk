//
//  CR_FeedbackStorage.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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

- (instancetype)initWithSendingQueueMaxSize:(NSUInteger)sendingQueueMaxSize;

- (NSArray<CR_FeedbackMessage *> *)popMessagesToSend;

- (void)pushMessagesToSend:(NSArray<CR_FeedbackMessage *> *)messages;

/**
 Applies the updateFunction to the stored FeedbackMessage object associated with given impressionId.

 In case the object doesn't exists, it creates a new empty object before updating.
 */
- (void)updateMessageWithImpressionId:(NSString *)impressionId by:(void (^)(CR_FeedbackMessage *message))updateFunction;

@end

NS_ASSUME_NONNULL_END
