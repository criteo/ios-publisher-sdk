//
//  CR_BidFetchTracker.m
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

#import "CR_BidFetchTracker.h"

@interface CR_BidFetchTracker ()
@property(nonatomic, strong)
    NSMutableDictionary<CR_CacheAdUnit *, NSNumber *> *bidFetchTrackerCache;
@end

@implementation CR_BidFetchTracker

- (instancetype)init {
  if (self = [super init]) {
    _bidFetchTrackerCache = [NSMutableDictionary new];
  }
  return self;
}

- (BOOL)trySetBidFetchInProgressForAdUnit:(CR_CacheAdUnit *)adUnit {
  @synchronized(_bidFetchTrackerCache) {
    if ([_bidFetchTrackerCache[adUnit] boolValue]) {
      return NO;
    }
    _bidFetchTrackerCache[adUnit] = [NSNumber numberWithBool:YES];
    return YES;
  }
}

- (void)clearBidFetchInProgressForAdUnit:(CR_CacheAdUnit *)adUnit {
  @synchronized(_bidFetchTrackerCache) {
    [_bidFetchTrackerCache removeObjectForKey:adUnit];
  }
}

@end
