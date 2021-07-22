//
//  CR_FeedbackStorage.m
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

#import "CR_CacheAdUnit.h"
#import "CR_FeedbackStorage.h"
#import "CR_FeedbackFileManager.h"
#import "CR_CASObjectQueue+ArraySet.h"
#import "CR_CASBoundedFileObjectQueue.h"
#import "CR_Logging.h"

@interface CR_FeedbackStorage ()

@property(strong, nonatomic, readonly) CR_CASObjectQueue<CR_FeedbackMessage *> *sendingQueue;
@property(strong, nonatomic, readonly) id<CR_FeedbackFileManaging> fileManaging;

@end

// Maximum size (in bytes) of metric elements stored in the metric sending queue.
// 200KB represents ~360 metrics (with ~556 bytes/metric) which already represent an extreme case.
// Setting a bit more to have some margin, which we can as 256KB is still relatively small
static NSUInteger const CR_FeedbackStorageSendingQueueMaxSize = 256 * 1024;

@implementation CR_FeedbackStorage

- (instancetype)init {
  return [self initWithSendingQueueMaxSize:CR_FeedbackStorageSendingQueueMaxSize];
}

- (instancetype)initWithSendingQueueMaxSize:(NSUInteger)sendingQueueMaxSize {
  return [self initWithSendingQueueMaxSize:sendingQueueMaxSize
                               fileManager:[[CR_FeedbackFileManager alloc] init]];
}

- (instancetype)initWithSendingQueueMaxSize:(NSUInteger)sendingQueueMaxSize
                                fileManager:(id<CR_FeedbackFileManaging>)fileManager {
  CR_CASObjectQueue<CR_FeedbackMessage *> *queue = nil;
  @try {
    queue = [self buildSendingQueueWithMaxSize:sendingQueueMaxSize fileManager:fileManager];
  } @catch (NSException *exception) {
    CRLogException(@"Metrics", exception, @"Failed initializing metrics queue");
    // Try to recover by deleting potentially corrupted file
    [fileManager removeSendingQueueFile];
    queue = [self buildSendingQueueWithMaxSize:sendingQueueMaxSize fileManager:fileManager];
  }
  return [self initWithFileManager:fileManager withQueue:queue];
}

- (CR_CASObjectQueue<CR_FeedbackMessage *> *)
    buildSendingQueueWithMaxSize:(NSUInteger)sendingQueueMaxSize
                     fileManager:(CR_FeedbackFileManager *)fileManager {
  return [[CR_CASBoundedFileObjectQueue alloc] initWithAbsolutePath:fileManager.sendingQueueFilePath
                                                      maxFileLength:sendingQueueMaxSize
                                                              error:nil];
}

- (instancetype)initWithFileManager:(id<CR_FeedbackFileManaging>)fileManaging
                          withQueue:(CR_CASObjectQueue<CR_FeedbackMessage *> *)queue {
  if (self = [super init]) {
    _fileManaging = fileManaging;
    _sendingQueue = queue;
    [self moveAllFeedbackObjectsToSendingQueue];
  }
  return self;
}

- (NSArray<CR_FeedbackMessage *> *)popMessagesToSend {
  @synchronized(self) {
    NSUInteger size = [self.sendingQueue size];
    NSError *error;
    NSArray<CR_FeedbackMessage *> *messages = [self.sendingQueue peek:size error:&error];
    [self.sendingQueue pop:size error:&error];
    return messages;
  }
}

- (void)pushMessagesToSend:(NSArray<CR_FeedbackMessage *> *)messages {
  @synchronized(self) {
    for (CR_FeedbackMessage *message in messages) {
      [self.sendingQueue addFeedbackMessage:message];
    }
  }
}

- (void)updateMessageWithImpressionId:(NSString *)impressionId
                                   by:(void (^)(CR_FeedbackMessage *message))updateFunction {
  if (impressionId == nil) {
    return;
  }
  @synchronized(self) {
    CR_FeedbackMessage *feedback = [self readOrCreateFeedbackMessageByFilename:impressionId];
    updateFunction(feedback);
    if ([feedback isReadyToSend]) {
      [self.sendingQueue addFeedbackMessage:feedback];
      [self.fileManaging removeFileForFilename:impressionId];
    } else {
      [self.fileManaging writeFeedback:feedback forFilename:impressionId];
    }
  }
}

#pragma mark - Private methods

- (CR_FeedbackMessage *)readOrCreateFeedbackMessageByFilename:(NSString *)filename {
  CR_FeedbackMessage *feedback = [self.fileManaging readFeedbackForFilename:filename];
  if (!feedback) {
    feedback = [[CR_FeedbackMessage alloc] init];
  }
  return feedback;
}

- (void)moveAllFeedbackObjectsToSendingQueue {
  NSArray<NSString *> *filenames = [self.fileManaging allActiveFeedbackFilenames];
  for (NSString *filename in filenames) {
    [self moveFeedbackObjectToSendingQueue:filename];
  }
}

- (void)moveFeedbackObjectToSendingQueue:(NSString *)filename {
  @try {
    CR_FeedbackMessage *feedback = [self.fileManaging readFeedbackForFilename:filename];
    if (feedback) {
      [self.sendingQueue addFeedbackMessage:feedback];
    }
  } @catch (NSException *exception) {
    CRLogException(@"Metrics", exception, @"Failed moving metric to sending queue");
  } @finally {
    [self.fileManaging removeFileForFilename:filename];
  }
}

@end
