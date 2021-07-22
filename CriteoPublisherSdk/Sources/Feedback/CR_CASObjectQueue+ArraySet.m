//
//  CR_CASObjectQueue+ArraySet.m
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

#import "CR_CASObjectQueue+ArraySet.h"

@implementation CR_CASObjectQueue (ArraySet)

- (void)addFeedbackMessage:(CR_FeedbackMessage *)message {
  NSAssert(![self containsFeedbackMessage:message], @"Add to the queue an existing element: %@",
           [self allFeedbackMessages]);
  NSError *error;
  [self add:message error:&error];
}

- (BOOL)containsFeedbackMessage:(CR_FeedbackMessage *)message {
  NSArray *all = [self allFeedbackMessages];
  for (CR_FeedbackMessage *m in all) {
    if ([m.impressionId isEqualToString:message.impressionId]) {
      return YES;
    }
  }
  return NO;
}

- (NSArray *)allFeedbackMessages {
  NSError *error;
  return [self peek:NSUIntegerMax error:&error];
}

@end
