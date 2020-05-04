//
//  CR_FeedbackStorage.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_CacheAdUnit.h"
#import "CR_FeedbackStorage.h"
#import "CR_FeedbackFileManager.h"
#import "CASObjectQueue+ArraySet.h"
#import "CASBoundedFileObjectQueue.h"
#import "Logging.h"

@interface CR_FeedbackStorage()

@property (strong, nonatomic, readonly) CASObjectQueue<CR_FeedbackMessage *> *sendingQueue;
@property (strong, nonatomic, readonly) id<CR_FeedbackFileManaging> fileManaging;

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
    CR_FeedbackFileManager * fileManager = [[CR_FeedbackFileManager alloc] init];
    CASObjectQueue<CR_FeedbackMessage *> *queue =
        [[CASBoundedFileObjectQueue alloc] initWithAbsolutePath:fileManager.sendingQueueFilePath
                                                  maxFileLength:sendingQueueMaxSize
                                                          error:nil];
    return [self initWithFileManager:fileManager withQueue:queue];
}

- (instancetype)initWithFileManager:(id <CR_FeedbackFileManaging>)fileManaging
                          withQueue:(CASObjectQueue<CR_FeedbackMessage *> *)queue {
    if (self = [super init]) {
        _fileManaging = fileManaging;
        _sendingQueue = queue;
        [self moveAllFeedbackObjectsToSendingQueue];
    }
    return self;
}

- (NSArray<CR_FeedbackMessage *> *)popMessagesToSend {
    @synchronized (self) {
        NSUInteger size = [self.sendingQueue size];
        NSArray<CR_FeedbackMessage *> *messages = [self.sendingQueue peek:size];
        [self.sendingQueue pop:size];
        return messages;
    }
}

- (void)pushMessagesToSend:(NSArray<CR_FeedbackMessage *> *)messages {
    @synchronized (self) {
        for (CR_FeedbackMessage *message in messages) {
            [self.sendingQueue addFeedbackMessage:message];
        }
    }
}

- (void)updateMessageWithImpressionId:(NSString *)impressionId
                                   by:(void (^)(CR_FeedbackMessage *message))updateFunction {
    @synchronized (self) {
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
    if(!feedback) {
        feedback = [[CR_FeedbackMessage alloc] init];
    }
    return feedback;
}

- (void)moveAllFeedbackObjectsToSendingQueue {
    NSArray<NSString *> *filenames = [self.fileManaging allActiveFeedbackFilenames];
    for(NSString *filename in filenames) {
        [self moveFeedbackObjectToSendingQueue:filename];
    }
}

- (void)moveFeedbackObjectToSendingQueue:(NSString *)filename {
    @try {
        CR_FeedbackMessage *feedback = [self.fileManaging readFeedbackForFilename:filename];
        if (feedback) {
            [self.sendingQueue addFeedbackMessage:feedback];
        }
    }
    @catch (NSException *exception) {
        CLogException(exception);
    }
    @finally {
        [self.fileManaging removeFileForFilename:filename];
    }
}

@end
