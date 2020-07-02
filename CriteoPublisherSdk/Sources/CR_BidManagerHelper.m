//
//  CR_BidManagerHelper.m
//  CriteoPublisherSdk
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

#import "CR_BidManagerHelper.h"

@implementation CR_BidManagerHelper

+ (void)removeCriteoBidsFromMoPubRequest:(id)adRequest {
  SEL mopubKeywords = NSSelectorFromString(@"keywords");
  if ([adRequest respondsToSelector:mopubKeywords]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id keywords = [adRequest performSelector:mopubKeywords];
    if ([keywords isKindOfClass:[NSString class]]) {
      NSArray *keywordPairs = [keywords componentsSeparatedByString:@","];
      NSMutableArray *nonCriteoKeywords = [[NSMutableArray alloc] init];
      for (NSString *pair in keywordPairs) {
        if (![pair hasPrefix:@"crt_"]) {
          [nonCriteoKeywords addObject:pair];
        }
      }
      keywords = [nonCriteoKeywords componentsJoinedByString:@","];
      [adRequest setValue:keywords forKey:@"keywords"];
    }
#pragma clang diagnostic pop
  }
}

@end
