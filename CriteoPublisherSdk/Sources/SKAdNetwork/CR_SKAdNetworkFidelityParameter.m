//
//  CR_SKAdNetworkFidelityParameter.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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

#import "CR_SKAdNetworkFidelityParameter.h"
#import "CR_Logging.h"
#import "NSString+Criteo.h"

@implementation CR_SKAdNetworkFidelityParameter
#pragma mark - Lifecycle
- (instancetype)initWithDict:(NSDictionary *)dict {
  return [self initWithFidelity:@([dict[@"fidelity"] intValue])
                      timestamp:@([dict[@"timestamp"] longLongValue])
                          nonce:[[NSUUID alloc] initWithUUIDString:dict[@"nonce"]]
                      signature:[NSString cr_nonEmptyStringWithStringOrNil:dict[@"signature"]]];
}

- (instancetype)initWithFidelity:(NSNumber *)fidelity
                       timestamp:(NSNumber *)timestamp
                           nonce:(NSUUID *)nonce
                       signature:(NSString *)signature {
  if (fidelity == nil || fidelity.intValue == 0 || nonce == nil || timestamp == nil ||
      timestamp.intValue == 0 || signature == nil) {
    CRLogError(@"SKAdNetwork", @"Unsupported payload format");
    return nil;
  }

  self = [super init];
  if (self) {
    self.fidelity = fidelity;
    self.timestamp = timestamp;
    self.nonce = nonce;
    self.signature = signature;
  }
  return self;
}
@end
