//
//  XCTestExpectation+Criteo.m
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

#import "XCTestExpectation+Criteo.h"

@implementation XCTestExpectation (Criteo)

- (instancetype)initWithPollingBlock:(BOOL (^)(void))block {
  if (self = [self init]) {
    [self pollBlock:block];
  }
  return self;
}

+ (instancetype)expectationWithPollingBlock:(BOOL (^)(void))block {
  return [[self alloc] initWithPollingBlock:block];
}

- (void)pollBlock:(BOOL (^)(void))block {
  if (block()) {
    [self fulfill];
    return;
  } else {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
      [self pollBlock:block];
    });
  }
}
@end
