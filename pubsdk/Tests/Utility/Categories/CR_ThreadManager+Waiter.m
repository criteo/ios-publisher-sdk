//
//  CR_ThreadManager+Waiter.m
//  pubsdk
//
//  Created by Romain Lofaso on 1/29/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_ThreadManager+Waiter.h"
#import "CR_ThreadManagerWaiter.h"

@implementation CR_ThreadManager (Waiter)

- (void)waiter_waitIdle {
    CR_ThreadManagerWaiter *waiter = [[CR_ThreadManagerWaiter alloc] initWithThreadManager:self];
    [waiter waitIdleWithTimeout:CR_ThreadManagerWaiter.defaultTimeout];
}

@end
