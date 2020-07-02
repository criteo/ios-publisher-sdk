//
//  NSString+Testing.m
//  CriteoPublisherSdkTests
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

#import "NSString+Testing.h"

@implementation NSString (Testing)

- (NSUInteger)ocurrencesCountOfSubstring:(NSString *)substring {
  NSUInteger count = 0, length = [self length];
  NSRange range = NSMakeRange(0, length);
  while (range.location != NSNotFound) {
    range = [self rangeOfString:substring options:0 range:range];
    if (range.location != NSNotFound) {
      range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
      count++;
    }
  }
  return count;
}

- (NSDictionary *)testing_moPubKeywordDictionary {
  NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
  NSArray *splitKeywords = [self componentsSeparatedByString:@","];
  for (NSString *keyValue in splitKeywords) {
    NSRange range = [keyValue rangeOfString:@":"];
    NSAssert(range.location != NSNotFound, @"Malformed keyword: %@ => %@", self, keyValue);

    NSRange keyRange = NSMakeRange(0, range.location);
    NSString *key = [keyValue substringWithRange:keyRange];

    NSRange valueRange = NSMakeRange(range.location + 1, keyValue.length - (range.location + 1));
    NSString *value = [keyValue substringWithRange:valueRange];

    result[key] = value;
  }
  return result;
}

@end
