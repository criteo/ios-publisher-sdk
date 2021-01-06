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

#import "CR_RemoteLogStorage.h"

#import "CR_CASBoundedFileObjectQueue.h"
#import "CR_DefaultFileManipulator.h"
#import "CR_RemoteLogRecord.h"

@interface CR_RemoteLogStorage ()
@property(strong, nonatomic, readonly) CR_CASObjectQueue<CR_RemoteLogRecord *> *logQueue;
@end

// Maximum size (in bytes) of stored log records
static NSUInteger const CR_RemoteLogStorageLogQueueMaxSize = 256 * 1024;

@implementation CR_RemoteLogStorage

#pragma mark - Lifecycle

- (instancetype)init {
  return [self initWithLogQueueMaxFileLength:CR_RemoteLogStorageLogQueueMaxSize
                             fileManipulator:[[CR_DefaultFileManipulator alloc] init]];
}

- (instancetype)initWithLogQueueMaxFileLength:(NSUInteger)maxFileLength
                              fileManipulator:(id<CR_FileManipulating>)fileManipulator {
  self = [super init];
  if (self) {
    NSString *logQueuePath = [fileManipulator.libraryPath stringByAppendingPathComponent:@"logs"];
    @try {
      _logQueue = [self queueWithAbsolutePath:logQueuePath maxFileLength:maxFileLength];
    } @catch (NSException *exception) {
      // Try to recover by deleting potentially corrupted file
      [fileManipulator removeItemAtPath:logQueuePath error:nil];
      _logQueue = [self queueWithAbsolutePath:logQueuePath maxFileLength:maxFileLength];
    }
  }
  return self;
}

#pragma mark - Public

- (void)pushRemoteLogRecord:(CR_RemoteLogRecord *)record {
  @synchronized(self) {
    [self.logQueue add:record];
  }
}

- (NSArray<CR_RemoteLogRecord *> *)popRemoteLogRecords:(NSUInteger)size {
  @synchronized(self) {
    NSArray<CR_RemoteLogRecord *> *records = [self.logQueue peek:size];
    [self.logQueue pop:size];
    return records;
  }
}

#pragma mark - Private

- (CR_CASObjectQueue<CR_RemoteLogRecord *> *)queueWithAbsolutePath:(NSString *)path
                                                     maxFileLength:(NSUInteger)length {
  return [[CR_CASBoundedFileObjectQueue alloc] initWithAbsolutePath:path
                                                      maxFileLength:length
                                                              error:nil];
}

@end