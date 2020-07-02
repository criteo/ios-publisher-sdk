//
//  CASBoundedFileObjectQueueTests.m
//  CriteoPublisherSdkTests
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

#import <XCTest/XCTest.h>
#import "CASBoundedFileObjectQueue.h"

@interface CASBoundedFileObjectQueueTests : XCTestCase
@property(strong, nonatomic) CASBoundedFileObjectQueue *queue;
@end

static const NSUInteger CASBoundedFileObjectQueueTestsMaxFileLength = 1024 * 8;

@implementation CASBoundedFileObjectQueueTests

+ (NSString *)testQueuePath {
  NSString *tempPath = NSTemporaryDirectory();
  return [tempPath stringByAppendingPathComponent:NSStringFromClass(self.class)];
}

+ (void)setUp {
  [super setUp];
  // Ensure we do not have leftovers from a previous test
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:self.testQueuePath]) {
    [fileManager removeItemAtPath:self.testQueuePath error:nil];
  }
}

- (void)setUp {
  [super setUp];
  NSError *error = nil;
  self.queue = [[CASBoundedFileObjectQueue alloc]
      initWithAbsolutePath:self.class.testQueuePath
             maxFileLength:CASBoundedFileObjectQueueTestsMaxFileLength
                     error:&error];
  XCTAssertNil(error);
}

- (void)tearDown {
  [super tearDown];
  [self.queue clear];
}

- (void)testInitWithoutError {
  XCTAssertNotNil(self.queue);
}

- (void)addDummyObjectsToQueue:(CASObjectQueue *)queue size:(NSUInteger)size {
  static const NSUInteger dummyObjectSize = 1024;
  void *dummyBytes = malloc(dummyObjectSize);
  NSData *dummyObject = [NSData dataWithBytes:dummyBytes length:dummyObjectSize];
  for (int j = 0; j < size / dummyObjectSize; ++j) {
    [queue add:dummyObject];
  }
}

- (void)testReachBoundOut {
  NSUInteger initialQueueSize = self.queue.size;
  // Fill queue
  [self addDummyObjectsToQueue:self.queue size:CASBoundedFileObjectQueueTestsMaxFileLength];
  XCTAssertLessThan(initialQueueSize, self.queue.size, @"Queue should have grown");
}

- (void)testInsertOutOfBound {
  // Fill queue
  [self addDummyObjectsToQueue:self.queue size:CASBoundedFileObjectQueueTestsMaxFileLength];
  NSUInteger boundedQueueSize = self.queue.size;
  // Add data out of bound
  [self addDummyObjectsToQueue:self.queue size:CASBoundedFileObjectQueueTestsMaxFileLength];
  XCTAssertEqual(boundedQueueSize, self.queue.size, @"Queue should not grow anymore");
}

@end
