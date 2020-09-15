//
//  RequestLogEntry.m
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

#import "RequestLogEntry.h"

@interface RequestLogEntry ()

@property(copy, nonatomic) NSDate *timestamp;
@property(copy, nonatomic) NSURLRequest *request;

@end

@implementation RequestLogEntry

#pragma mark - Lifecycle

- (instancetype)initWithRequest:(NSURLRequest *)request {
  if (self = [super init]) {
    _timestamp = [NSDate date];
    _request = [request copy];
  }
  return self;
}

#pragma mark - Public

- (NSString *)title {
  NSString *host = self.request.URL.host ?: @"Unknown";
  return [NSString stringWithFormat:@"⬆️ REQ: %@", host];
}

- (NSString *)subtitle {
  NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
  timestampFormatter.dateFormat = @"HH:mm:ss.SSS";
  NSString *ts = [timestampFormatter stringFromDate:self.timestamp];
  return ts;
}

- (NSString *)detail {
  if (!_request.HTTPBody) {
    return @"";
  }
  return [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
}

@end
