//
//  CRNativeAdUnit.m
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

#import "CRNativeAdUnit.h"
#import "CRAdUnit+Internal.h"

@implementation CRNativeAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
  self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeNative];
  return self;
}

- (NSUInteger)hash {
  return self.adUnitId.hash ^ (NSUInteger)11748390512345843219ull;
}

- (BOOL)isEqual:(id)other {
  if (!other || ![other isMemberOfClass:CRNativeAdUnit.class]) {
    return NO;
  }
  return [self isEqualToNativeAdUnit:(CRNativeAdUnit *)other];
}

- (BOOL)isEqualToNativeAdUnit:(CRNativeAdUnit *)other {
  return [self.adUnitId isEqualToString:other.adUnitId];
}

@end
