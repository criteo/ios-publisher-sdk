//
//  CR_FeedbackFileManager.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_FeedbackMessage.h"
#import "CR_DefaultFileManipulator.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CR_FeedbackFileManaging <NSObject>

@required

- (nullable CR_FeedbackMessage *)readFeedbackForFilename:(NSString *)filename;

- (void)writeFeedback:(CR_FeedbackMessage *)feedback forFilename:(NSString *)filename;

- (void)removeFileForFilename:(NSString *)filename;

- (NSArray<NSString *> *)allActiveFeedbackFilenames;

- (void)removeSendingQueueFile;

@end

@interface CR_FeedbackFileManager : NSObject <CR_FeedbackFileManaging>

@property(strong, nonatomic) NSString *sendingQueueFilePath;

- (instancetype)initWithFileManipulating:(NSObject<CR_FileManipulating> *)fileManipulating
                activeMetricsMaxFileSize:(NSUInteger)activeMetricsMaxFileSize
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
