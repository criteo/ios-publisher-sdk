//
//  CR_FeedbackStorage.m
//  pubsdk
//
//  Created by Aleksandr Pakhmutov on 25/02/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_CacheAdUnit.h"
#import "CR_FeedbackStorage.h"
#import "CR_FeedbackFileManager.h"
#import "CASObjectQueue+ArraySet.h"

@interface CR_FeedbackStorage()

@property (strong, nonatomic, readonly) CASObjectQueue<CR_FeedbackMessage *> *sendingQueue;
@property (strong, nonatomic, readonly) id<CR_FeedbackFileManaging> fileManaging;

@end

@implementation CR_FeedbackStorage

- (instancetype)init {
    CR_FeedbackFileManager * fileManager = [[CR_FeedbackFileManager alloc] init];
    CASObjectQueue<CR_FeedbackMessage *> *queue = [[CASFileObjectQueue alloc] initWithAbsolutePath:fileManager.sendingQueueFilePath error:nil];
    return [self initWithFileManager:fileManager withQueue:queue];
}

- (instancetype)initWithFileManager:(id <CR_FeedbackFileManaging>)fileManaging withQueue:(CASObjectQueue<CR_FeedbackMessage *> *)queue {
    if (self = [super init]) {
        _fileManaging = fileManaging;
        _sendingQueue = queue;
        [self moveAllFeedbackObjectsToSendingQueue];
    }
    return self;
}

- (NSArray<CR_FeedbackMessage *> *)messagesReadyToSend {
    return [self.sendingQueue peek:[self.sendingQueue size]];
}

- (void)removeFirstMessagesWithCount:(NSUInteger)count {
    [self.sendingQueue pop:count];
}

- (void)updateMessageWithImpressionId:(NSString *)impressionId by:(void (^)(CR_FeedbackMessage *message))updateFunction {
    CR_FeedbackMessage *feedback = [self readOrCreateFeedbackMessageByFilename:impressionId];
    updateFunction(feedback);
    if([feedback isReadyToSend]) {
        [self.sendingQueue addSafely:feedback];
        [self.fileManaging removeFileForFilename:impressionId];
    } else {
        [self.fileManaging writeFeedback:feedback forFilename:impressionId];
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
    CR_FeedbackMessage *feedback = [self.fileManaging readFeedbackForFilename:filename];
    if (feedback) {
        [self.sendingQueue addSafely:feedback];
    }
    [self.fileManaging removeFileForFilename:filename];
}

@end
