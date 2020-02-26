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

@interface CR_FeedbackStorage()

@property (strong, nonatomic, readonly) NSMutableDictionary *filenameMap;
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
        _filenameMap = [[NSMutableDictionary alloc] init];
        _fileManaging = fileManaging;
        _sendingQueue = queue;
        [self moveAllFeedbackObjectsToSendingQueue];
    }
    return self;
}

- (NSArray<CR_FeedbackMessage *> *)messagesReadyToSend {
    return [self.sendingQueue peek:[self.sendingQueue size]];
}

- (void)removeMessages:(NSUInteger)amount {
    [self.sendingQueue pop:amount];
}

- (void)updateMessageWithAdUnit:(CR_CacheAdUnit *)adUnit by:(void (^)(CR_FeedbackMessage *message))updateFunction {
    NSString *filename = [self getOrCreateFilenameForAdUnit:adUnit];
    CR_FeedbackMessage *feedback = [self readOrCreateFeedbackMessageByFilename:filename];
    updateFunction(feedback);
    if([feedback isReadyToSend]) {
        [self.sendingQueue add:feedback];
        [self.fileManaging removeFileForFilename:filename];
    } else {
        [self.fileManaging writeFeedback:feedback forFilename:filename];
    }
}

#pragma mark - Private methods

- (NSString *)getOrCreateFilenameForAdUnit:(CR_CacheAdUnit *)adUnit {
    NSString *filename = self.filenameMap[adUnit];
    if(!filename) {
        filename = [NSString stringWithFormat:@"%@_%@", adUnit.adUnitId, [NSUUID UUID]];
        self.filenameMap[adUnit] = filename;
    }
    return filename;
}

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
        [self.sendingQueue add:feedback];
    }
    [self.fileManaging removeFileForFilename:filename];
}

@end
