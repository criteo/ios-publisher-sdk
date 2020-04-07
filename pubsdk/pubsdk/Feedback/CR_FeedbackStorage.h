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

- (NSArray<CR_FeedbackMessage *> *)popMessagesToSend;

- (void)pushMessagesToSend:(NSArray<CR_FeedbackMessage *> *)messages;

/**
 Applies the updateFunction to the stored FeedbackMessage object associated with given impressionId.

 In case the object doesn't exists, it creates a new empty object before updating.
 */
- (void)updateMessageWithImpressionId:(NSString *)impressionId by:(void (^)(CR_FeedbackMessage *message))updateFunction;

@end

NS_ASSUME_NONNULL_END
