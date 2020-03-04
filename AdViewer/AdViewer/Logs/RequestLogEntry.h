//
//  RequestLogEntry.h
//  AdViewer
//
//  Created by Vincent Guerci on 04/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "LogEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface RequestLogEntry : NSObject <LogEntry>

#pragma mark - Lifecycle

- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
