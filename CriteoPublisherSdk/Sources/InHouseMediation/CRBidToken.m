//
//  CRBidToken.m
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

#import "CRBidToken.h"
#import "CRBidToken+Internal.h"

@implementation CRBidToken

- (instancetype)init {
  return [self initWithUUID:nil];
}

- (instancetype)initWithUUID:(NSUUID *)uuid {
  if (self = [super init]) {
    _bidTokenUUID = uuid ? uuid : [NSUUID UUID];
  }
  return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
  return [[CRBidToken alloc] initWithUUID:_bidTokenUUID];
}

- (NSUInteger)hash {
  return _bidTokenUUID.hash;
}

- (BOOL)isEqual:(id)object {
  if ([object isKindOfClass:[CRBidToken class]]) {
    CRBidToken *other = object;
    if ([self.bidTokenUUID isEqual:other.bidTokenUUID]) {
      return YES;
    }
  }
  return NO;
}

@end
