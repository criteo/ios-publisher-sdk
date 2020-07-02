//
//  CR_ThreadManager+Waiter.m
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
#import "CR_ThreadManager+Waiter.h"
#import "CR_ThreadManagerWaiter.h"

@implementation CR_ThreadManager (Waiter)

- (void)waiter_waitIdle {
  CR_ThreadManagerWaiter *waiter = [[CR_ThreadManagerWaiter alloc] initWithThreadManager:self];
  [waiter waitIdle];
}

@end
