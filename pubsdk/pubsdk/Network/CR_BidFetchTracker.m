//
//  CR_BidFetchTracker.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
