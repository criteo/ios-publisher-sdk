//
//  CR_CASBoundedFileObjectQueue.m
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

#import "CR_CASBoundedFileObjectQueue.h"
#import "CR_CASQueueFile.h"

/**
 * Expose the CASFileObjectQueue private queueFile.fileLength property
 * Starts with QueueFileInitialLength = 4096 then grows by *2 as needed
 */
@interface CR_CASFileObjectQueue (private)
@property(nonatomic, nonnull, strong, readonly) CR_CASQueueFile *queueFile;
@end

@interface CR_CASQueueFile (private)
@property(nonatomic, readwrite) NSUInteger fileLength;
@end

@interface CR_CASBoundedFileObjectQueue ()
@property(assign, nonatomic, readonly) NSUInteger maxFileLength;
@end

@implementation CR_CASBoundedFileObjectQueue

- (instancetype)initWithAbsolutePath:(NSString *)filePath
                       maxFileLength:(NSUInteger)maxFileLength
                               error:(NSError *__autoreleasing *_Nullable)error {
  if (self = [super initWithAbsolutePath:filePath error:error]) {
    _maxFileLength = maxFileLength;
  }
  return self;
}

- (BOOL)add:(id<NSCoding>)data error:(NSError *__autoreleasing *_Nullable)error {
  if ([super add:data error:error]) {
    if (self.queueFile.fileLength > self.maxFileLength) {
      return [self pop:1 error:error];
    }
    return YES;
  }
  return NO;
}

@end
