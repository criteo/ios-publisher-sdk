//
//  LogManager.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "LogEntry.h"
#import "NetworkManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kLogUpdateKey;

@interface LogManager : NSObject <NetworkManagerDelegate>

#pragma mark - Lifecycle

- (instancetype)init NS_UNAVAILABLE;

+ (nonnull instancetype)sharedInstance;

#pragma mark - Public

@property (strong, nonatomic, readonly) NSArray<id <LogEntry>> *logs;

- (void)logEvent:(NSString *)event detail:(NSString *)detail;

- (void)logEvent:(NSString *)event info:(id)info;

- (void)logEvent:(NSString *)event info:(id)info error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
