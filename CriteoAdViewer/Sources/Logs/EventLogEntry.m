//
//  EventLogEntry.m
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

#import "EventLogEntry.h"

@interface EventLogEntry ()

@property(copy, nonatomic) NSDate *timestamp;
@property(copy, nonatomic) NSString *event;
@property(copy, nonatomic) NSString *detail;

@end

@implementation EventLogEntry

#pragma mark - Lifecycle

- (instancetype)initWithEvent:(NSString *)event detail:(NSString *)detail {
  if (self = [super init]) {
    _timestamp = [NSDate date];
    _event = [event copy];
    _detail = [detail copy];
  }
  return self;
}

#pragma mark - Public

- (NSString *)title {
  return [NSString stringWithFormat:@"⏺ %@", self.event];
}

- (NSString *)subtitle {
  NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
  timestampFormatter.dateFormat = @"HH:mm:ss.SSS";
  NSString *ts = [timestampFormatter stringFromDate:self.timestamp];
  return ts;
}

@end
