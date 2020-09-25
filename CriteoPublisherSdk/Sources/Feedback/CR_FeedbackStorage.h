//
//  CR_FeedbackStorage.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import "Cassette.h"
#import "CR_FeedbackFileManager.h"

@class CR_FeedbackMessage;
@class CR_CacheAdUnit;

NS_ASSUME_NONNULL_BEGIN

@interface CR_FeedbackStorage : NSObject

- (instancetype)initWithFileManager:(id<CR_FeedbackFileManaging>)fileManaging
                          withQueue:(CR_CASObjectQueue<CR_FeedbackMessage *> *)queue
    NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithSendingQueueMaxSize:(NSUInteger)sendingQueueMaxSize;

- (NSArray<CR_FeedbackMessage *> *)popMessagesToSend;

- (void)pushMessagesToSend:(NSArray<CR_FeedbackMessage *> *)messages;

/**
 Applies the updateFunction to the stored FeedbackMessage object associated with given impressionId.

 In case the object doesn't exists, it creates a new empty object before updating.
 */
- (void)updateMessageWithImpressionId:(NSString *)impressionId
                                   by:(void (^)(CR_FeedbackMessage *message))updateFunction;

@end

NS_ASSUME_NONNULL_END
