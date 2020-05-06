//
//  ResponseLogEntry.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "LogEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface ResponseLogEntry : NSObject <LogEntry>

#pragma mark - Lifecycle

- (instancetype)initWithResponse:(NSURLResponse *)response
                            data:(NSData *)data
                           error:(NSError *)error NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
