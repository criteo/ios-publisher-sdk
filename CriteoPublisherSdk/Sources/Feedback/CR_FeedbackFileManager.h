//
//  CR_FeedbackFileManager.h
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
