//
//  CRTimer.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_Timer.h"

@interface CR_Timer ()

@property(nonatomic, copy) void (^block)(NSTimer *timer);
@property(nonatomic, strong) NSTimer *nstimer;

@end

@implementation CR_Timer

+ (CR_Timer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     repeats:(BOOL)repeats
                                       block:(void (^)(NSTimer *timer))block {
  CR_Timer *timer = [[CR_Timer alloc] initWithTimeBlock:block];
  timer.nstimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                   target:timer
                                                 selector:@selector(runWithTimer:)
                                                 userInfo:nil
                                                  repeats:repeats];
  return timer;
}

- (instancetype)initWithTimeBlock:(void (^)(NSTimer *timer))block {
  if (self = [super init]) {
    _block = [block copy];
  }
  return self;
}

- (void)runWithTimer:(NSTimer *)timer {
  self.block(timer);
}

- (void)timerSelector {
  if (self.block) {
    self.block(self.nstimer);
  }
}

@end
