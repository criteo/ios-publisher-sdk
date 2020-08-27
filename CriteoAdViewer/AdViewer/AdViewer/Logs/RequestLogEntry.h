//
//  RequestLogEntry.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "LogEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface RequestLogEntry : NSObject <LogEntry>

#pragma mark - Lifecycle

- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
