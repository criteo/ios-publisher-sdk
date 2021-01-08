//
//  CR_Session.m
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

#import "CR_Session.h"
#import "CR_UniqueIdGenerator.h"

@interface CR_Session ()
@property(nonatomic, copy) NSDate *startDate;
@end

@implementation CR_Session

- (id)initWithStartDate:(NSDate *)date {
  if (self = [super init]) {
    _startDate = date;
    _sessionId = CR_UniqueIdGenerator.generateId;
  }
  return self;
}

- (NSTimeInterval)duration {
  return -self.startDate.timeIntervalSinceNow;
}

@end
