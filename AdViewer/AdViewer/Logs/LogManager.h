//
//  LogManager.h
//  AdViewer
//
//  Created by Vincent Guerci on 03/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "LogEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogManager : NSObject

#pragma mark - Lifecycle

- (instancetype)init NS_UNAVAILABLE;

+ (nonnull instancetype)sharedInstance;

#pragma mark - Public

@property (strong, nonatomic, readonly) NSArray<id <LogEntry>> *logs;

- (void)log:(id <LogEntry>)entry;

@end

NS_ASSUME_NONNULL_END
