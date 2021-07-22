//
//  CR_RemoteLogStorage.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2021 Criteo. All rights reserved.
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

#import "CR_RemoteLogStorage+Internal.h"

#import "CR_CASBoundedFileObjectQueue.h"
#import "CR_DefaultFileManipulator.h"

// Maximum size (in bytes) of stored log records
static NSUInteger const CR_RemoteLogStorageLogQueueMaxFileLength = 256 * 1024;

@implementation CR_RemoteLogStorage

#pragma mark - Lifecycle

- (instancetype)init {
  return [self initWithLogQueueMaxFileLength:CR_RemoteLogStorageLogQueueMaxFileLength
                             fileManipulator:[[CR_DefaultFileManipulator alloc] init]];
}

- (instancetype)initWithLogQueueMaxFileLength:(NSUInteger)maxFileLength
                              fileManipulator:(id<CR_FileManipulating>)fileManipulator {
  CR_CASObjectQueue<CR_RemoteLogRecord *> *logQueue =
      [self buildQueueWithMaxFileLength:maxFileLength fileManipulator:fileManipulator];
  return [self initWithLogQueue:logQueue];
}

- (instancetype)initWithLogQueue:(CR_CASObjectQueue<CR_RemoteLogRecord *> *)logQueue {
  self = [super init];
  if (self) {
    _logQueue = logQueue;
  }
  return self;
}

#pragma mark - Public

- (void)pushRemoteLogRecord:(CR_RemoteLogRecord *)record {
  @synchronized(self) {
    NSError *error;
    [self.logQueue add:record error:&error];
  }
}

- (NSArray<CR_RemoteLogRecord *> *)popRemoteLogRecords:(NSUInteger)size {
  @synchronized(self) {
    NSError *error;
    NSArray<CR_RemoteLogRecord *> *records = [self.logQueue peek:size error:&error];
    [self.logQueue pop:size error:&error];
    return records;
  }
}

#pragma mark - Private

- (CR_CASObjectQueue<CR_RemoteLogRecord *> *)buildQueueWithAbsolutePath:(NSString *)path
                                                          maxFileLength:(NSUInteger)length {
  return [[CR_CASBoundedFileObjectQueue alloc] initWithAbsolutePath:path
                                                      maxFileLength:length
                                                              error:nil];
}

- (CR_CASObjectQueue<CR_RemoteLogRecord *> *)buildQueueWithMaxFileLength:(NSUInteger)maxFileLength
                                                         fileManipulator:(id<CR_FileManipulating>)
                                                                             fileManipulator {
  NSString *logQueuePath = [fileManipulator.libraryPath stringByAppendingPathComponent:@"logs"];
  CR_CASObjectQueue<CR_RemoteLogRecord *> *logQueue;
  @try {
    logQueue = [self buildQueueWithAbsolutePath:logQueuePath maxFileLength:maxFileLength];
  } @catch (NSException *exception) {
    // Try to recover by deleting potentially corrupted file
    [fileManipulator removeItemAtPath:logQueuePath error:nil];
    logQueue = [self buildQueueWithAbsolutePath:logQueuePath maxFileLength:maxFileLength];
  }
  return logQueue;
}

@end