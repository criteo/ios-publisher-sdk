//
//  CRInterstitialAdUnit.m
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

#import "CRInterstitialAdUnit.h"
#import "CRAdUnit+Internal.h"
#import <UIKit/UIKit.h>

@implementation CRInterstitialAdUnit

- (instancetype)initWithAdUnitId:(NSString *)adUnitId {
  self = [super initWithAdUnitId:adUnitId adUnitType:CRAdUnitTypeInterstitial];
  return self;
}

- (NSUInteger)hash {
  return super.hash ^ (NSUInteger)14559042078869117629ull;
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }

  if (![object isKindOfClass:CRInterstitialAdUnit.class]) {
    return NO;
  }

  return [self isEqualToInterstitialAdUnit:object];
}

- (BOOL)isEqualToInterstitialAdUnit:(CRInterstitialAdUnit *)adUnit {
  return [adUnit isMemberOfClass:self.class] && [self isEqualToAdUnit:adUnit];
}

@end
