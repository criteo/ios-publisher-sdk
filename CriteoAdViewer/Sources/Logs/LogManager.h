//
//  LogManager.h
//  CriteoAdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

@property(strong, nonatomic, readonly) NSArray<id<LogEntry>> *logs;

- (void)logEvent:(NSString *)event detail:(NSString *)detail;

- (void)logEvent:(NSString *)event info:(id)info;

- (void)logEvent:(NSString *)event info:(id)info error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
