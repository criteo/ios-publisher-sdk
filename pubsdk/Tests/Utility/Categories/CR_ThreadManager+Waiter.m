//
//  CR_ThreadManager+Waiter.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
