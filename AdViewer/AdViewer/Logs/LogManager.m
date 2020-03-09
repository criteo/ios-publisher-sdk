//
//  LogManager.m
//  AdViewer
//
//  Created by Vincent Guerci on 03/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "LogManager.h"

NSString *const kLogUpdateKey = @"kLogUpdate";

@interface LogManager () {
    NSMutableArray *_logs;
    NSNotificationCenter *_notificationCenter;
}

@end

@implementation LogManager

#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        _logs = [[NSMutableArray alloc] init];
        _notificationCenter = [NSNotificationCenter defaultCenter];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static LogManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - Public

- (void)log:(id <LogEntry>)entry {
    [_logs insertObject:entry atIndex:0];
    [_notificationCenter postNotificationName:kLogUpdateKey object:entry];
}

@end
