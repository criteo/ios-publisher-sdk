//
//  LogManager.m
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

#import "LogManager.h"

#import "EventLogEntry.h"
#import "RequestLogEntry.h"
#import "ResponseLogEntry.h"

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

#pragma mark - Private

- (void)log:(id<LogEntry>)entry {
  NSLog(@"%@ (detail: %@)", entry.title, entry.detail);
  [_logs insertObject:entry atIndex:0];
  [_notificationCenter postNotificationName:kLogUpdateKey object:entry];
}

#pragma mark - Public

- (void)logEvent:(NSString *)event detail:(NSString *)detail {
  [self log:[[EventLogEntry alloc] initWithEvent:event detail:detail]];
}

- (void)logEvent:(NSString *)event info:(id)info {
  [self logEvent:event detail:[info debugDescription]];
}

- (void)logEvent:(NSString *)event info:(id)info error:(NSError *)error {
  [self logEvent:event
          detail:[NSString stringWithFormat:@"info: %@\nerror: %@", [info debugDescription],
                                            [error localizedDescription]]];
}

#pragma mark - NetworkManagerDelegate

- (void)networkManager:(NetworkManager *)manager sentRequest:(NSURLRequest *)request {
  [self log:[[RequestLogEntry alloc] initWithRequest:request]];
}

- (void)networkManager:(NetworkManager *)manager
      receivedResponse:(NSURLResponse *)response
              withData:(NSData *)data
                 error:(NSError *)error {
  [self log:[[ResponseLogEntry alloc] initWithResponse:response data:data error:error]];
}
@end
