//
//  ResponseLogEntry.m
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

#import "ResponseLogEntry.h"

@interface ResponseLogEntry ()

@property(copy, nonatomic) NSDate *timestamp;
@property(copy, nonatomic) NSURLResponse *response;
@property(weak, nonatomic) NSHTTPURLResponse *httpResponse;
@property(copy, nonatomic) NSData *data;
@property(copy, nonatomic) NSError *error;

@end

@implementation ResponseLogEntry

#pragma mark - Lifecycle

- (instancetype)initWithResponse:(NSURLResponse *)response
                            data:(NSData *)data
                           error:(NSError *)error {
  if (self = [super init]) {
    _timestamp = [NSDate date];
    _response = [response copy];
    _httpResponse =
        [_response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)_response : nil;
    _data = [data copy];
    _error = [error copy];
  }
  return self;
}

#pragma mark - Public

- (NSString *)title {
  NSString *host = self.response.URL.host ?: @"Unknown";
  return
      [NSString stringWithFormat:@"⬇️ RESP: %ld %@", (long)self.httpResponse.statusCode, host];
}

- (NSString *)subtitle {
  NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
  timestampFormatter.dateFormat = @"HH:mm:ss.SSS";
  NSString *ts = [timestampFormatter stringFromDate:self.timestamp];
  return ts;
}

- (NSString *)detail {
  NSString *detail = [self.title stringByAppendingString:@"\n\n"];

  // Error
  if (self.error) {
    detail = [detail stringByAppendingFormat:@"Error: %@\nReason: %@\n\n",
                                             self.error.localizedDescription,
                                             self.error.localizedFailureReason];
  }

  // Status
  if (self.httpResponse) {
    detail = [detail
        stringByAppendingFormat:@"Status: %ld %@\n\n", (long)self.httpResponse.statusCode,
                                [NSHTTPURLResponse
                                    localizedStringForStatusCode:self.httpResponse.statusCode]];
  }

  // Body
  NSString *body =
      self.data ? [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] : nil;
  detail = [detail stringByAppendingFormat:@"Body: %@", body];

  return detail;
}
@end
