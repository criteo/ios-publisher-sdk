//
//  CR_FeedbackFileManager.m
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

#import "CR_FeedbackFileManager.h"

@interface CR_FeedbackFileManager ()

@property(strong, nonatomic, readonly) NSString *activeMetricsPath;
@property(strong, nonatomic, readonly) id<CR_FileManipulating> fileManipulating;
@property(assign, nonatomic, readonly) NSUInteger activeMetricsMaxFileSize;

@end

// Maximum size (in bytes) of metric elements stored in the metrics folder.
// 160KB represents ~300 metrics (with ~556 bytes/metric) which already represent an extreme case.
// Setting a bit more to have some margin, which we can as 256KB is still relatively small
static NSUInteger const CR_FeedbackFileManagerActiveMetricsMaxFileSize = 256 * 1024;

@implementation CR_FeedbackFileManager

- (instancetype)init {
  return [self initWithFileManipulating:[[CR_DefaultFileManipulator alloc] init]
               activeMetricsMaxFileSize:CR_FeedbackFileManagerActiveMetricsMaxFileSize];
}

- (instancetype)initWithFileManipulating:(id<CR_FileManipulating>)fileManipulating
                activeMetricsMaxFileSize:(NSUInteger)activeMetricsMaxFileSize {
  if (self = [super init]) {
    _fileManipulating = fileManipulating;
    _activeMetricsMaxFileSize = activeMetricsMaxFileSize;

    NSString *rootDirectoryPath = _fileManipulating.libraryPath;
    if (!rootDirectoryPath) {
      return nil;
    }
    NSString *metricsRootPath =
        [rootDirectoryPath stringByAppendingPathComponent:@"criteo_metrics"];
    _activeMetricsPath = [metricsRootPath stringByAppendingPathComponent:@"active"];
    _sendingQueueFilePath = [metricsRootPath stringByAppendingPathComponent:@"sendingQueue"];

    if (![fileManipulating fileExistsAtPath:_activeMetricsPath isDirectory:nil]) {
      [fileManipulating createDirectoryAtPath:_activeMetricsPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil];
    }
  }
  return self;
}

- (nullable CR_FeedbackMessage *)readFeedbackForFilename:(NSString *)filename {
  NSData *content =
      [self.fileManipulating readDataForAbsolutePath:[self buildAbsolutePathByFilename:filename]];
  if (@available(iOS 11.0, *)) {
    return [NSKeyedUnarchiver unarchivedObjectOfClass:CR_FeedbackMessage.class
                                             fromData:content
                                                error:nil];
  } else {
    return [NSKeyedUnarchiver unarchiveObjectWithData:content];
  }
}

- (void)writeFeedback:(CR_FeedbackMessage *)feedback forFilename:(NSString *)filename {
  NSData *content = nil;
  if (@available(iOS 11.0, *)) {
    content = [NSKeyedArchiver archivedDataWithRootObject:feedback
                                    requiringSecureCoding:NO
                                                    error:nil];
  } else {
    content = [NSKeyedArchiver archivedDataWithRootObject:feedback];
  }

  NSString *feedbackPath = [self buildAbsolutePathByFilename:filename];
  if ([self.fileManipulating fileExistsAtPath:feedbackPath isDirectory:nil] ||
      [self getActiveMetricsFileSize] < self.activeMetricsMaxFileSize) {
    [self.fileManipulating writeData:content forAbsolutePath:feedbackPath];
  }
}

- (NSUInteger)getActiveMetricsFileSize {
  return [self.fileManipulating sizeOfDirectoryAtPath:self.activeMetricsPath error:nil];
}

- (void)removeFileForFilename:(NSString *)filename {
  NSAssert(filename, @"We should never remove active metrics folder");
  if (filename == nil) {
    return;
  }
  [self.fileManipulating removeItemAtPath:[self buildAbsolutePathByFilename:filename] error:nil];
}

- (NSArray<NSString *> *)allActiveFeedbackFilenames {
  return [self.fileManipulating contentsOfDirectoryAtPath:[self activeMetricsPath] error:nil];
}

- (void)removeSendingQueueFile {
  [self.fileManipulating removeItemAtPath:_sendingQueueFilePath error:nil];
}

#pragma mark - Private methods

- (NSString *)buildAbsolutePathByFilename:(NSString *)filename {
  return [self.activeMetricsPath stringByAppendingPathComponent:filename];
}

@end
